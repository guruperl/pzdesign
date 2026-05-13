package main

import (
	"net/http"
	"net/http/httptest"
	"strings"
	"testing"

	"github.com/guruperl/aofei/dsp"
)

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
