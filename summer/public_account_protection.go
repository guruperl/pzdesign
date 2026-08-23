package summer

import (
	"context"
	"crypto/hmac"
	"crypto/sha256"
	"encoding/hex"
	"encoding/json"
	"errors"
	"expvar"
	"fmt"
	"io"
	"net/http"
	"net/mail"
	"net/netip"
	"net/url"
	"os"
	"strconv"
	"strings"
	"time"

	"github.com/guruperl/genelet"
	"github.com/mediocregopher/radix/v4"
)

const (
	PublicAccountProtectorStorageKey = "PublicAccountProtector"
	turnstileVerifyURL               = "https://challenges.cloudflare.com/turnstile/v0/siteverify"
	turnstileTokenLimit              = 2048
	turnstileResponseLimit           = 64 << 10
	publicAccountRedisTimeout        = 2 * time.Second
)

var (
	publicAccountSubmissions  = expvar.NewMap("aofei_public_account_submissions_total")
	publicAccountTurnstile    = expvar.NewMap("aofei_public_account_turnstile_rejections_total")
	publicAccountRateLimited  = expvar.NewMap("aofei_public_account_rate_limited_total")
	publicAccountDependencies = expvar.NewMap(
		"aofei_public_account_dependency_errors_total",
	)
)

type publicAccountLimit struct {
	scope  string
	limit  int
	window time.Duration
}

type publicAccountProtectionConfig struct {
	siteKey        string
	secretKey      string
	hostnames      map[string]struct{}
	trustedProxies []netip.Prefix
	limits         []publicAccountLimit
	verifyURL      string
}

// PublicAccountProtector validates Cloudflare Turnstile tokens and applies
// privacy-preserving Redis quotas before public registration or recovery work.
// It is immutable after construction and safe for concurrent requests.
type PublicAccountProtector struct {
	config publicAccountProtectionConfig
	redis  radix.Client
	client *http.Client
}

type turnstileResponse struct {
	Success    bool     `json:"success"`
	Hostname   string   `json:"hostname"`
	Action     string   `json:"action"`
	ErrorCodes []string `json:"error-codes"`
}

type publicAccountHumanContextKey struct{}

var publicAccountQuotaScript = `
for i = 1, #KEYS do
  local current = tonumber(redis.call('GET', KEYS[i]) or '0')
  local limit = tonumber(ARGV[(i - 1) * 2 + 1])
  if current >= limit then
    return -i
  end
end
for i = 1, #KEYS do
  local count = redis.call('INCR', KEYS[i])
  if count == 1 or redis.call('TTL', KEYS[i]) < 0 then
    redis.call('EXPIRE', KEYS[i], ARGV[(i - 1) * 2 + 2])
  end
end
return 1
`

// NewPublicAccountProtectorFromEnv returns nil when protection is explicitly
// disabled. Enabling is fail-closed: Turnstile, Redis, hostname, proxy, and
// quota configuration must all be valid before the service can start.
func NewPublicAccountProtectorFromEnv(redis radix.Client) (*PublicAccountProtector, error) {
	enabledValue := strings.TrimSpace(os.Getenv("PUBLIC_ACCOUNT_PROTECTION_ENABLED"))
	enabled := false
	if enabledValue != "" {
		parsed, err := strconv.ParseBool(enabledValue)
		if err != nil {
			return nil, fmt.Errorf("PUBLIC_ACCOUNT_PROTECTION_ENABLED must be true or false")
		}
		enabled = parsed
	}
	if !enabled {
		if strings.TrimSpace(os.Getenv("TURNSTILE_SITE_KEY")) != "" ||
			strings.TrimSpace(os.Getenv("TURNSTILE_SECRET_KEY")) != "" {
			return nil, fmt.Errorf("turnstile credentials require PUBLIC_ACCOUNT_PROTECTION_ENABLED=true")
		}
		return nil, nil
	}
	if redis == nil {
		return nil, fmt.Errorf("public account protection requires Redis")
	}

	hostnames, err := parsePublicAccountHostnames(os.Getenv("TURNSTILE_HOSTNAMES"))
	if err != nil {
		return nil, err
	}
	trusted, err := parseTrustedProxyCIDRs(os.Getenv("PUBLIC_ACCOUNT_TRUSTED_PROXY_CIDRS"))
	if err != nil {
		return nil, err
	}
	limits, err := publicAccountLimitsFromEnv()
	if err != nil {
		return nil, err
	}
	config := publicAccountProtectionConfig{
		siteKey:        strings.TrimSpace(os.Getenv("TURNSTILE_SITE_KEY")),
		secretKey:      strings.TrimSpace(os.Getenv("TURNSTILE_SECRET_KEY")),
		hostnames:      hostnames,
		trustedProxies: trusted,
		limits:         limits,
		verifyURL:      turnstileVerifyURL,
	}
	if config.siteKey == "" || config.secretKey == "" {
		return nil, fmt.Errorf("public account protection requires Turnstile site and secret keys")
	}
	return newPublicAccountProtector(config, redis, &http.Client{Timeout: 5 * time.Second})
}

