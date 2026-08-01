# pzdesign

`pzdesign` is the Go module `github.com/guruperl/pzdesign`. It owns the
Summer admin packages, UI templates, and static assets used by the sibling
Aofei/Winter DSP checkout. It depends on the external Genelet framework module
`github.com/guruperl/genelet`.

## Layout

- `docs/` contains Genelet framework and Summer module maintenance references.
- `tmpls/` contains Go `html/template` files arranged as
  `tmpls/<role>/<object>/<action>.g`.
- `cmd/unify/` contains the combined Summer/Genelet admin and Aofei DSP HTTP
  service command.
- `summer/` contains admin UI models, filters, component JSON, registry code,
  and module tests.
- `tmpls/<role>/*.g` contains shared role-level layout fragments such as
  headers, sidebars, and footers.
- `*.g` templates are the active UI templates.
- `*.e` templates are English variants kept parse-clean where practical, but
  they are not the primary runtime surface.
- `www/` is the static document root used by the UI templates.
- `tools/check-templates.go` parses the templates with Go's `html/template`
  package and catches syntax errors.

## Static Assets

Runtime asset groups under `www/`:

- `sb2/` contains the SB Admin 2 assets referenced by advertiser templates.
- `admin/` contains Bootstrap admin assets referenced by admin and agent
  templates.
- `1.0.8/` contains publisher and web console assets.
- `css/`, `js/`, `img/`, and `vendor/` support the public landing page and
  legacy creative/demo pages.
- `www/css/w8m-account.css` is the shared public registration/login theme:
  advertiser entry pages use the landing page's coral role color and publisher
  entry pages use its teal role color. Keep authenticated dashboard styling
  separate from this public account surface.
- `manuals/` contains the public Chinese advertiser/agency and
  publisher/supply-side web manuals.
  Their operational content follows the sibling Aofei references
  `docs/advertiser-dsp-agent-manual.zh-CN.md` and
  `docs/publisher-manual.zh-CN.md`; keep both editions aligned when user-facing
  behavior changes.
- [docs/public-chinese-content-guide.md](docs/public-chinese-content-guide.md)
  defines the terminology, descriptive-heading style, account/error wording,
  and typography rules for public pages, account emails, and authenticated
  Chinese templates.
- `uploads/` is ignored and should stay empty in the public repository; runtime
  uploads belong in the application upload directory.

Keep template-referenced paths stable. Before removing files, search `tmpls/`
and non-generated files in `www/` for the URL path.

## Aofei Integration

From the sibling `aofei` checkout, local Summer config generation can point to
this repository:

```bash
AOFEI_PZDESIGN_ROOT=/srv/aofei/pzdesign ./scripts/aofei-local.sh up
```

The generated Summer config should use:

```text
ProjectRoot:   /srv/aofei/pzdesign
Template:     /srv/aofei/pzdesign/tmpls
DocumentRoot: /srv/aofei/pzdesign/www
```

The module depends on Aofei through the stable `github.com/guruperl/aofei/adminapi`
facade for Summer UI helpers, while `cmd/unify` imports `dsp` as the HTTP service
integration point. Local development uses the `replace` in `go.mod` to resolve
that dependency to `../aofei`.

The CI workflow pins its sibling Aofei and Genelet checkouts to reviewed
commits so moving dependency branches cannot change pzdesign verification
unexpectedly. Update those `ref` values in `.github/workflows/verify.yml` when
intentionally adopting a new dependency revision, and verify the repositories
in the same change. CI fetches the primary repository history and checks
committed whitespace over the pull-request
merge-base-to-head or push before-to-after range. Keep `git diff --check` as the
local closeout check for uncommitted changes.

Run the combined service from this checkout with Aofei's generated configs:

```bash
GOWORK=off SUMMER="$PWD/../aofei/etc/summer.local.json" \
  AOFEI="$PWD/../aofei/etc/aofei.local.json" \
  go run ./cmd/unify
```

`cmd/unify` preserves the Aofei config `is_local` value unless `-local` is
passed explicitly; `-local` also loads the local static snapshots before
serving requests.

`SIGINT` and `SIGTERM` stop new HTTP work, allow up to 15 seconds for in-flight
handlers, and then close the Aofei controller so queued audits and owned
service connections drain in order. A shutdown timeout force-closes remaining
connections and exits with an error.

For a local `systemctl --user` service, set `WorkingDirectory` to this checkout
and pass the Aofei config paths explicitly. For example, the port-8200 local
service uses:

```ini
WorkingDirectory=/srv/aofei/pzdesign
Environment=GOWORK=off
ExecStart=/usr/local/go/bin/go run ./cmd/unify -s /srv/aofei/aofei/.local/aofei.8200.json -g /srv/aofei/aofei/.local/summer.8200.json
```

The matching Summer config must set `ProjectRoot` to the pzdesign checkout so
component loading resolves `summer/*/component.json`.

Public advertiser/publisher registration and password retrieval require a
complete `Blks._gmail` SMTP block. If it is absent or incomplete, those actions
return a Chinese maintenance error before database mutation. Login, activation
links already issued, and authenticated workspaces remain available. Removing
the block is the supported emergency email-disable control after credential
exposure.

Bidder portal pages live under:

- `tmpls/adv/bidder/*.g`
- `tmpls/admin/bidder/*.g`

## Documentation

- [docs/genelet-manual.md](docs/genelet-manual.md) covers Genelet config,
  routes, auth, CRUD, uploads, CORS, and error handling.
- [docs/summer-ui-structure.md](docs/summer-ui-structure.md) covers Summer
  module layout, component conventions, registry use, UI options, and cache
  side effects.

## Checks

Run the template parser after editing templates:

```bash
GOWORK=off go test ./...
GOWORK=off go test ./cmd/unify
go run ./tools/check-templates.go -ext=.g
go run ./tools/check-templates.go -ext=.e
GOWORK=off go run ./tools/check-public-copy
./tools/check-public-data.sh
gitleaks git --redact .
```

The `.e` check is intentionally best-effort cleanup coverage. If an English
variant has no runtime owner, prefer making it parse-clean without changing the
active `.g` behavior.

The public-copy check requires the complete Chinese advertiser/publisher
account-action template matrix, preserves reset-form field contracts, and
rejects retired account terms across public and authenticated Chinese
templates. It also rejects slogan headings, raw framework errors, and
Chinese-page links into the secondary `.e` surface.

`.github/workflows/verify.yml` runs tests, vet, both template parsers, and
staticcheck and the public-copy guard on pushes and pull requests. It checks out public Aofei beside this
repository so the local `go.mod` replace directive resolves on a clean runner;
staticcheck keeps the established `ST1000`, `ST1003`, and `ST1006` legacy style
exclusions.

See [SECURITY.md](SECURITY.md) for private vulnerability reporting and the
repository data boundary.
