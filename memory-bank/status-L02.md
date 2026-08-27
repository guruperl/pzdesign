# Status L02 - .g/.e structural parity check

**Acceptance.** The new parity tool exits 0 at `HEAD` with its seeded exemption
file. Its tests prove it fails on a synthetic missing `.e` twin and on a twin
whose input `name` set or hidden `action` value differs. The CI step is present
in `.github/workflows/verify.yml`. `GOWORK=off go test ./...` and both existing
template parsers stay green.

| Item | State | Notes |
|---|---|---|
| Add the parity tool with twin-existence checking | `[ ]` | Every `.g` action template at depth three or more must have an `.e` twin. Role-level fragments count too — 7 are currently missing. Follow the existing `tools/check-templates.go` conventions: a `main` that walks a root, prints findings to stderr, and exits non-zero on failure. |
| Extend to form-contract comparison | `[ ]` | For each pair, compare form `action` targets, hidden `action` input values, and the set of input `name` attributes. Compare sets, not order or surrounding markup — the point is that a translated form posts the same thing, not that it looks the same. |
| Seed the exemption file | `[ ]` | List today's 50 gaps (43 action templates, 7 role fragments — admin 30, adv 8, pub 5 among actions) plus any pair that exists but fails the contract comparison. The file is the visible backlog and only ever shrinks; adding an entry needs a stated reason. |
| Wire into `.github/workflows/verify.yml` | `[ ]` | New step after the two template parsers, with `GOWORK=off`. Keep the workflow's existing pinned-dependency and working-directory structure untouched. |
