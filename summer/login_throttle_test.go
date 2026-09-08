package summer

import (
	"bytes"
	"context"
	"encoding/base64"
	"net/http"
	"strings"
	"testing"

	"github.com/alicebob/miniredis/v2"
	"github.com/guruperl/genelet"
	"github.com/mediocregopher/radix/v4"
)

func testLoginThrottle(t *testing.T) (*RedisLoginThrottle, *miniredis.Miniredis) {
	t.Helper()
	server := miniredis.RunT(t)
	client, err := (radix.PoolConfig{}).New(context.Background(), "tcp", server.Addr())
	if err != nil {
		t.Fatal(err)
	}
	t.Cleanup(func() { _ = client.Close() })
	t.Setenv("LOGIN_THROTTLE_TEST_KEY", base64.StdEncoding.EncodeToString(bytes.Repeat([]byte{7}, 32)))
	t.Setenv("LOGIN_THROTTLE_PREVIOUS_TEST_KEY", base64.StdEncoding.EncodeToString(bytes.Repeat([]byte{8}, 32)))
	protector, err := genelet.NewAccountProtector(&genelet.Config{AccountProtection: genelet.AccountProtectionConfig{
		Enabled:  true,
		Current:  genelet.AccountProtectionKeyConfig{ID: "test-1", KeyEnv: "LOGIN_THROTTLE_TEST_KEY"},
		Previous: []genelet.AccountProtectionKeyConfig{{ID: "test-0", KeyEnv: "LOGIN_THROTTLE_PREVIOUS_TEST_KEY"}},
	}, Roles: map[string]genelet.Role{"adv": {Issuers: map[string]genelet.Issuer{"db": {
		PasswordHash: "passwd", ProtectedSQL: "SELECT", IdentifierNamespace: "adv.email",
		IdentifierNormalization: "email", IdentifierCipherAttribute: "a_email",
	}}}}})
	if err != nil {
		t.Fatal(err)
	}
	throttle, err := NewRedisLoginThrottle(client, protector)
	if err != nil {
		t.Fatal(err)
	}
	return throttle, server
}

func TestRedisLoginThrottleIsSharedBoundedAndPseudonymous(t *testing.T) {
	throttle, server := testLoginThrottle(t)
	attempt := genelet.LoginAttempt{Role: "adv", Provider: "db", IdentifierDigests: [][]byte{bytes.Repeat([]byte{9}, 32)}, ClientIP: "198.51.100.10"}
	for index := 1; index <= loginThrottleLimit; index++ {
		err := throttle.Failure(context.Background(), attempt)
		if index < loginThrottleLimit && err != nil {
			t.Fatalf("failure %d = %v", index, err)
		}
		if index == loginThrottleLimit {
			if gerr, ok := err.(genelet.Gerror); !ok || gerr.Code != http.StatusTooManyRequests {
				t.Fatalf("failure %d = %#v, want 429", index, err)
			}
		}
	}
	allowed, err := throttle.Allowed(context.Background(), attempt)
	if err != nil || allowed {
		t.Fatalf("allowed = %v, %v", allowed, err)
	}
	keys := server.Keys()
	if len(keys) != 1 || strings.Contains(keys[0], "198.51.100.10") || strings.Contains(keys[0], "adv") {
		t.Fatalf("Redis keys expose identity: %v", keys)
	}
	if server.TTL(keys[0]) <= 0 {
		t.Fatal("login throttle key has no expiry")
	}
	if err := throttle.Success(context.Background(), attempt); err != nil {
		t.Fatal(err)
	}
	allowed, err = throttle.Allowed(context.Background(), attempt)
	if err != nil || !allowed || len(server.Keys()) != 0 {
		t.Fatalf("success did not clear throttle: allowed=%v err=%v keys=%v", allowed, err, server.Keys())
	}
}

func TestRedisLoginThrottleRejectsUnprotectedAttempt(t *testing.T) {
	throttle, _ := testLoginThrottle(t)
	if _, err := throttle.Allowed(context.Background(), genelet.LoginAttempt{Role: "adv", Provider: "db", ClientIP: "127.0.0.1"}); err == nil {
		t.Fatal("missing identifier digest was accepted")
	}
}

func TestRedisLoginThrottleReadsAndClearsPreviousKeyCandidates(t *testing.T) {
	throttle, server := testLoginThrottle(t)
	attempt := genelet.LoginAttempt{
		Role: "adv", Provider: "db", ClientIP: "198.51.100.20",
		IdentifierDigests: [][]byte{bytes.Repeat([]byte{10}, 32), bytes.Repeat([]byte{11}, 32)},
	}
	keys, err := throttle.keys(attempt)
	if err != nil {
		t.Fatal(err)
	}
	if len(keys) != 4 {
		t.Fatalf("rotation throttle keys = %d, want 4", len(keys))
	}
	if err := server.Set(keys[len(keys)-1], "5"); err != nil {
		t.Fatal(err)
	}
	allowed, err := throttle.Allowed(context.Background(), attempt)
	if err != nil || allowed {
		t.Fatalf("previous-key throttle allowed=%v err=%v", allowed, err)
	}
	if err := throttle.Success(context.Background(), attempt); err != nil {
		t.Fatal(err)
	}
	if len(server.Keys()) != 0 {
		t.Fatalf("previous-key throttle state remained: %v", server.Keys())
	}
}
