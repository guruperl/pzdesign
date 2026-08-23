package summer

import (
	"context"
	"encoding/json"
	"net/http"
	"net/http/httptest"
	"net/netip"
	"net/url"
	"strings"
	"sync/atomic"
	"testing"
	"time"

	"github.com/alicebob/miniredis/v2"
	"github.com/guruperl/genelet"
	"github.com/mediocregopher/radix/v4"
)

func testPublicAccountProtector(t *testing.T, handler http.Handler, limits []publicAccountLimit) (*PublicAccountProtector, *miniredis.Miniredis) {
	t.Helper()
	server := miniredis.RunT(t)
	client, err := (radix.PoolConfig{Size: 1}).New(context.Background(), "tcp", server.Addr())
	if err != nil {
		t.Fatal(err)
	}
	t.Cleanup(func() { client.Close() })
	verify := httptest.NewServer(handler)
	t.Cleanup(verify.Close)
	trusted := []netip.Prefix{
		netip.MustParsePrefix("127.0.0.0/8"),
		netip.MustParsePrefix("203.0.113.0/24"),
	}
	protector, err := newPublicAccountProtector(publicAccountProtectionConfig{
		siteKey:        "public-site-key",
		secretKey:      "private-secret-key",
		hostnames:      map[string]struct{}{"w8m.com": {}, "www.w8m.com": {}},
		trustedProxies: trusted,
		limits:         limits,
		verifyURL:      verify.URL,
	}, client, verify.Client())
	if err != nil {
		t.Fatal(err)
	}
	return protector, server
}

func successfulTurnstileHandler(t *testing.T, calls *atomic.Int64, expectedAction string) http.Handler {
	t.Helper()
	return http.HandlerFunc(func(response http.ResponseWriter, request *http.Request) {
		calls.Add(1)
		if err := request.ParseForm(); err != nil {
			t.Error(err)
			response.WriteHeader(http.StatusBadRequest)
			return
		}
		if request.Form.Get("secret") != "private-secret-key" || request.Form.Get("response") == "" {
			t.Errorf("unexpected Siteverify form %#v", request.Form)
		}
		if request.Form.Get("remoteip") != "198.51.100.25" {
			t.Errorf("remoteip = %q", request.Form.Get("remoteip"))
		}
		response.Header().Set("Content-Type", "application/json")
		_ = json.NewEncoder(response).Encode(map[string]interface{}{
			"success":  true,
			"hostname": "www.w8m.com",
			"action":   expectedAction,
		})
	})
}

func TestVerifyPublicAccountHumanValidatesExpectedContextBeforeRedis(t *testing.T) {
	var calls atomic.Int64
	protector, redisServer := testPublicAccountProtector(t, successfulTurnstileHandler(t, &calls, "register_adv"), []publicAccountLimit{
		{scope: "ip_10m", limit: 10, window: 10 * time.Minute},
	})
	request := httptest.NewRequest(http.MethodPost, "/goto/web/g/adv", strings.NewReader(url.Values{
		"cf-turnstile-response": {"single-use-token"},
	}.Encode()))
	request.Header.Set("Content-Type", "application/x-www-form-urlencoded")
	request.Header.Set("X-Forwarded-For", "198.51.100.25, 203.0.113.8")
	request.RemoteAddr = "127.0.0.1:8200"
	if err := request.ParseForm(); err != nil {
		t.Fatal(err)
	}
	storage := map[string]interface{}{PublicAccountProtectorStorageKey: protector}
	if err := VerifyPublicAccountHuman(storage, request, "web", "adv", "insert"); err != nil {
		t.Fatal(err)
	}
	if calls.Load() != 1 {
		t.Fatalf("Siteverify calls = %d, want 1", calls.Load())
	}
	if request.Form.Get("cf-turnstile-response") != "" {
		t.Fatal("Turnstile token remained in request form")
	}
	if request.Context().Value(publicAccountHumanContextKey{}) != "register_adv" {
		t.Fatalf("validation marker = %#v", request.Context().Value(publicAccountHumanContextKey{}))
	}
	if keys := redisServer.Keys(); len(keys) != 0 {
		t.Fatalf("verification touched Redis: %v", keys)
	}
}

