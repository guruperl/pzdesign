# Status L03 - Front-page negotiation and language cookie

**Acceptance.** `GOWORK=off go test -race ./cmd/unify` covers zh-CN, en, absent
`Accept-Language`, cookie override in both directions, and the missing-English-
file fallback. Manual check: `curl -H 'Accept-Language: zh-CN' localhost:PORT/`
and the `en` equivalent return different documents once T02 lands, and identical
Chinese documents before it. `GOWORK=off go test ./...` and `go vet ./...` green.

| Item | State | Notes |
|---|---|---|
| Add exact `GET /` and `GET /index.html` handlers in `cmd/unify` | `[ ]` | Register ahead of the `/` catch-all that serves the Genelet handler, following the pattern already used for `/healthz`, `/readyz`, and the webhook mount. Genelet's `staticPage` stays unchanged — no edit to `../genelet`. |
| Parse `Accept-Language` and select an edition | `[ ]` | Chinese for a `zh` primary tag in any form (`zh`, `zh-CN`, `zh-Hans`, `zh-TW`); English otherwise, including an absent or unparsable header. Respect quality values. Serve the Chinese file when the English one does not exist, so this row lands safely before T02. |
| Add the language cookie | `[ ]` | Read at negotiation; an explicit value outranks `Accept-Language`. Non-identifying, no personal data, and it must not collide with the Genelet role or session cookie names. The cookie only selects the front page and entry links — never redirects an authenticated request to a different chartag. |
| Tests in `cmd/unify` | `[ ]` | Table-driven over header and cookie combinations, plus the fallback case with the English file absent. The package is the only one CI runs with `-race`, so keep handlers free of shared mutable state. |
