# pzdesign

`pzdesign` is the template and static asset companion for the Aofei/Winter
Summer UI. Aofei can point its Summer configuration at this repository so the
Genelet pages are loaded from `tmpls/` and static files are served from `www/`.

## Layout

- `tmpls/` contains Go `html/template` files arranged as
  `tmpls/<role>/<object>/<action>.g`.
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
Template:     /srv/aofei/Workspace/pzdesign/tmpls
DocumentRoot: /srv/aofei/Workspace/pzdesign/www
```

Bidder portal pages live under:

- `tmpls/adv/bidder/*.g`
- `tmpls/admin/bidder/*.g`

## Checks

Run the template parser after editing templates:

```bash
go run ./tools/check-templates.go -ext=.g
go run ./tools/check-templates.go -ext=.e
```

The `.e` check is intentionally best-effort cleanup coverage. If an English
variant has no runtime owner, prefer making it parse-clean without changing the
active `.g` behavior.
