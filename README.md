# pzdesign

`pzdesign` is the Go module `github.com/guruperl/pzdesign`. It owns the
Genelet framework package, Summer admin packages, UI templates, and static
assets used by the sibling Aofei/Winter DSP checkout.

## Layout

- `docs/` contains Genelet framework and Summer module maintenance references.
- `tmpls/` contains Go `html/template` files arranged as
  `tmpls/<role>/<object>/<action>.g`.
- `cmd/unify/` contains the combined Summer/Genelet admin and Aofei DSP HTTP
  service command.
- `genelet/` contains the local web/admin framework used by Summer and
  `cmd/unify`.
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
- `uploads/` is ignored and should stay empty in the public repository; runtime
  uploads belong in the application upload directory.

Keep template-referenced paths stable. Before removing files, search `tmpls/`
and non-generated files in `www/` for the URL path.

## Aofei Integration

From the sibling `aofei` checkout, local Summer config generation can point to
this repository:

```bash
AOFEI_PZDESIGN_ROOT=/srv/aofei/Workspace/pzdesign ./scripts/aofei-local.sh up
```

The generated Summer config should use:

```text
ProjectRoot:   /srv/aofei/Workspace/pzdesign
Template:     /srv/aofei/Workspace/pzdesign/tmpls
DocumentRoot: /srv/aofei/Workspace/pzdesign/www
```

The module depends on Aofei through the stable `github.com/guruperl/aofei/adminapi`
facade for Summer UI helpers, while `cmd/unify` imports `dsp` as the HTTP service
integration point. Local development uses the `replace` in `go.mod` to resolve
that dependency to `../aofei`.

Run the combined service from this checkout with Aofei's generated configs:

```bash
GOWORK=off SUMMER="$PWD/../aofei/etc/summer.local.json" \
  AOFEI="$PWD/../aofei/etc/aofei.local.json" \
  go run ./cmd/unify
```

For a local `systemctl --user` service, set `WorkingDirectory` to this checkout
and pass the Aofei config paths explicitly. For example, the port-8200 local
service uses:

```ini
WorkingDirectory=/srv/aofei/Workspace/pzdesign
Environment=GOWORK=off
ExecStart=/usr/local/go/bin/go run ./cmd/unify -s /srv/aofei/Workspace/aofei/.local/aofei.8200.json -g /srv/aofei/Workspace/aofei/.local/summer.8200.json
```

The matching Summer config must set `ProjectRoot` to the pzdesign checkout so
component loading resolves `summer/*/component.json`.

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
```

The `.e` check is intentionally best-effort cleanup coverage. If an English
variant has no runtime owner, prefer making it parse-clean without changing the
active `.g` behavior.
