# Status T05 - English typography polish

**Acceptance.** Every shared English presentation surface uses a professional
Latin system UI stack and a restrained type scale selected by the document
language. Chinese typography and all `.g`/`.e` element, route, action, and form
contracts remain aligned; no Chinese-specific CSS rule changes. The repository-
wide verification matrix passes, and no runtime, deployment, or production state
is changed.

| Item | State | Notes |
|---|---|---|
| T05.1 Polish English typography across all presentation surfaces | `[+]` | Added English-only font, line-height, heading, navigation, table, form, and button sizing to the landing page, manuals, account flows, advertiser/publisher workspaces, and administrator/agent/analyst dashboards. Brought the standalone analyst notice under the shared dashboard style in both editions, preserving parity. Added source-policy assertions for all five shared CSS surfaces and advanced every stylesheet reference to one checked revision so the four-hour edge cache cannot conceal a future rollout. The complete automated verification matrix and bounded source review pass; the owner authorized commit, release construction, and deployment on 2026-08-28. |

## Verification and review

Passed on 2026-08-28 with `GOWORK=off` where applicable:

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
failures; public-data passes; Gitleaks scans 173 commits with no leaks; and the
working-tree whitespace check passes.

A read-only production header check showed `Cache-Control: max-age=14400` on the
shared CSS. Every Chinese and English stylesheet reference therefore advances
to `v=20260828-1`; the copy guard rejects a stale revision. This changes no
Cloudflare setting and requires no cache purge.

Review iteration 1 found that the standalone analyst error page was the only
English HTML document without a stylesheet and therefore retained the browser's
default serif face. Both language twins now load the existing dashboard assets
with matching structure. Iteration 2 found that unchanged asset URLs could hide
the rollout behind the public four-hour CSS cache; all paired references now use
the checked revision. The first full-suite rerun then found four stale rendered-
template expectations, which were updated. Review iteration 3 inspected the
complete candidate and found no remaining P1/P2-or-higher source issue. A local
graphical browser is not installed, so final visual judgment remains an owner
review before any release or deployment authorization.

## Boundaries

- New typography rules are selected only by `lang="en"`; no Chinese-specific
  CSS declaration or rendered copy changes. The formerly unstyled analyst notice
  adopts the shared dashboard shell in both editions to preserve source parity.
- No external web font, JavaScript behavior, template structure, backend code,
  account flow, dependency, database, cache, feature, Cloudflare,
  infrastructure, release, deployment, service restart, or push is part of T05.
- The Pzdesign milestone commit is the T05 delivery unit. The separately
  authorized release construction and W8M deployment retain their own immutable
  Aofei and infrastructure evidence.