func newPublicAccountProtector(config publicAccountProtectionConfig, redis radix.Client, client *http.Client) (*PublicAccountProtector, error) {
	if config.siteKey == "" || config.secretKey == "" || len(config.hostnames) == 0 ||
		len(config.trustedProxies) == 0 || len(config.limits) == 0 || config.verifyURL == "" ||
		redis == nil || client == nil {
		return nil, fmt.Errorf("incomplete public account protection configuration")
	}
	return &PublicAccountProtector{config: config, redis: redis, client: client}, nil
}

func parsePublicAccountHostnames(raw string) (map[string]struct{}, error) {
	result := make(map[string]struct{})
	for _, value := range strings.Split(raw, ",") {
		hostname := strings.ToLower(strings.TrimSpace(value))
		if hostname == "" {
			continue
		}
		if strings.ContainsAny(hostname, "/: ") || strings.HasPrefix(hostname, ".") || strings.HasSuffix(hostname, ".") {
			return nil, fmt.Errorf("TURNSTILE_HOSTNAMES contains an invalid hostname")
		}
		result[hostname] = struct{}{}
	}
	if len(result) == 0 {
		return nil, fmt.Errorf("TURNSTILE_HOSTNAMES must contain at least one hostname")
	}
	return result, nil
}

func parseTrustedProxyCIDRs(raw string) ([]netip.Prefix, error) {
	result := make([]netip.Prefix, 0)
	for _, value := range strings.Split(raw, ",") {
		value = strings.TrimSpace(value)
		if value == "" {
			continue
		}
		prefix, err := netip.ParsePrefix(value)
		if err != nil {
			address, addressErr := netip.ParseAddr(value)
			if addressErr != nil {
				return nil, fmt.Errorf("PUBLIC_ACCOUNT_TRUSTED_PROXY_CIDRS contains an invalid address or CIDR")
			}
			prefix = netip.PrefixFrom(address.Unmap(), address.BitLen())
		}
		result = append(result, prefix.Masked())
	}
	if len(result) == 0 {
		return nil, fmt.Errorf("PUBLIC_ACCOUNT_TRUSTED_PROXY_CIDRS must contain at least one trusted proxy")
	}
	return result, nil
}

