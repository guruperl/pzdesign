# Status T04 - Authenticated workspace English completion

**Acceptance.** Every Chinese `.g` template has a complete English `.e` twin
derived from the same element tree, functional attributes, form fields, hidden
actions, and template actions. English templates contain no untranslated Chinese
copy outside the intentional public `中文` toggle. The parity exemption ledger is
empty, the complete repository verification matrix passes, and no runtime,
deployment, or production state is changed.

| Item | State | Notes |
|---|---|---|
| T04.1 Translate and align the complete English template surface | `[+]` | Rebuilt all advertiser, publisher, administrator, agent, analyst, and structurally stale public English templates from their Chinese twins; added every missing authenticated twin and the English targeting dictionaries; strengthened parity to compare the full template tree and structure, reject untranslated Chinese copy and stale exemptions, and closed the exemption ledger. All verification and the bounded review pass; the owner authorized commit, release construction, and deployment on 2026-08-28. |

## Verification and review

Passed on 2026-08-28 with `GOWORK=off` where applicable:

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

Observed results: all 228 Chinese templates have English twins; 342 action
templates parse with zero failures; parity, public-copy, and public-data guards
report zero failures; static analysis, race tests, secret-history scanning, and
whitespace checks pass.

Review iteration 1 found that the historical parity walker skipped role-level
fragments and therefore missed nine stale English headers, footers, and shared
controls. The walker and fragments were fixed. Iteration 2 found two remaining
English publisher slot pages bound to the Chinese attribute dictionary; both now
use the English dictionary. Iteration 3 reviewed the complete source-of-truth
diff and found no remaining P1/P2-or-higher issue. The prepublication
commit-range whitespace gate then found one trailing blank line in a previously
untracked English template; it was removed, and iteration 4 found no remaining
P1/P2-or-higher issue.

## Boundaries

- Chinese `.g` templates remain the source of truth; no Chinese template was
  rewritten to accommodate its English twin.
- No account was created, no registration or authenticated workflow was run,
  and no database, cache, dependency, feature, Cloudflare, or infrastructure
  state was changed.
- The Pzdesign milestone commit is the T04 delivery unit. The subsequently
  authorized release construction and production deployment remain separate
  Aofei and W8M-infrastructure operations with their own immutable evidence.
