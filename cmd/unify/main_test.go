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
	"github.com/guruperl/aofei/hostedpayment"
)

type observingHTTPServer struct {
	*http.Server
	shutdownCalled chan struct{}
}

func TestServeMuxExposesOnlyAuthenticatedHostedPaymentWebhookWhenEnabled(t *testing.T) {
	controller := &dsp.Controller{C: &dsp.Config{}}
	payment := &hostedpayment.Service{
		Config:        hostedpayment.Config{MaxBodyBytes: 4096, WebhookToleranceSeconds: 300},
		WebhookSecret: []byte("whsec_test_at_least_16"),
	}
	mux := newServeMuxWithServices(controller, http.NotFoundHandler(), nil, nil, payment)
	request := httptest.NewRequest(http.MethodPost, "/webhooks/stripe", strings.NewReader(`{"id":"evt_test"}`))
	request.Header.Set("Content-Type", "application/json")
	request.Header.Set("Stripe-Signature", "t=1,v1=00")
	response := httptest.NewRecorder()
	mux.ServeHTTP(response, request)
	if response.Code != http.StatusBadRequest {
		t.Fatalf("invalid signature status=%d, want 400", response.Code)
	}
	request = httptest.NewRequest(http.MethodPost, "/webhooks/stripe/extra", strings.NewReader(`{}`))
	response = httptest.NewRecorder()
	mux.ServeHTTP(response, request)
	if response.Code != http.StatusNotFound {
		t.Fatalf("non-exact webhook path status=%d, want 404", response.Code)
	}

	disabled := newServeMux(controller, http.NotFoundHandler())
	request = httptest.NewRequest(http.MethodPost, "/webhooks/stripe", strings.NewReader(`{}`))
	response = httptest.NewRecorder()
	disabled.ServeHTTP(response, request)
	if response.Code != http.StatusNotFound {
		t.Fatalf("disabled webhook status=%d, want 404", response.Code)
	}
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
		{name: "action", method: http.MethodPost, path: "/action", body: "{}", want: http.StatusUnsupportedMediaType},
		{name: "debug vars", method: http.MethodGet, path: "/debug/vars", want: http.StatusOK},
		{name: "liveness", method: http.MethodGet, path: "/healthz", want: http.StatusNoContent},
		{name: "readiness", method: http.MethodGet, path: "/readyz", want: http.StatusServiceUnavailable},
	}
	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			req := httptest.NewRequest(tt.method, tt.path, strings.NewReader(tt.body))
			if tt.path == "/debug/vars" {
				req.RemoteAddr = "127.0.0.1:1234"
			}
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
	remoteMetrics := httptest.NewRequest(http.MethodGet, "/debug/vars", nil)
	remoteMetrics.RemoteAddr = "203.0.113.10:1234"
	remoteMetrics.Header.Set("X-Forwarded-For", "127.0.0.1")
	remoteMetricsResponse := httptest.NewRecorder()
	mux.ServeHTTP(remoteMetricsResponse, remoteMetrics)
	if remoteMetricsResponse.Code != http.StatusNotFound {
		t.Fatalf("remote metrics status = %d, want 404", remoteMetricsResponse.Code)
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

func TestReadinessWithdrawsBeforeGracefulDrain(t *testing.T) {
	health := newServiceHealth(&dsp.Controller{C: &dsp.Config{}})
	health.accepting.Store(true)
	mux := newServeMux(health.controller, http.NotFoundHandler(), health)

	before := httptest.NewRecorder()
	mux.ServeHTTP(before, httptest.NewRequest(http.MethodGet, "/readyz", nil))
	if before.Code != http.StatusNoContent {
		t.Fatalf("ready status before drain = %d", before.Code)
	}
	health.accepting.Store(false)
	after := httptest.NewRecorder()
	mux.ServeHTTP(after, httptest.NewRequest(http.MethodGet, "/readyz", nil))
	if after.Code != http.StatusServiceUnavailable || after.Header().Get("Cache-Control") != "no-store" {
		t.Fatalf("ready status after drain = %d headers=%v", after.Code, after.Header())
	}
	live := httptest.NewRecorder()
	mux.ServeHTTP(live, httptest.NewRequest(http.MethodGet, "/healthz", nil))
	if live.Code != http.StatusNoContent {
		t.Fatalf("liveness during drain = %d", live.Code)
	}
}

func TestHealthCheckedFailoverKeepsSecondNodeServing(t *testing.T) {
	newNode := func() (*httptest.Server, *serviceHealth) {
		controller := &dsp.Controller{C: &dsp.Config{}}
		health := newServiceHealth(controller)
		health.accepting.Store(true)
		mux := newServeMux(controller, http.HandlerFunc(func(w http.ResponseWriter, _ *http.Request) {
			w.WriteHeader(http.StatusNoContent)
		}), health)
		return httptest.NewServer(mux), health
	}
	nodeOne, healthOne := newNode()
	defer nodeOne.Close()
	nodeTwo, _ := newNode()
	defer nodeTwo.Close()

	selectReady := func(nodes ...string) string {
		t.Helper()
		client := &http.Client{Timeout: time.Second}
		for _, node := range nodes {
			response, err := client.Get(node + "/readyz")
			if err != nil {
				continue
			}
			response.Body.Close()
			if response.StatusCode == http.StatusNoContent {
				return node
			}
		}
		return ""
	}

	if got := selectReady(nodeOne.URL, nodeTwo.URL); got != nodeOne.URL {
		t.Fatalf("initial ready node = %q, want first node", got)
	}
	healthOne.accepting.Store(false)
	if got := selectReady(nodeOne.URL, nodeTwo.URL); got != nodeTwo.URL {
		t.Fatalf("ready node after first-node drain = %q, want second node", got)
	}
	response, err := http.Get(nodeTwo.URL + "/goto/pub")
	if err != nil {
		t.Fatal(err)
	}
	defer response.Body.Close()
	if response.StatusCode != http.StatusNoContent {
		t.Fatalf("second-node response = %d, want 204", response.StatusCode)
	}
}

func TestServeMuxAppliesIndependentADXPartnerLimits(t *testing.T) {
	controller := &dsp.Controller{C: &dsp.Config{
		TrafficDefault: dsp.TrafficPolicy{QPS: 0.001, Burst: 1, MaxConcurrency: 2, TimeoutMS: 500, MaxBodyBytes: 1024},
		TrafficPartners: map[string]dsp.TrafficPolicy{
			"adx:a.example": {},
			"adx:b.example": {},
		},
	}}
	mux := newServeMux(controller, http.NotFoundHandler())
	request := func(partner string) int {
		req := httptest.NewRequest(http.MethodPost, "/bid/"+partner, strings.NewReader("{"))
		response := httptest.NewRecorder()
		mux.ServeHTTP(response, req)
		return response.Code
	}
	if got := request("a.example"); got != http.StatusBadRequest {
		t.Fatalf("first A status = %d, want 400", got)
	}
	if got := request("a.example"); got != http.StatusTooManyRequests {
		t.Fatalf("second A status = %d, want 429", got)
	}
	if got := request("b.example"); got != http.StatusBadRequest {
		t.Fatalf("first B status = %d, want independent 400", got)
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