func TestVerifyPublicAccountHumanRejectsMissingAndMisScopedTokens(t *testing.T) {
	var calls atomic.Int64
	protector, redisServer := testPublicAccountProtector(t, successfulTurnstileHandler(t, &calls, "recover_pub"), []publicAccountLimit{
		{scope: "ip_10m", limit: 10, window: 10 * time.Minute},
	})
	storage := map[string]interface{}{PublicAccountProtectorStorageKey: protector}

	missing := httptest.NewRequest(http.MethodPost, "/goto/web/g/pub", nil)
	missing.RemoteAddr = "198.51.100.25:1234"
	missing.Form = make(url.Values)
	assertPublicAccountErrorCode(t, VerifyPublicAccountHuman(storage, missing, "web", "pub", "retrieve"), http.StatusBadRequest)
	if calls.Load() != 0 {
		t.Fatal("missing token called Siteverify")
	}
	oversized := httptest.NewRequest(http.MethodPost, "/goto/web/g/pub", nil)
	oversized.RemoteAddr = "198.51.100.25:1234"
	oversized.Form = url.Values{"cf-turnstile-response": {strings.Repeat("x", turnstileTokenLimit+1)}}
	assertPublicAccountErrorCode(t, VerifyPublicAccountHuman(storage, oversized, "web", "pub", "retrieve"), http.StatusBadRequest)
	if calls.Load() != 0 {
		t.Fatal("oversized token called Siteverify")
	}

	wrongAction := httptest.NewRequest(http.MethodPost, "/goto/web/g/adv", nil)
	wrongAction.RemoteAddr = "198.51.100.25:1234"
	wrongAction.Form = url.Values{"cf-turnstile-response": {"wrong-action-token"}}
	assertPublicAccountErrorCode(t, VerifyPublicAccountHuman(storage, wrongAction, "web", "adv", "insert"), http.StatusBadRequest)
	if calls.Load() != 1 {
		t.Fatalf("Siteverify calls = %d, want 1", calls.Load())
	}
	if keys := redisServer.Keys(); len(keys) != 0 {
		t.Fatalf("rejected verification touched Redis: %v", keys)
	}
}

func TestVerifyPublicAccountHumanFailsClosedWhenTurnstileUnavailable(t *testing.T) {
	protector, _ := testPublicAccountProtector(t, http.HandlerFunc(func(response http.ResponseWriter, _ *http.Request) {
		response.WriteHeader(http.StatusBadGateway)
	}), []publicAccountLimit{{scope: "ip_10m", limit: 10, window: 10 * time.Minute}})
	request := httptest.NewRequest(http.MethodPost, "/goto/web/g/adv", nil)
	request.RemoteAddr = "198.51.100.25:1234"
	request.Form = url.Values{"cf-turnstile-response": {"token"}}
	storage := map[string]interface{}{PublicAccountProtectorStorageKey: protector}
	assertPublicAccountErrorCode(t, VerifyPublicAccountHuman(storage, request, "web", "adv", "insert"), http.StatusServiceUnavailable)
}

func TestVerifyPublicAccountHumanRejectsWrongHostname(t *testing.T) {
	protector, _ := testPublicAccountProtector(t, http.HandlerFunc(func(response http.ResponseWriter, _ *http.Request) {
		response.Header().Set("Content-Type", "application/json")
		_, _ = response.Write([]byte(`{"success":true,"hostname":"evil.example","action":"recover_adv"}`))
	}), []publicAccountLimit{{scope: "ip_10m", limit: 10, window: 10 * time.Minute}})
	request := httptest.NewRequest(http.MethodPost, "/goto/web/g/adv", nil)
	request.RemoteAddr = "198.51.100.25:1234"
	request.Form = url.Values{"cf-turnstile-response": {"wrong-hostname-token"}}
	storage := map[string]interface{}{PublicAccountProtectorStorageKey: protector}
	assertPublicAccountErrorCode(t, VerifyPublicAccountHuman(storage, request, "web", "adv", "retrieve"), http.StatusBadRequest)
}

func TestAdmitPublicAccountSubmissionUsesAtomicPseudonymousQuotas(t *testing.T) {
	var calls atomic.Int64
	protector, redisServer := testPublicAccountProtector(t, successfulTurnstileHandler(t, &calls, "register_adv"), []publicAccountLimit{
		{scope: "ip_10m", limit: 1, window: 10 * time.Minute},
		{scope: "email_hour", limit: 10, window: time.Hour},
		{scope: "global_hour", limit: 10, window: time.Hour},
	})
	storage := map[string]interface{}{PublicAccountProtectorStorageKey: protector}
	config := &genelet.Config{Secret: "deployment-secret"}
	newRequest := func() *http.Request {
		request := httptest.NewRequest(http.MethodPost, "/goto/web/g/adv", nil)
		request.RemoteAddr = "198.51.100.25:1234"
		request.Form = url.Values{
			"email":                 {"Person@Example.Test"},
			"cf-turnstile-response": {"single-use-token"},
		}
		if err := VerifyPublicAccountHuman(storage, request, "web", "adv", "insert"); err != nil {
			t.Fatal(err)
		}
		return request
	}
	if err := AdmitPublicAccountSubmission(storage, newRequest(), config, "web", "adv", "insert"); err != nil {
		t.Fatal(err)
	}
	assertPublicAccountErrorCode(t, AdmitPublicAccountSubmission(storage, newRequest(), config, "web", "adv", "insert"), http.StatusTooManyRequests)

	keys := redisServer.Keys()
	if len(keys) != 3 {
		t.Fatalf("Redis keys = %v, want 3", keys)
	}
	for _, key := range keys {
		if strings.Contains(strings.ToLower(key), "person") || strings.Contains(strings.ToLower(key), "example.test") || strings.Contains(key, "198.51.100.25") {
			t.Fatalf("Redis key exposes request identity: %q", key)
		}
		value, err := redisServer.Get(key)
		if err != nil || value != "1" {
			t.Fatalf("Redis key %q = %q, %v; denied request must not partially increment quotas", key, value, err)
		}
		if redisServer.TTL(key) <= 0 {
			t.Fatalf("Redis key %q has no TTL", key)
		}
	}
}