func publicAccountLimitsFromEnv() ([]publicAccountLimit, error) {
	type limitSetting struct {
		env    string
		scope  string
		value  int
		window time.Duration
	}
	settings := []limitSetting{
		{"PUBLIC_ACCOUNT_IP_10M_LIMIT", "ip_10m", 10, 10 * time.Minute},
		{"PUBLIC_ACCOUNT_IP_DAY_LIMIT", "ip_day", 50, 24 * time.Hour},
		{"PUBLIC_ACCOUNT_EMAIL_HOUR_LIMIT", "email_hour", 5, time.Hour},
		{"PUBLIC_ACCOUNT_EMAIL_DAY_LIMIT", "email_day", 20, 24 * time.Hour},
		{"PUBLIC_ACCOUNT_GLOBAL_HOUR_LIMIT", "global_hour", 200, time.Hour},
		{"PUBLIC_ACCOUNT_GLOBAL_DAY_LIMIT", "global_day", 1000, 24 * time.Hour},
	}
	limits := make([]publicAccountLimit, 0, len(settings))
	for _, setting := range settings {
		value := setting.value
		if raw := strings.TrimSpace(os.Getenv(setting.env)); raw != "" {
			parsed, err := strconv.Atoi(raw)
			if err != nil || parsed <= 0 || parsed > 1_000_000 {
				return nil, fmt.Errorf("%s must be between 1 and 1000000", setting.env)
			}
			value = parsed
		}
		limits = append(limits, publicAccountLimit{scope: setting.scope, limit: value, window: setting.window})
	}
	return limits, nil
}

func publicAccountPurpose(role, object, action string) (string, bool) {
	if role != "web" || (object != "adv" && object != "pub") {
		return "", false
	}
	switch action {
	case "insert":
		return "register_" + object, true
	case "retrieve":
		return "recover_" + object, true
	default:
		return "", false
	}
}

func storedPublicAccountProtector(storage map[string]interface{}) (*PublicAccountProtector, error) {
	if storage == nil {
		return nil, nil
	}
	raw, ok := storage[PublicAccountProtectorStorageKey]
	if !ok || raw == nil {
		return nil, nil
	}
	protector, ok := raw.(*PublicAccountProtector)
	if !ok {
		return nil, fmt.Errorf("%s has type %T, want *summer.PublicAccountProtector", PublicAccountProtectorStorageKey, raw)
	}
	return protector, nil
}

// VerifyPublicAccountHuman validates the one-time Turnstile token before
// password hashing, database access, Gmail credential checks, or Redis work.
func VerifyPublicAccountHuman(storage map[string]interface{}, request *http.Request, role, object, action string) error {
	purpose, protected := publicAccountPurpose(role, object, action)
	if !protected {
		return nil
	}
	protector, err := storedPublicAccountProtector(storage)
	if err != nil {
		return genelet.Err(http.StatusServiceUnavailable, "账户服务保护配置异常，请稍后再试。")
	}
	if protector == nil {
		return nil
	}
	publicAccountSubmissions.Add(purpose, 1)
	return protector.verify(request, purpose)
}

// AdmitPublicAccountSubmission atomically consumes the public-form Redis
// quotas after normal form validation and before database or Gmail work.
func AdmitPublicAccountSubmission(storage map[string]interface{}, request *http.Request, config *genelet.Config, role, object, action string) error {
	purpose, protected := publicAccountPurpose(role, object, action)
	if !protected {
		return nil
	}
	protector, err := storedPublicAccountProtector(storage)
	if err != nil {
		return genelet.Err(http.StatusServiceUnavailable, "账户服务保护配置异常，请稍后再试。")
	}
	if protector == nil {
		return nil
	}
	validatedPurpose, _ := request.Context().Value(publicAccountHumanContextKey{}).(string)
	if validatedPurpose != purpose {
		return genelet.Err(http.StatusBadRequest, "人机验证已失效，请刷新页面后重试。")
	}
	return protector.admit(request, config, purpose)
}

// AddPublicAccountProtectionView exposes only the public widget site key and a
// fixed action. The secret key never enters template data.
func AddPublicAccountProtectionView(other map[string]interface{}, storage map[string]interface{}, role, object, action string) error {
	if role != "web" || (action != "startnew" && action != "startretrieve") {
		return nil
	}
	submissionAction := "insert"
	if action == "startretrieve" {
		submissionAction = "retrieve"
	}
	purpose, protected := publicAccountPurpose(role, object, submissionAction)
	if !protected {
		return nil
	}
	protector, err := storedPublicAccountProtector(storage)
	if err != nil {
		return err
	}
	if protector == nil {
		return nil
	}
	other["TurnstileSiteKey"] = protector.config.siteKey
	other["TurnstileAction"] = purpose
	return nil
}

