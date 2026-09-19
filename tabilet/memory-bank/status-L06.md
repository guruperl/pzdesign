# Status L06 - Public chartag toggle remediation

**Acceptance.** Every public advertiser and publisher account-flow language
toggle maps Chinese `g` routes to English `e` routes and English `e` routes to
Chinese `g` routes. The current query and fragment survive an interactive
toggle, the literal fallback retains the component and action, and `en`, `zh`,
or `zw` can never enter the route chartag segment. Repository-wide verification
passes without publishing, releasing, deploying, or changing runtime state.

| Item | State | Notes |
|---|---|---|
| L06.1 Correct and guard public account-flow chartag toggles | `[+]` | Owner report on 2026-08-29 identified that `/goto/web/g/pub?action=startnew` generated the broken `/goto/web/en/pub?action=startnew` target. Source inspection confirmed the shared `.g` header stored `en`, the `.e` header stored `zh`, and the footer inserted that language tag into the chartag segment. Shared headers now encode destination chartags `e`/`g`, literal fallbacks retain component and action, and the closed web-only handler retains the full query and fragment. Source and rendered-template guards reject `en`, `zh`, `zw`, the legacy data attribute, incorrect chartag direction, generic-role replacement, and query/fragment loss. Full verification and review pass. |

## Verification and review

Passed on 2026-08-29 with `GOWORK=off` where applicable:

```text
GOWORK=off go build ./...
GOWORK=off go test ./...
GOWORK=off go vet ./...
GOWORK=off go test -race ./cmd/unify
GOWORK=off staticcheck -checks=all,-ST1000,-ST1003,-ST1006 ./...
GOWORK=off go run ./tools/check-templates.go -ext=.g,.e
GOWORK=off go run ./tools/check-parity
GOWORK=off go run ./tools/check-public-copy
./tools/check-public-data.sh
gitleaks git --redact .
git diff --check
```

Observed results: build, unit tests, vet, race tests, and staticcheck pass; all
342 action templates parse with zero failures; parity and public-copy report zero
failures; public-data passes; Gitleaks scans 174 commits with no leaks; and the
working-tree whitespace check passes.

Review iteration 1 found that the English-copy checker allowed Han text beneath
any element carrying the Chinese chartag marker, rather than only the exact
language-toggle anchor, and that the invalid chartag source check assumed a
trailing slash. Both guards were tightened and their negative fixtures added.
Review iteration 2 inspected the complete corrected candidate and found no
remaining P1/P2-or-higher source issue.

## Boundaries

- Route chartags are the closed values `g` and `e`; language labels and metadata
  do not define route values.
- No backend handler, Genelet router, account-flow field, authentication rule,
  dependency, database, cache, feature, Cloudflare, infrastructure, release,
  deployment, service restart, or push is part of L06.
- The Pzdesign milestone commit is the L06 delivery unit.