func TestPublicAccountClientIPTrustsOnlyConfiguredProxyChain(t *testing.T) {
	var calls atomic.Int64
	protector, _ := testPublicAccountProtector(t, successfulTurnstileHandler(t, &calls, "register_adv"), []publicAccountLimit{
		{scope: "ip_10m", limit: 10, window: 10 * time.Minute},
	})

	direct := httptest.NewRequest(http.MethodPost, "/", nil)
	direct.RemoteAddr = "198.51.100.44:443"
	direct.Header.Set("X-Forwarded-For", "192.0.2.99")
	address, err := protector.clientIP(direct)
	if err != nil || address.String() != "198.51.100.44" {
		t.Fatalf("direct client IP = %v, %v", address, err)
	}

	proxied := httptest.NewRequest(http.MethodPost, "/", nil)
	proxied.RemoteAddr = "127.0.0.1:8200"
	proxied.Header.Set("X-Forwarded-For", "198.51.100.25, 203.0.113.8")
	address, err = protector.clientIP(proxied)
	if err != nil || address.String() != "198.51.100.25" {
		t.Fatalf("proxied client IP = %v, %v", address, err)
	}

	malformed := httptest.NewRequest(http.MethodPost, "/", nil)
	malformed.RemoteAddr = "127.0.0.1:8200"
	malformed.Header.Set("X-Forwarded-For", "not-an-address")
	if _, err := protector.clientIP(malformed); err == nil {
		t.Fatal("malformed trusted proxy chain was accepted")
	}
}

func TestPublicAccountProtectionEnvironmentIsFailClosed(t *testing.T) {
	for _, name := range []string{
		"PUBLIC_ACCOUNT_PROTECTION_ENABLED", "TURNSTILE_SITE_KEY", "TURNSTILE_SECRET_KEY",
		"TURNSTILE_HOSTNAMES", "PUBLIC_ACCOUNT_TRUSTED_PROXY_CIDRS",
	} {
		t.Setenv(name, "")
	}
	protector, err := NewPublicAccountProtectorFromEnv(nil)
	if err != nil || protector != nil {
		t.Fatalf("disabled protection = %#v, %v", protector, err)
	}
	t.Setenv("TURNSTILE_SITE_KEY", "configured-without-enable")
	if _, err := NewPublicAccountProtectorFromEnv(nil); err == nil {
		t.Fatal("credentials without the enable gate were accepted")
	}
	t.Setenv("PUBLIC_ACCOUNT_PROTECTION_ENABLED", "true")
	if _, err := NewPublicAccountProtectorFromEnv(nil); err == nil {
		t.Fatal("enabled protection without Redis and complete configuration was accepted")
	}
}

func TestAddPublicAccountProtectionViewExposesNoSecret(t *testing.T) {
	var calls atomic.Int64
	protector, _ := testPublicAccountProtector(t, successfulTurnstileHandler(t, &calls, "register_adv"), []publicAccountLimit{
		{scope: "ip_10m", limit: 10, window: 10 * time.Minute},
	})
	other := make(map[string]interface{})
	storage := map[string]interface{}{PublicAccountProtectorStorageKey: protector}
	if err := AddPublicAccountProtectionView(other, storage, "web", "adv", "startnew"); err != nil {
		t.Fatal(err)
	}
	if other["TurnstileSiteKey"] != "public-site-key" || other["TurnstileAction"] != "register_adv" {
		t.Fatalf("view metadata = %#v", other)
	}
	encoded, err := json.Marshal(other)
	if err != nil {
		t.Fatal(err)
	}
	if strings.Contains(string(encoded), "private-secret-key") {
		t.Fatal("Turnstile secret entered template data")
	}
}

func assertPublicAccountErrorCode(t *testing.T, err error, want int) {
	t.Helper()
	gerr, ok := err.(genelet.Gerror)
	if !ok || gerr.Code != want {
		t.Fatalf("error = %#v, want Gerror code %d", err, want)
	}
}
