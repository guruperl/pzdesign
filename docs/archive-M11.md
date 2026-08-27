# Archive M11 - Presentation Surface And Rendering Safety

**Context.** Ownership of everything a browser receives: the template tree and
its composition model, the static asset tree, the public Chinese landing page
and manuals, and the source-level policies plus checkers that keep rendered
values escaped and locally served.

**Baseline.** `d67ea8ac35b0578db9674bfbb40fede56954cddf`

**Coverage.** verified

**Supersedes.** none

## Scope And Responsibilities

This context owns `tmpls/` as a structure, `www/` as an asset tree, the public
landing page and the two Chinese manuals, `tools/check-templates.go` with its
test file, and `tools/check-public-copy`. It owns the contextual-escaping rule,
the URL and asset source policy, the trusted-HTML boundary, and the Chinese copy
and typography rules.

It excludes the per-domain meaning of the values templates render, which belongs
to M04 through M10, and it excludes the CI wiring that invokes these checkers,
which is M01.

## Domain And Workflows

Templates are composed, not standalone. Genelet parses one action file at
`<Template>/<role>/<object>/<action>.<tag>` together with every role-level file
matching `<Template>/<role>/*.<tag>`, so headers, sidebars, footers, and shared
fragments live at the role level and every action inherits them. The template
checker reproduces exactly this composition when parsing, which is why a role
fragment with a syntax error fails every action of that role rather than one
page.

There are two language surfaces with unequal status. `.g` is the active Chinese
runtime surface; `.e` is a secondary English variant kept parse-clean where
practical. The asymmetry is deliberate and bounded: parsing and security source
policies are mandatory for both, and an English variant without a runtime owner
is still not allowed to weaken a shared safety rule. Chinese pages may not link
into the `.e` surface.

The core rendering rule is that ordinary request and database values stay typed
as plain strings so `html/template` escapes them per context — HTML text,
attributes, URLs, and JavaScript strings. There is exactly one approved raw
conversion in the whole system, Genelet's fixed CSRF hidden-input renderer, and
the renderer injects that input into every POST form that lacks it so one
manually tokenized form cannot leave a sibling password, TOTP, mutation, or
logout form unprotected.

Stored creative content is the sharpest case. Creative source and URLs are
intentionally stored because delivery may return an approved advertisement, but
control-plane pages must never execute or fetch that value: management and
review templates show it as escaped source inside `<pre class="creative-source">`
only. An iframe `src`, an `img src`, a `srcdoc`, a script assignment, or a
dynamic embedded resource would turn a review page into an execution or
server-directed fetch surface. The same source-only rule covers publisher
`store_url` review metadata.

Assets are served locally. Application actions and static assets use relative or
root-relative URLs, and executable JavaScript and stylesheet dependencies come
from the reviewed `www/` tree. There is one byte-for-byte vendor exception: the
Cloudflare Turnstile bootstrap on public registration and recovery pages. The
checker removes only that exact string before applying the remote-resource rule,
so a different host, path, query, attribute, or embedding element still fails.

Query values are written directly into URL attributes and passed through
`urlquery` when they are names or free-form text; assembling a query string with
`print` and inserting the result into a URL context is a checked failure. Modal
labels and other account-controlled strings use DOM text sinks; page templates
may not use `.html()`, `innerHTML`, or an equivalent raw insertion API.

Public Chinese copy is a governed surface, not free prose. Headings describe the
page or task rather than sloganeering; the terminology table fixes 广告主,
代理商, 流量方, 广告位, 广告活动/广告组/广告素材, and 登录, and forbids 商家,
商户, 媒体主, 流量源公司, 中间商, 登入, and 登陆. Copy may not promise revenue,
fill rate, traffic quality, or delivery outcomes that are not contractual, may
not present a default-off capability as production-open, and may not display
internal milestone numbers. Password recovery always answers with the
non-enumerating phrasing regardless of whether the account exists. Typography is
bounded: home title at most 42 px on desktop and 34 px on mobile, section
headings 32/28, account headings 30/28, body text at least 16 px with dense
modal detail lists allowed at 14 px and at least 1.7 line height.

A site-wide Content Security Policy is deliberately out of scope at this
baseline: current templates and supported ad delivery still contain
compatibility-sensitive inline behavior, and a publisher CSP is inherited by
`srcdoc` and can disable approved creative scripts. The narrow iframe
permissions policy plus the opaque-origin sandbox is the chosen alternative.

## System Shape

