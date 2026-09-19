# Archive M01 - Module Boundary, Dependencies, And Repository Verification

**Context.** Ownership of the `github.com/guruperl/pzdesign` module as a
publishable unit: its identity, its sibling-module dependency topology, the
verification pipeline that gates every change, and the public-data boundary that
keeps this a shareable repository.

**Baseline.** `d67ea8ac35b0578db9674bfbb40fede56954cddf`

**Coverage.** verified

**Supersedes.** none

## Scope And Responsibilities

This context owns the module manifest, the dependency pinning strategy, the CI
workflow, the repository-wide guard scripts, the security-reporting policy, and
the set of long-form maintenance documents that other contexts must keep
current.

It excludes the behavior those checks verify. Rendering and copy policy belong
to M11, service composition to M02, and the component contract to M03. It also
excludes everything inside the sibling Aofei and Genelet modules, which are
external contexts reached through `replace` directives.

## Domain And Workflows

The module is one of three checkouts that must sit side by side. `pzdesign`
holds the Summer admin UI/model layer, templates, and static assets. `aofei`
holds the DSP controller, MySQL schema, accounting, and the authoritative
product contracts. `genelet` holds the web framework. Local development resolves
the two dependencies through `replace ... => ../aofei` and `=> ../genelet`, so a
developer checkout is only valid as a sibling arrangement.

Because those replaces point at moving local branches, CI cannot rely on them.
The workflow instead checks out both dependencies by explicit commit, so a
change in a dependency branch can never silently change pzdesign verification.
Adopting a new dependency revision is therefore a deliberate edit to the
workflow `ref` values, verified in the same change.

The repository is public. The standing invariant is that templates, assets,
tests, and examples carry no live account details, runtime logs, uploaded
customer media, production paths, or secrets. Exposure is handled by rotating
the credential first; deleting it in a later commit does not make the earlier
public value safe.

## System Shape

- `go.mod` declares module `github.com/guruperl/pzdesign`, Go 1.22 with the
  1.23.5 toolchain, and direct requirements on `aofei`, `genelet`, the MySQL
  driver, `radix/v4`, `nats.go`, `zap`, and `golang.org/x/net`. Test-only
  dependencies are `go-sqlmock` and `miniredis/v2`.
- `.github/workflows/verify.yml` runs on pushes to `master` and on pull
  requests, with in-progress cancellation, `contents: read` permission, and all
  steps executed from the `pzdesign` working directory beside the two
  dependency checkouts.
- `tools/check-public-data.sh` is a self-contained bash guard run from the
  repository root by CI and by contributors.
- `.gitleaks.toml` extends the default rule set and allowlists only paths that
  are not repository inputs: `logs/`, `www/uploads/`, and three vendored
  minified JavaScript files.
- `docs/` holds four maintenance contracts: the Genelet framework manual, the
  Summer UI structure reference, the rendering-security contract, and the
  public Chinese content guide.

## Contracts And Dependencies

The verification pipeline is the module's outward contract. In workflow order it
runs `go test ./...`, race tests on `./cmd/unify`, `go vet ./...`, staticcheck
with `all` minus the legacy `ST1000`, `ST1003`, and `ST1006` style exclusions,
the active-template parser, the English-template parser, the public Chinese copy
check, the public-data guard, a pinned Gitleaks v8.27.2 history scan, and a
committed whitespace check over the pull-request merge base to head or the push
before-to-after range. Every step sets `GOWORK=off` so a developer workspace
file cannot alter resolution.

Gitleaks is pinned at v8.27.2 specifically so `go install` stays compatible with
the workflow's Go 1.23.5 toolchain.

The public-data guard rejects AWS access-key identifiers, private key material,
a private home path, personal CSS identifiers, customer email domains, retired
customer exchange domains, and any tracked file under `logs/`, `www/uploads/`,
or with a `.docx` extension. The patterns are themselves split across string
concatenations so the guard does not trip on its own source.

`SECURITY.md` directs vulnerability reports to GitHub private vulnerability
reporting rather than public issues.

## Operations And Verification

At this baseline the full local pipeline passes on a clean worktree:
`go build ./...` succeeds, `go test ./...` reports `ok` for all twenty-three
packages with test files and `[no test files]` for eight, the template parser
reports 171 active `.g` actions and 128 secondary `.e` actions with zero
failures, the public-copy check reports zero failures, and the public-data guard
passes. Database-backed tests are present but degrade to skips without a
`SUMMER` configuration, so this local run exercises the non-database paths.

`.gitignore` keeps `logs/`, `www/coreui`, `www/uploads`, and several scratch
HTML files out of the tree.

## Evidence

| Claim | Repository Evidence |
|---|---|
| Module identity, Go/toolchain versions, and direct dependency set. | `go.mod:1-32` |
| Local development resolves Aofei and Genelet as sibling checkouts. | `go.mod:31-33` |
| CI pins both dependencies to explicit commits rather than branches. | `.github/workflows/verify.yml:26-37` |
| The verification pipeline order and its `GOWORK=off` discipline. | `.github/workflows/verify.yml:46-72` |
| Staticcheck keeps three named legacy style exclusions. | `.github/workflows/verify.yml:57-60` |
| Gitleaks is pinned to v8.27.2 for toolchain compatibility. | `.github/workflows/verify.yml:73-78`, `README.md` |
| Whitespace hygiene is checked over the committed PR or push range. | `.github/workflows/verify.yml:79-98` |
| The public-data guard's forbidden patterns and tracked-path rules. | `tools/check-public-data.sh:18-30` |
| Secret scanning allowlists only non-input paths. | `.gitleaks.toml:5-14` |
| Vulnerability reporting is private, and rotation precedes removal. | `SECURITY.md:3-18` |
| The four maintenance contracts other contexts must keep current. | `docs/genelet-manual.md`, `docs/summer-ui-structure.md`, `docs/rendering-security.md`, `docs/public-chinese-content-guide.md` |

## Observed Gaps

The MySQL schema, deployment manifests, and runtime configuration are not in
this repository; the checked-in examples they pair with live under
`../aofei/etc/`. No in-repo evidence establishes which dependency commits are
deployed in production, only which are pinned for verification.
