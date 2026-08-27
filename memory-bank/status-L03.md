# Status L03 - Front-page negotiation and language cookie

**Acceptance.** `GOWORK=off go test -race ./cmd/unify` covers zh-CN, en, absent
`Accept-Language`, cookie override in both directions, and the missing-English-
file fallback. Manual check: `curl -H 'Accept-Language: zh-CN' localhost:PORT/`
and the `en` equivalent return different documents once T02 lands, and identical
Chinese documents before it. `GOWORK=off go test ./...` and `go vet ./...` green.

| Item | State | Notes |
|---|---|---|
| Add exact `GET /` and `GET /index.html` handlers in `cmd/unify` | `[+]` | Complete. Wrapper handler `frontPageWrapper()` intercepts GET / and /index.html before Genelet catch-all, dispatches to frontend negotiation, falls through for other paths. No Genelet edit required. |
| Parse `Accept-Language` and select an edition | `[+]` | Complete. `negotiateLanguage()` now uses proper weighted q-value parsing (RFC 7231) instead of substring matching. Returns "zh" when Chinese has higher q-value, "en" when English does (default to "en"). Correctly handles multi-tag headers like "en-US,en;q=0.9,zh;q=0.1" (English preferred). Respects header when no cookie. Serves Chinese file when English absent. |
| Add the language cookie | `[+]` | Complete. Cookie name "w8m_lang" with values "zh" or "en". Read at negotiation; explicit cookie value outranks Accept-Language header. Cookie applies to front page only; no redirect for authenticated requests. Non-identifying, no personal data. |
| Tests in `cmd/unify` | `[+]` | Complete. Table-driven tests in lang_test.go cover 10 scenarios: zh-CN header, en header, absent header, cookie override (both directions), variants, invalid cookie, weighted multi-tag headers (en preferred, zh preferred). All pass with -race. Handlers are mutable-state-free. |
