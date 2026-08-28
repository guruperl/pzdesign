# Status L05 - English surface review remediation

State: `[+]` Complete on 2026-08-27. The owner authorized the verified closeout
commit after review. This remediation was approved after a review of the
completed L01-L04/T01-T03 horizon. It does not reopen completed history; it owns
the newly confirmed defects.

Post-close owner correction on 2026-08-27: the two front-page language links
target the literal sibling files `/index.html` and `/index.en.html`. Only `/`
negotiates; an opposite cookie or browser language cannot rewrite either named
file. Handler and public-copy regressions preserve that distinction.

## Review disposition

| Finding | Local severity | Disposition |
|---|---|---|
| Global workspace toggles can enter one of 72 missing `.e` templates | P1 | Confirmed. Keep the completed public/account English surface, but remove authenticated-workspace toggles until the next translation horizon closes every reachable twin. |
| Language preference is read but never written; negotiated responses are not cache-safe | P2 | Confirmed. Persist only the non-identifying `w8m_lang` preference from explicit toggles and emit exact variance/content-language headers with handler coverage. |
| The English copy/link guard does not inspect `.e` templates and treats regex syntax as literal text | P2 | Confirmed. Make file edition explicit, parse HTML links, enforce opposite-edition links only in real toggle/alternate elements, and add adversarial tests. |
| Hidden `action` parity is dead code | P2 | Confirmed. Parse field contracts independent of quoting/order, compare hidden action values, and prove rejection in tests. |
| Diff, static-analysis, secret-scan, and generated-binary hygiene gates fail | P2 | Confirmed. Normalize the two edited CRLF templates, use exact historical Gitleaks fingerprints, ignore local build output, and rerun every release gate. |
| Current Aofei includes a separately operated schema migration | Operational boundary | Valid but not a Pzdesign defect. No deployment or migration belongs to L05; production remains on the selected immutable release. |

## Task ledger

| Item | State | Notes |
|---|---|---|
| L05.1 Reconcile the shipped language boundary | `[+]` | Authenticated role headers no longer expose a global toggle; only the complete public `web` account surface retains it. The static front page, manuals, and public advertiser/publisher account flows remain bilingual. Product, architecture, README, rendering-security, tech-stack, and milestone truth now identify the 205-file authenticated workspace as a later reviewed horizon. |
| L05.2 Make preference and negotiation behavior durable | `[+]` | Explicit public choices persist a `Secure`, `HttpOnly`, `SameSite=Lax` `w8m_lang` cookie; negotiated pages declare exact variance, private/no-cache policy, and actual content language. Redirect returns are limited to the chosen public chartag subtree. Handler tests cover negotiation weights (including zero/malformed values), cookie precedence/write, fallback, cache headers, exact routes, safe/unsafe returns, and fallthrough. |
| L05.3 Close copy and parity guard gaps | `[+]` | The copy guard walks both template editions, requires both nine-action public matrices, applies edition rules, rejects direct/pipelined raw framework errors, parses links and exact toggle/alternate metadata, and checks both front-page structures plus reciprocal `hreflang`. Nine exposed English login/error paths now emit fixed guidance rather than backend messages. The parity guard parses form controls and hidden actions independent of quoting/order; one real advertiser field drift was repaired and four deferred authenticated mutations have exact documented action exceptions. |
| L05.4 Restore repository release hygiene | `[+]` | Root `/bin/` is ignored without deleting the local executable, four reviewed historical/synthetic Gitleaks findings are pinned by exact fingerprint, edited advertiser layouts use LF with clean indentation, staticcheck is clean, and both Gitleaks and `git diff --check` pass. |
| L05.5 Verify and deep-review the remediation | `[+]` | The full matrix below passes. Review iteration 1 confirmed the intake findings. Iteration 2 found raw English error rendering, unacceptable/malformed language-weight handling, and unenforced English landing-page/hreflang structure; all were fixed with regressions. Iteration 3 reviewed the complete diff and found no remaining P1/P2-or-higher issue. |

## Verification

Passed on 2026-08-27 with `GOWORK=off` where applicable:

```text
go build ./...
go test ./...
go vet ./...
go test -race ./cmd/unify
staticcheck -checks=all,-ST1000,-ST1003,-ST1006 ./...
go run ./tools/check-templates.go -ext=.g,.e
go run ./tools/check-parity
go run ./tools/check-public-copy
./tools/check-public-data.sh
gitleaks git --redact .
git diff --check
```

Observed guard results: 299 templates and zero template failures, zero parity
failures, zero public-copy failures, public-data passed, 169 commits scanned by
Gitleaks with no leaks.

## Boundaries

- No Aofei schema change, migration, cache rebuild, feature activation,
  Cloudflare mutation, deployment, service restart, or push is part of L05.
- English public registration remains an authoring/rendering surface; this
  milestone does not submit a registration or alter account policy.
- The untracked local executable is never a release input. Production builds
  continue to use the clean, published, provenance-bound Aofei release builder.

## Commit handling

The owner authorized the already-integrated, fully verified L05 working tree as
one closeout commit on 2026-08-27. Future milestone work resumes the normal
one-row-per-commit cadence. No push was authorized.
