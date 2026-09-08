package summer

import (
	"context"
	"encoding/hex"
	"fmt"
	"net/http"
	"strconv"
	"time"

	"github.com/guruperl/genelet"
	"github.com/mediocregopher/radix/v4"
)

const (
	loginThrottleLimit   = 5
	loginThrottleWindow  = 5 * time.Minute
	loginThrottleTimeout = 2 * time.Second
)

var loginThrottleFailureEval = radix.NewEvalScript(`
local count = redis.call('INCR', KEYS[1])
if count == 1 or redis.call('TTL', KEYS[1]) < 0 then
  redis.call('EXPIRE', KEYS[1], ARGV[1])
end
return count
`)

// RedisLoginThrottle shares login-failure state across service instances. Its
// Redis keys contain only a deployment-keyed digest, never a login or IP.
type RedisLoginThrottle struct {
	redis     radix.Client
	protector *genelet.AccountProtector
}

func NewRedisLoginThrottle(redis radix.Client, protector *genelet.AccountProtector) (*RedisLoginThrottle, error) {
	if redis == nil || protector == nil {
		return nil, fmt.Errorf("shared login throttle requires Redis and account protection")
	}
	return &RedisLoginThrottle{redis: redis, protector: protector}, nil
}

func (t *RedisLoginThrottle) keys(attempt genelet.LoginAttempt) ([]string, error) {
	if attempt.Role == "" || attempt.Provider == "" || len(attempt.IdentifierDigests) == 0 || attempt.ClientIP == "" {
		return nil, fmt.Errorf("incomplete protected login attempt")
	}
	keys := make([]string, 0, len(attempt.IdentifierDigests))
	seen := make(map[string]struct{})
	for _, identifierDigest := range attempt.IdentifierDigests {
		if len(identifierDigest) != 32 {
			return nil, fmt.Errorf("incomplete protected login attempt")
		}
		material := attempt.Role + "\x00" + attempt.Provider + "\x00" + hex.EncodeToString(identifierDigest) + "\x00" + attempt.ClientIP
		digests, err := t.protector.OpaqueDigests("login-throttle", material)
		if err != nil {
			return nil, err
		}
		for _, digest := range digests {
			key := "aofei:login-throttle:v1:{login-throttle}:" + hex.EncodeToString(digest)
			if _, exists := seen[key]; exists {
				continue
			}
			seen[key] = struct{}{}
			keys = append(keys, key)
		}
	}
	return keys, nil
}

func (t *RedisLoginThrottle) Allowed(ctx context.Context, attempt genelet.LoginAttempt) (bool, error) {
	keys, err := t.keys(attempt)
	if err != nil {
		return false, err
	}
	ctx, cancel := context.WithTimeout(ctx, loginThrottleTimeout)
	defer cancel()
	for _, key := range keys {
		var count int
		if err := t.redis.Do(ctx, radix.Cmd(&count, "GET", key)); err != nil {
			return false, err
		}
		if count >= loginThrottleLimit {
			return false, nil
		}
	}
	return true, nil
}

func (t *RedisLoginThrottle) Failure(ctx context.Context, attempt genelet.LoginAttempt) error {
	keys, err := t.keys(attempt)
	if err != nil {
		return err
	}
	ctx, cancel := context.WithTimeout(ctx, loginThrottleTimeout)
	defer cancel()
	var count int
	if err := t.redis.Do(ctx, loginThrottleFailureEval.Cmd(&count, []string{keys[0]}, strconv.FormatInt(int64(loginThrottleWindow/time.Second), 10))); err != nil {
		return err
	}
	if count >= loginThrottleLimit {
		return genelet.Err(http.StatusTooManyRequests, http.StatusText(http.StatusTooManyRequests))
	}
	return nil
}

func (t *RedisLoginThrottle) Success(ctx context.Context, attempt genelet.LoginAttempt) error {
	keys, err := t.keys(attempt)
	if err != nil {
		return err
	}
	ctx, cancel := context.WithTimeout(ctx, loginThrottleTimeout)
	defer cancel()
	return t.redis.Do(ctx, radix.Cmd(nil, "DEL", keys...))
}
