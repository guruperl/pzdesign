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
and hidden action values and records exact exceptions for the incomplete
authenticated workspace. The copy guard walks `.g` and `.e`, requires both
public account matrices, parses edition links, and rejects raw framework errors.
Manual acceptance opens `/` with primary browser languages `zh-CN` and `en`,
confirms Chinese moves to `/index.zh.html` while non-Chinese stays on the
English `/`, and confirms literal `/index.html` ↔ `/index.zh.html` links remain
on the selected file. Public account-flow toggles navigate directly to the
opposite chartag; no language cookie, header negotiation, or location-based CDN
rule is involved.