- 414 tracked files under `tmpls/`: 228 `.g`, 178 `.e`, and a small set of
  chartag-specific error templates (`.js`, `.json`, `.t`) plus an `.htaccess`.
  Six role trees exist: `admin`, `adv`, `agent`, `analyst`, `pub`, and the
  public `web`.
- 332 tracked files under `www/`. Four are third-party bundles, each carrying
  its own upstream version marker and referenced by a small, fixed set of
  template paths:

  | Group | Bundle | Files | Distinct template references |
  |---|---|---|---|
  | `www/1.0.8/` | CoreUI Pro Bootstrap 4 Admin Template v1.0.8 | 128 | 18 |
  | `www/sb2/` | Start Bootstrap SB Admin 2 v3.3.7+1, MIT, with `LICENSE` | 61 | 8 |
  | `www/admin/` | Bootstrap 4 documentation-site assets and `dist/` | 59 | 9 |
  | `www/vendor/` | Bootstrap v4.1.1, Font Awesome 4.7.0, magnific-popup, jQuery, jquery-easing, scrollreveal | 53 | 8 |

  `www/1.0.8/` is dominated by 63 `scss` sources and 47 vendored css/js files
  and serves the publisher and web console surfaces; `sb2/` serves advertiser
  templates; `admin/` serves admin and agent templates; `vendor/` serves the
  public landing page. The remaining 31 files are the first-party `css/`, `js/`,
  `img/`, `manuals/`, and root assets.
- First-party stylesheets are `w8m-home.css`, `w8m-account.css`,
  `w8m-workspace.css`, and `w8m-manual.css`, plus the creative preview styles.
  `w8m-account.css` is the shared public registration and login theme, coral for
  advertiser entry and teal for publisher entry, kept separate from
  authenticated dashboard styling.
- First-party scripts are `ads.js`, `counter.js`, and `creative.min.js`.
- `tools/check-templates.go` walks a template root for one extension, applies
  four source rules and the assembled-query rule to every file, parses every
  action with its role fragments, and separately walks the Go tree to reject six
  `html/template` raw types.
- `tools/check-public-copy` checks `www/index.html`, both manuals, and every
  `.g` template against a forbidden-term list, a required-snippet map, the
  nine-file account-action matrix, and the required capability, role-guide, and
  journey modal id sets.

## Contracts And Dependencies

- The four template source rules reject unsafe `javascript:`, `vbscript:`, and
  HTML `data:` URLs; remote `script`/`iframe`/`object`/`embed`/`source` sources
  and remote `link` hrefs; template interpolation inside an executable or
  fetching element; and raw client-side HTML sinks.
- The forbidden raw types are `template.CSS`, `HTML`, `HTMLAttr`, `JS`,
  `Srcset`, and `URL`. The scan is AST-based, tracks import aliases, flags a dot
  import outright, and skips `.git` and `vendor` directories.
- The checker's own test file closes the creative-consumer inventory: it scans
  first-party JavaScript for raw DOM insertion APIs after removing the one exact
  reviewed `ads.js` assignment, and scans the command, Summer, template, and
  JavaScript trees plus the whole repository in Java, Kotlin, Swift,
  Objective-C/C++, C#, Dart, TypeScript/JSX, and XML for native WebView renderer
  APIs, ignoring dependency and build directories.
- The four vendored bundles honor the same locally-served rule the template
  checker enforces for `tmpls/`: no stylesheet in `www/` performs a remote
  `url()` fetch, and no vendored script issues a remote `src`, `href`, `fetch`,
  or `open` call. The roughly 180 remote hostnames that do appear in those
  bundles are exclusively license headers, upstream documentation links, and
  W3C XML/SVG namespace URIs.
- No vendored file contains a first-party identifier (`w8m`, `pz` delivery
  symbols, or a `/goto/<role>/` path), so no application logic is hidden inside
  a third-party path.
- The raw-DOM-sink scan is scoped to `www/js` — `ads.js`, `counter.js`, and
  `creative.min.js` — and checks six markers: `innerHTML`, `outerHTML`,
  `insertAdjacentHTML`, `document.write`, `.html(`, and `srcdoc`. Vendored
  bundles sit outside that root by design, which is why ordinary jQuery
  `.html()` usage inside a library does not fail the build while the same call
  in a first-party file would.
- Account mail templates at `tmpls/web/{adv,pub}/*.mail.{g,e}` are rendered with
  `html/template` and sent as plain mail content, with `urlquery` on query
  values.
- Template-referenced paths must stay stable; removing a file requires searching
  `tmpls/` and non-generated `www/` for the URL path first.