func (protector *PublicAccountProtector) verify(request *http.Request, purpose string) error {
	token := strings.TrimSpace(request.Form.Get("cf-turnstile-response"))
	request.Form.Del("cf-turnstile-response")
	if token == "" || len(token) > turnstileTokenLimit {
		publicAccountTurnstile.Add(purpose, 1)
		return genelet.Err(http.StatusBadRequest, "请完成人机验证后再提交。")
	}
	clientIP, err := protector.clientIP(request)
	if err != nil {
		publicAccountTurnstile.Add(purpose, 1)
		return genelet.Err(http.StatusBadRequest, "无法确认请求来源，请刷新页面后重试。")
	}
	form := url.Values{
		"secret":   {protector.config.secretKey},
		"response": {token},
	}
	if clientIP.IsValid() {
		form.Set("remoteip", clientIP.String())
		request.Form.Set("ip", clientIP.String())
	}
	verifyRequest, err := http.NewRequestWithContext(request.Context(), http.MethodPost, protector.config.verifyURL, strings.NewReader(form.Encode()))
	if err != nil {
		publicAccountDependencies.Add("turnstile", 1)
		return genelet.Err(http.StatusServiceUnavailable, "人机验证服务暂时不可用，请稍后再试。")
	}
	verifyRequest.Header.Set("Content-Type", "application/x-www-form-urlencoded")
	response, err := protector.client.Do(verifyRequest)
	if err != nil {
		publicAccountDependencies.Add("turnstile", 1)
		return genelet.Err(http.StatusServiceUnavailable, "人机验证服务暂时不可用，请稍后再试。")
	}
	defer response.Body.Close()
	if response.StatusCode != http.StatusOK {
		_, _ = io.Copy(io.Discard, io.LimitReader(response.Body, turnstileResponseLimit))
		publicAccountDependencies.Add("turnstile", 1)
		return genelet.Err(http.StatusServiceUnavailable, "人机验证服务暂时不可用，请稍后再试。")
	}
	body, err := io.ReadAll(io.LimitReader(response.Body, turnstileResponseLimit+1))
	if err != nil || len(body) > turnstileResponseLimit {
		publicAccountDependencies.Add("turnstile", 1)
		return genelet.Err(http.StatusServiceUnavailable, "人机验证服务暂时不可用，请稍后再试。")
	}
	var result turnstileResponse
	if err := json.Unmarshal(body, &result); err != nil {
		publicAccountDependencies.Add("turnstile", 1)
		return genelet.Err(http.StatusServiceUnavailable, "人机验证服务暂时不可用，请稍后再试。")
	}
	hostname := strings.ToLower(strings.TrimSuffix(strings.TrimSpace(result.Hostname), "."))
	_, hostnameAllowed := protector.config.hostnames[hostname]
	if !result.Success || !hostnameAllowed || result.Action != purpose {
		publicAccountTurnstile.Add(purpose, 1)
		return genelet.Err(http.StatusBadRequest, "人机验证未通过，请刷新页面后重试。")
	}
	*request = *request.WithContext(context.WithValue(request.Context(), publicAccountHumanContextKey{}, purpose))
	return nil
}

