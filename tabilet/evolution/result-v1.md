# Result v1 - Current state at initialization

Baseline commit `d67ea8ac35b0578db9674bfbb40fede56954cddf`, clean worktree.

## What exists

The Summer admin UI and model layer, its templates and static assets, and the
combined `cmd/unify` HTTP service are complete and green. Twenty-five
component-backed modules are registered, covering advertiser demand, publisher
supply, cross-party access control, marketplace reporting, external demand
integration, and the default-off identity, abuse-protection, management-API,
traffic-quality, and hosted-payment surfaces.

Eleven frozen context archives, `docs/archive-M01.md` through
`docs/archive-M11.md`, record the whole repository at this baseline. All are
`verified`.

## Language state at initialization

- The Genelet **chartag** already selects a language edition: `g` for Chinese and
  `e` for English, both configured `text/html`, resolved as
  `<Template>/<role>/<object>/<action>.<chartag>`. Switching an authenticated
  page's language is already a URL swap.
- Template inventory: 228 `.g` files (171 action templates, 57 role fragments)
  against 178 `.e` files (128 action, 50 fragments). **50 are missing** — 43
  action templates and 7 role fragments, of which admin accounts for 35.
- The `.e` set is not a stale translation but a **divergent legacy design**.
  All 14 public account pages use the current `w8m-account.css` theme in `.g`
  and the older CoreUI design in `.e`. `w8m-account.css` appears in 10 `.g` role
  fragments and 1 `.e`.
- The newest features — security, traffic quality, hosted payment, API and
  publisher credentials, and the analyst ledger — already have genuine,
  structurally parallel `.e` templates.
- Turnstile parity already holds: the bootstrap is present on all four public
  entry pages in both editions.
- `www/index.html` (87 KB, `lang="zh-CN"`) and both manuals are Chinese-only.
- `/` is served by Genelet's `staticPage` through `http.ServeFile` with no
  language negotiation. Nothing reads `Accept-Language`.
- Entry-point URLs hardcode the chartag: `/goto/adv/g/campaign?action=topics`
  and `/goto/pub/g/site?action=topics` appear 14 times each, plus two
  registration links and one agent link.
- `tools/check-public-copy` actively **forbids** `/goto/*/e/` links in Chinese
  pages, which blocks a language toggle until the rule is replaced.
- `README.md` and `docs/rendering-security.md` declare `.e` secondary and
  require only that it stay parse-clean — a policy this direction inverts.

## Verification at this baseline

`go build ./...` succeeds. `go test ./...` reports `ok` for every package with
tests. The template parser reports 171 active `.g` actions and 128 secondary
`.e` actions, both with zero failures. The public-copy check and the public-data
guard both pass.

## Known findings not yet scheduled

None. The three stale `.gitleaks.toml` allowlist entries found during the M11
evidence pass are scheduled as a row in L01.