- The manuals' operational content follows the sibling Aofei Chinese advertiser
  and publisher manuals, and both editions move together when user-facing
  behavior changes.

## Operations And Verification

At this baseline the active surface parses 171 action templates and the
secondary surface 128, both with zero failures, and the public-copy check
reports zero failures. `tools/check-templates_test.go` is the largest test file
in the repository at 1,054 lines and carries the hostile fixtures: public login
and TOTP values, TOTP enrollment and recovery material, account and campaign
data, every authenticated role family, creative source views, report JavaScript
contexts, unsafe form actions, account mail, and every advertiser and publisher
registration and recovery variant with scoped Turnstile metadata.

The reviewer's procedure for a new rendered value is recorded: identify its
source and trust level, inspect every context it appears in, and test a value
containing quotes, closing tags, an event handler, a script element, and an
unsafe URL scheme.

## Evidence

| Claim | Repository Evidence |
|---|---|
| Actions are parsed with their role-level fragments. | `tools/check-templates.go:231-259` |
| Only files at depth three or more are treated as actions. | `tools/check-templates.go:134-139` |
| The four template source rules. | `tools/check-templates.go:24-43` |
| The narrow byte-for-byte Turnstile exception. | `tools/check-templates.go:18-22` |
| Assembled query strings in URL contexts are rejected. | `tools/check-templates.go:17`, `tools/check-templates.go:163-165` |
| Six raw template types are rejected by AST scan across the Go tree. | `tools/check-templates.go:46-53`, `tools/check-templates.go:178-228` |
| Forbidden Chinese and English copy terms, including `.e` deep links. | `tools/check-public-copy/main.go:12-55` |
| The nine-file account-action template matrix. | `tools/check-public-copy/main.go:138-148` |
| Required capability, role-guide, and journey modal ids. | `tools/check-public-copy/main.go:150-176` |
| The copy check covers the landing page, manuals, and all `.g` files. | `tools/check-public-copy/main.go:310-329` |
| The rendering inventory and per-surface treatment. | `docs/rendering-security.md` |
| The one trusted HTML boundary and blanket CSRF injection. | `docs/rendering-security.md` |
| Creative source is shown escaped in three named templates. | `docs/rendering-security.md` |
| CSP is deliberately deferred with a stated rationale. | `docs/rendering-security.md` |
| Terminology, heading, and typography rules for public Chinese pages. | `docs/public-chinese-content-guide.md` |
| Non-enumerating password recovery phrasing. | `docs/public-chinese-content-guide.md` |
| Asset groups and the shared public account theme. | `README.md`, `www/css/` |
| Each vendored bundle's upstream identity and version. | `www/sb2/dist/css/sb-admin-2.css:1-5`, `www/vendor/bootstrap/css/bootstrap.min.css:1-4`, `www/1.0.8/css/style.css:1-4`, `www/vendor/font-awesome/css/font-awesome.min.css:1-3` |
| No vendored stylesheet or script performs a remote fetch. | `www/1.0.8/`, `www/sb2/`, `www/admin/`, `www/vendor/` |
| No first-party logic is hidden in a vendored path. | `www/1.0.8/`, `www/sb2/`, `www/admin/`, `www/vendor/` |
| The first-party DOM-sink scan is scoped to `www/js` with six markers. | `tools/check-templates_test.go:180-214` |
| Six role template trees and the two language surfaces. | `tmpls/` |

## Observed Gaps

`.gitleaks.toml` allowlists three paths that no longer exist in the tree:
`www/1.0.8/vendors/js/quill.min.js`, `www/admin/assets/js/docs.min.js`, and
`www/admin/assets/js/src/application.js` are neither tracked nor present on
disk, and only `www/1.0.8/vendors/css/quill.snow.min.css` remains of the Quill
editor. The dead entries do not weaken scanning, because an allowlist entry for
a missing file exempts nothing, but the allowlist no longer describes the asset
tree it was written for.

`tmpls/adv/middle` has no file extension, so the role glob `*.{g,e}` never loads
it and the checker never parses it, leaving a `footer` definition that no
composition reaches. `tmpls/pub/white/` renders an object with no registered
component, and `tmpls/adv/error.t`, `tmpls/pub/error.js`, `tmpls/pub/error.json`,
and `tmpls/web/error.js` are chartag-specific error templates whose runtime
chartags are configured outside this repository.

`www/js/creative.min.js` is minified but sits inside the first-party `www/js`
root, so it is held to the same six-marker DOM-sink rule as the hand-written
first-party scripts; this repository does not record its upstream origin.
