# Tech Stack

## Runtime

Go 1.22 with the 1.23.5 toolchain, module `github.com/guruperl/pzdesign`.
Rendering is Go `html/template`. Storage and messaging are MySQL, Redis, and
NATS, all reached through the Aofei DSP controller rather than configured here.

## Dependencies

Direct: `github.com/guruperl/aofei`, `github.com/guruperl/genelet`,
`github.com/go-sql-driver/mysql`, `github.com/mediocregopher/radix/v4`,
`github.com/nats-io/nats.go`, `go.uber.org/zap`, `golang.org/x/net`.
Test-only: `github.com/DATA-DOG/go-sqlmock`, `github.com/alicebob/miniredis/v2`.

Aofei and Genelet resolve through `replace` to `../aofei` and `../genelet`, so a
working checkout is a three-directory sibling arrangement. CI checks both out at
pinned commits; changing a `ref` in `.github/workflows/verify.yml` is the only
supported way to adopt a new dependency revision, and it is verified in the same
change.

`GOWORK=off` is set on every command so a developer workspace file cannot alter
resolution.

## Commands

```bash
# Build and test
GOWORK=off go build ./...
GOWORK=off go test ./...
GOWORK=off go test -race ./cmd/unify

# Static analysis
GOWORK=off go vet ./...
GOWORK=off go install honnef.co/go/tools/cmd/staticcheck@v0.5.1
GOWORK=off "$(go env GOPATH)/bin/staticcheck" -checks=all,-ST1000,-ST1003,-ST1006 ./...

# Template and copy guards
GOWORK=off go run ./tools/check-templates.go -ext=.g,.e
GOWORK=off go run ./tools/check-templates.go -ext=.g
GOWORK=off go run ./tools/check-templates.go -ext=.e
GOWORK=off go run ./tools/check-public-copy

# Repository data boundary
./tools/check-public-data.sh
gitleaks git --redact .
git diff --check
```

`cmd/unify` tests pin the exact legacy administrator landing redirects and
prove that adjacent methods and paths still reach the Genelet catch-all.
`summer` tests exercise both a real account protector and a typed-nil disabled
adapter so the default-off S07 projection contract cannot regress.

S07 offline identifier tooling reads the owner-readable Summer configuration
and the environment key named by `AccountProtection.Current.KeyEnv`. It prints
counts and numeric row IDs only; `status` validates all retained plaintext
sources, and `backfill` preflights every account table for invalid source data
or partial pairs before any mutation. Rotation authenticates ciphertext and
requires matching current/previous digest provenance. Writes require the
explicit `-write` gate:

```bash
GOWORK=off SUMMER=/owner/readable/summer.json go run ./cmd/account-data -mode=status
GOWORK=off SUMMER=/owner/readable/summer.json go run ./cmd/account-data -mode=backfill -write
GOWORK=off SUMMER=/owner/readable/summer.json go run ./cmd/account-data -mode=verify -limit=100000
```

Activation proofs expire after 24 hours and reset proofs after one hour. Keep
the prior S07 key through that drain window. The application marks proof pages
no-store/no-referrer and redacts its own logs; the exact proxy access-log gate
belongs to the private environment runbook.

Database-backed admin tests need a generated Summer config and skip without one:

```bash
GOWORK=off SUMMER="$PWD/../aofei/etc/summer.local.json" \
  go test ./summer ./summer/pub ./summer/slot ./summer/weight
```

## Running the service

```bash
(cd ../aofei && ./scripts/aofei-local.sh reset-sample)

GOWORK=off SUMMER="$PWD/../aofei/etc/summer.local.json" \
  AOFEI="$PWD/../aofei/etc/aofei.local.json" \
  go run ./cmd/unify
```

The Summer config's `ProjectRoot` must point at this checkout so
`summer/*/component.json` resolves; `Template` points at `tmpls/` and
`DocumentRoot` at `www/`.

## Baseline at initialization

At commit `d67ea8ac35b0578db9674bfbb40fede56954cddf` the whole pipeline passes:
build succeeds, all packages with tests report `ok`, the template parser reports
171 active `.g` actions and 128 secondary `.e` actions with zero failures, the
public-copy check reports zero failures, and the public-data guard passes.

## Language harnesses

The `.g`/`.e` structural parity check and both language arms of the public-copy
checker are active release gates. The parity guard compares parsed field names
and hidden action values, the full element/action structure, twin completeness,
and the absence of untranslated Chinese copy in English templates. It rejects
stale exemptions, and the authenticated workspace now needs none. The copy guard
walks `.g` and `.e`, requires both public account matrices, parses edition links,
and rejects raw framework errors. English typography is implemented without a
font download or new dependency: the five shared CSS surfaces select the host
platform's UI sans-serif stack under `html[lang="en"]`. The copy checker pins
those selectors and the principal English size and line-height values while the
parity checker continues to protect the shared HTML structure.
Manual acceptance opens `/` with primary browser languages `zh-CN` and `en`,
confirms Chinese moves to `/index.zh.html` while non-Chinese stays on the
English `/`, and confirms literal `/index.html` ↔ `/index.zh.html` links remain
on the selected file. Public account-flow toggles navigate directly to the
opposite chartag; no language cookie, header negotiation, or location-based CDN
rule is involved.

The public-copy checker also treats the four static legal documents as release
inputs. It pins their effective-date and core Google/user-data disclosures,
requires reciprocal `hreflang`, compares the ordered legal section IDs, and
requires language-correct Privacy and Terms links on public footers and both
advertiser/publisher registration forms. This is a structural and copy
regression gate, not legal approval or evidence that the URLs are deployed.
