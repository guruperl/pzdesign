package main

import (
	"context"
	"errors"
	"net"
	"net/http"
	"net/http/httptest"
	"reflect"
	"strings"
	"sync"
	"testing"
	"time"

	"github.com/guruperl/aofei/dsp"
)

type observingHTTPServer struct {
	*http.Server
	shutdownCalled chan struct{}
}

func (s *observingHTTPServer) Shutdown(ctx context.Context) error {
	close(s.shutdownCalled)
	return s.Server.Shutdown(ctx)
}

func TestRunHTTPServerDrainsInFlightRequest(t *testing.T) {
	started := make(chan struct{})
	release := make(chan struct{})
	server := &observingHTTPServer{
		Server: &http.Server{Handler: http.HandlerFunc(func(w http.ResponseWriter, _ *http.Request) {
			close(started)
			<-release
			w.WriteHeader(http.StatusNoContent)
		})},
		shutdownCalled: make(chan struct{}),
	}
	listener, err := net.Listen("tcp", "127.0.0.1:0")
	if err != nil {
		t.Fatal(err)
	}
	ctx, cancel := context.WithCancel(context.Background())
	result := make(chan error, 1)
	go func() {
		result <- runHTTPServer(ctx, server, listener, time.Second)
	}()
	requestDone := make(chan error, 1)
	go func() {
		client := &http.Client{Timeout: 2 * time.Second}
		resp, err := client.Get("http://" + listener.Addr().String())
		if err == nil {
			resp.Body.Close()
			if resp.StatusCode != http.StatusNoContent {
				err = errors.New("unexpected response status")
			}
		}
		requestDone <- err
	}()
	<-started
	cancel()
	<-server.shutdownCalled
	select {
	case err := <-result:
		t.Fatalf("server returned before in-flight request completed: %v", err)
	default:
	}
	close(release)
	if err := <-requestDone; err != nil {
		t.Fatal(err)
	}
	if err := <-result; err != nil {
		t.Fatal(err)
	}
}

type timeoutHTTPServer struct {
	closed    chan struct{}
	closeOnce sync.Once
}

func (s *timeoutHTTPServer) Serve(net.Listener) error {
	<-s.closed
	return http.ErrServerClosed
}

func (s *timeoutHTTPServer) Shutdown(ctx context.Context) error {
	<-ctx.Done()
	return ctx.Err()
}

func (s *timeoutHTTPServer) Close() error {
	s.closeOnce.Do(func() { close(s.closed) })
	return nil
}

func TestRunHTTPServerForcesCloseAfterShutdownTimeout(t *testing.T) {
	server := &timeoutHTTPServer{closed: make(chan struct{})}
	listener, err := net.Listen("tcp", "127.0.0.1:0")
	if err != nil {
		t.Fatal(err)
	}
	defer listener.Close()
	ctx, cancel := context.WithCancel(context.Background())
	cancel()
	err = runHTTPServer(ctx, server, listener, 10*time.Millisecond)
	if !errors.Is(err, context.DeadlineExceeded) {
		t.Fatalf("runHTTPServer error = %v, want deadline exceeded", err)
	}
	select {
	case <-server.closed:
	default:
		t.Fatal("server was not forcibly closed")
	}
}

func TestServeMuxRegistersDSPRoutesBeforeCatchAll(t *testing.T) {
	catchAllHits := 0
	catchAll := http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		catchAllHits++
		w.WriteHeader(http.StatusNoContent)
	})
	mux := newServeMux(&dsp.Controller{}, catchAll)

	tests := []struct {
		name   string
		method string
		path   string
		body   string
		want   int
	}{
		{name: "ssp", method: http.MethodPost, path: "/pz", body: "{", want: http.StatusBadRequest},
		{name: "ssp options", method: http.MethodOptions, path: "/pz", want: http.StatusNoContent},
		{name: "bid", method: http.MethodPost, path: "/bid/pub.example", body: "{", want: http.StatusBadRequest},
		{name: "debug vars", method: http.MethodGet, path: "/debug/vars", want: http.StatusOK},
	}
	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			req := httptest.NewRequest(tt.method, tt.path, strings.NewReader(tt.body))
			rr := httptest.NewRecorder()
			mux.ServeHTTP(rr, req)
			if rr.Code != tt.want {
				t.Fatalf("status = %d, want %d: %s", rr.Code, tt.want, rr.Body.String())
			}
			if tt.path == "/pz" {
				if got := rr.Header().Get("Access-Control-Allow-Origin"); got != "*" {
					t.Fatalf("Access-Control-Allow-Origin = %q, want *", got)
				}
				if got := rr.Header().Get("Access-Control-Allow-Methods"); got != "POST, OPTIONS" {
					t.Fatalf("Access-Control-Allow-Methods = %q, want POST, OPTIONS", got)
				}
				if got := rr.Header().Get("Access-Control-Allow-Headers"); got != "Content-Type" {
					t.Fatalf("Access-Control-Allow-Headers = %q, want Content-Type", got)
				}
			}
			if tt.path == "/bid/pub.example" && rr.Header().Get("Access-Control-Allow-Origin") != "" {
				t.Fatalf("/bid received /pz CORS headers: %v", rr.Header())
			}
		})
	}
	if catchAllHits != 0 {
		t.Fatalf("catch-all handled DSP route %d times", catchAllHits)
	}

	req := httptest.NewRequest(http.MethodGet, "/goto/pub", nil)
	rr := httptest.NewRecorder()
	mux.ServeHTTP(rr, req)
	if rr.Code != http.StatusNoContent || catchAllHits != 1 {
		t.Fatalf("catch-all status/hits = %d/%d, want 204/1", rr.Code, catchAllHits)
	}
}

func TestApplyLocalModeFlagDoesNotOverrideConfigWhenOmitted(t *testing.T) {
	controller := &dsp.Controller{C: &dsp.Config{IsLocal: true}}

	if err := applyLocalModeFlag(controller, false, false); err != nil {
		t.Fatal(err)
	}
	if !controller.C.IsLocal {
		t.Fatal("local flag omitted should preserve config local mode")
	}
}

func TestApplyLocalModeFlagEnablesAndLoadsLocalStaticCache(t *testing.T) {
	controller := &dsp.Controller{C: &dsp.Config{Spread: t.TempDir()}}

	if err := applyLocalModeFlag(controller, true, true); err != nil {
		t.Fatal(err)
	}
	if !controller.C.IsLocal {
		t.Fatal("local flag should enable config local mode")
	}
	if reflect.ValueOf(controller).Elem().FieldByName("local").IsNil() {
		t.Fatal("local flag should load the local static cache")
	}
}