func (protector *PublicAccountProtector) admit(request *http.Request, config *genelet.Config, purpose string) error {
	email, err := normalizePublicAccountEmail(request.Form.Get("email"))
	if err != nil {
		return genelet.Err(http.StatusBadRequest, "请输入有效的电子邮箱。")
	}
	clientIP, err := protector.clientIP(request)
	if err != nil || !clientIP.IsValid() {
		return genelet.Err(http.StatusBadRequest, "无法确认请求来源，请刷新页面后重试。")
	}
	if config == nil || strings.TrimSpace(config.Secret) == "" {
		publicAccountDependencies.Add("config", 1)
		return genelet.Err(http.StatusServiceUnavailable, "账户服务保护配置异常，请稍后再试。")
	}

	emailDigest := publicAccountDigest(config.Secret, "email", email)
	ipDigest := publicAccountDigest(config.Secret, "ip", clientIP.String())
	keys := make([]string, 0, len(protector.config.limits))
	args := make([]string, 0, len(protector.config.limits)*2)
	for _, limit := range protector.config.limits {
		identity := "global"
		switch {
		case strings.HasPrefix(limit.scope, "email_"):
			identity = emailDigest
		case strings.HasPrefix(limit.scope, "ip_"):
			identity = ipDigest
		}
		keys = append(keys, "aofei:public-account:v1:{public-account}:"+limit.scope+":"+identity)
		args = append(args, strconv.Itoa(limit.limit), strconv.FormatInt(int64(limit.window/time.Second), 10))
	}
	command := []string{"EVAL", publicAccountQuotaScript, strconv.Itoa(len(keys))}
	command = append(command, keys...)
	command = append(command, args...)
	ctx, cancel := context.WithTimeout(request.Context(), publicAccountRedisTimeout)
	defer cancel()
	var result int64
	if err := protector.redis.Do(ctx, radix.Cmd(&result, command[0], command[1:]...)); err != nil {
		publicAccountDependencies.Add("redis", 1)
		return genelet.Err(http.StatusServiceUnavailable, "账户服务保护暂时不可用，请稍后再试。")
	}
	if result < 0 {
		index := int(-result) - 1
		scope := "unknown"
		if index >= 0 && index < len(protector.config.limits) {
			scope = protector.config.limits[index].scope
		}
		publicAccountRateLimited.Add(scope, 1)
		return genelet.Err(http.StatusTooManyRequests, "提交过于频繁，请稍后再试；如需帮助请联系 support@w8m.com。")
	}
	publicAccountSubmissions.Add(purpose+"_admitted", 1)
	return nil
}

func normalizePublicAccountEmail(value string) (string, error) {
	normalized := strings.ToLower(strings.TrimSpace(value))
	if normalized == "" || len(normalized) > 320 {
		return "", errors.New("invalid email")
	}
	address, err := mail.ParseAddress(normalized)
	if err != nil || strings.ToLower(address.Address) != normalized {
		return "", errors.New("invalid email")
	}
	return normalized, nil
}

func publicAccountDigest(secret, namespace, value string) string {
	digest := hmac.New(sha256.New, []byte(secret))
	_, _ = digest.Write([]byte("public-account-v1\x00" + namespace + "\x00" + value))
	return hex.EncodeToString(digest.Sum(nil))
}

func (protector *PublicAccountProtector) clientIP(request *http.Request) (netip.Addr, error) {
	peer, err := parseRemoteAddress(request.RemoteAddr)
	if err != nil {
		return netip.Addr{}, err
	}
	if !protector.trustedProxy(peer) {
		return peer, nil
	}
	chain := make([]netip.Addr, 0)
	for _, header := range request.Header.Values("X-Forwarded-For") {
		for _, raw := range strings.Split(header, ",") {
			address, err := netip.ParseAddr(strings.TrimSpace(raw))
			if err != nil {
				return netip.Addr{}, fmt.Errorf("invalid X-Forwarded-For address")
			}
			chain = append(chain, address.Unmap())
		}
	}
	chain = append(chain, peer)
	for index := len(chain) - 1; index >= 0; index-- {
		if !protector.trustedProxy(chain[index]) {
			return chain[index], nil
		}
	}
	if len(chain) > 0 {
		return chain[0], nil
	}
	return peer, nil
}

func parseRemoteAddress(value string) (netip.Addr, error) {
	value = strings.TrimSpace(value)
	if address, err := netip.ParseAddr(value); err == nil {
		return address.Unmap(), nil
	}
	addressPort, err := netip.ParseAddrPort(value)
	if err == nil {
		return addressPort.Addr().Unmap(), nil
	}
	return netip.Addr{}, fmt.Errorf("invalid remote address")
}

func (protector *PublicAccountProtector) trustedProxy(address netip.Addr) bool {
	for _, prefix := range protector.config.trustedProxies {
		if prefix.Contains(address) {
			return true
		}
	}
	return false
}
