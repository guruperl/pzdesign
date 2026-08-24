# Summer/Genelet Rendering Security

This document is the maintenance contract for server-rendered W8M pages. The
active UI uses Go `html/template`; request and stored values must stay typed as
ordinary strings so the renderer can escape them for HTML text, attributes,
URLs, and JavaScript string contexts.

## Rendering Inventory

Genelet composes each authenticated action template with the shared files at
`tmpls/<role>/*.{g,e}`. Public web actions use the same renderer with the
`tmpls/web` layout. The active Chinese surface is `.g`; `.e` remains secondary
but is subject to the same parser and source-policy checks.

| Surface | Entry points | Untrusted or stored inputs | Required treatment |
|---|---|---|---|
| Public account flows | `tmpls/web/adv`, `tmpls/web/pub` | registration, activation, recovery, reset, request arguments, account names and email addresses | ordinary contextual escaping; links use `urlquery` for query values |
| Login and error pages | `tmpls/{admin,adv,agent,pub,analyst}/login*`, role errors, `tmpls/web/error*` | login field names, return URI, password/TOTP input names, framework error code/message | contextual escaping; return redirects are validated by `Config.ValidateLocalRedirect`; raw internal errors are not rendered |
| Advertiser workspace | `tmpls/adv` | account, campaign, ad-group, bidder, target, balance, report, and creative records | contextual escaping in text, attribute, URL, and JavaScript contexts |
| Publisher workspace | `tmpls/pub` | account, site/App, slot, access-control, report, generated tag, and reviewed creative records | contextual escaping; reviewed creative content is source text only |
| Agent review | `tmpls/agent` | advertiser, campaign, ad-group, creative, and review records | contextual escaping; reviewed creative content is source text only |
| Administrator workspace | `tmpls/admin` | account, inventory, bidder, route, report, and operational status records | contextual escaping; credentials and secret values are not template data |
| Identity and analyst pages | `tmpls/{admin,adv,agent,pub,analyst}/security`, `tmpls/analyst` | one-time TOTP setup URI/secret, recovery codes, MFA state, account label, delegated report values | ordinary contextual escaping; setup/recovery values are response-only, never persisted in templates or converted to raw HTML; analyst has read-only report templates |
| Reports and charts | ledger/dashboard templates under each role | labels and aggregate database values | contextual escaping, including JavaScript-string escaping inside chart configuration |
| Account mail | `tmpls/web/{adv,pub}/*.mail.{g,e}` | account names, email and signed link fields; configured server origin | rendered with `html/template` and sent as plain mail content; query values use `urlquery` |

The service controller, Summer filters, and Genelet renderer are also rendering
entry points: filters shape `genelet.Tmpl` values, Genelet selects and composes
templates, and `cmd/unify` serves the result. None may convert application data
to a raw template type.

## One Trusted HTML Boundary

The only approved raw-template conversion is
`genelet.(*Base).CSRFInput() template.HTML`. It executes a fixed
`html/template` containing one hidden input and converts only that fully
rendered result. Callers can supply neither markup nor a different template.
Genelet tests scan the package to keep this the only `template.HTML`,
`template.URL`, `template.JS`, `template.CSS`, `template.HTMLAttr`, or
`template.Srcset` boundary.

The renderer injects that fixed hidden input separately into every POST form
that does not already contain it. One manually tokenized form must never cause
a sibling password, TOTP, mutation, or logout form to remain unprotected.

Application code and pzdesign templates must not add another raw type. If a
future feature appears to require one, first document its trust source,
sanitizer and allowed elements/attributes/URL schemes, then add narrow hostile
fixtures and obtain a security review. Convenience formatting is not a reason
to bypass contextual escaping.

## Stored Creative Content

Creative source data and URLs are intentionally stored because the auction
delivery path may return an approved advertisement. Control-plane pages must
never execute or fetch that stored value. The following management/review
templates show it only as escaped source in `<pre class="creative-source">`:

- `tmpls/adv/creative/topics.{g,e}`;
- `tmpls/pub/item/topics.g`;
- `tmpls/agent/item/topics.{g,e}`.

This rule covers both markup and URL creatives: an `<iframe src>`, `<img src>`,
`srcdoc`, script assignment, or dynamic embedded-resource element would turn a
review page into an execution or server-directed fetch surface. Actual bid and
direct-SSP creative materialization belongs to Aofei's delivery contract and
the D02 creative-validation milestone; it is not a template preview exception.

`www/js/ads.js` is the one named browser-side delivery sink: after a successful
`/pz` response it places the ordered HTML result in exactly one `srcdoc` iframe
inside the publisher-selected ad container. It never assigns the result to the
host page's `innerHTML`. The iframe has an opaque origin because its sandbox
omits `allow-same-origin`; it also removes the referrer and denies camera,
microphone, geolocation, payment, USB, serial, Bluetooth, and clipboard
permissions. Scripts, forms, and popup landing behavior remain explicitly
allowed for the reviewed advertising contract, but top/parent navigation is
not. This sink is not used by a W8M control-plane page. Focused source and Node
fixtures lock down the single sink, exact sandbox/permissions attributes,
hostile markup containment, and deterministic fill states. P01 owns publisher
integration isolation and D02/S05 own the creative acceptance and consumer
boundaries.

## URL, Attribute, And Asset Policy

- Application actions and static assets use local relative or root-relative
  URLs. Executable JavaScript and stylesheet dependencies are served from the
  reviewed `www/` tree.
- Templates must not contain `javascript:`, `vbscript:`, HTML `data:` URLs, or
  remotely hosted script, stylesheet, frame, object, embed, or source assets.
  S06 has one exact vendor-required exception: public registration/recovery may
  load `<script src="https://challenges.cloudflare.com/turnstile/v0/api.js"
  async defer></script>`. The template checker removes only that byte-for-byte
  bootstrap before applying the remote-resource rule; another host, path,
  query, attribute, or embedding element still fails. The widget receives only
  an escaped public site key and one fixed action, never the secret or response
  token.
- Query values are written directly in URL attributes and passed through
  `urlquery` when they are names or free-form text. Do not assemble a query
  string with `print` and then insert the result into a URL context.
- A wholly dynamic URL still needs application policy. Genelet accepts only a
  single-slash local return path under its configured script root. Bidder and
  landing endpoints are validated by their owning controller; a template must
  not make a stored endpoint clickable or fetch it merely to preview it.
- Dynamic event-handler and chart values remain ordinary template data so
  `html/template` emits JavaScript escapes such as `\u003c`. New inline script
  should be avoided; reviewed local scripts and data attributes are preferred.
- Modal labels and other account-controlled strings use DOM text sinks such as
  jQuery `.text()`. Page templates may not use `.html()`, `innerHTML`, or an
  equivalent raw DOM insertion API; the named `ads.js` delivery sink above is
  outside the page-template tree and separately locked down.

A site-wide Content Security Policy is not part of this audit because current
templates and supported ad delivery still contain compatibility-sensitive
inline behavior. A publisher CSP is also inherited by `srcdoc` and can disable
approved creative scripts. S05 therefore adds the compatible narrow iframe
permissions policy while retaining the opaque-origin sandbox. Introduce a
stricter script/style/network CSP only with measured creative compatibility,
an explicit migration, and rollback evidence.

## Required Checks

Run these after changing templates, layout helpers, mail, redirects, or values
passed to the renderer:

```bash
GOWORK=off go test ./...
GOWORK=off go vet ./...
GOWORK=off go run ./tools/check-templates.go -ext=.g,.e
GOWORK=off go run ./tools/check-public-copy
./tools/check-public-data.sh
(cd ../genelet && GOWORK=off go test ./...)
git diff --check
```

`tools/check-templates.go` parses every action with its role layout, rejects
assembled queries and unsafe template-source patterns, and scans pzdesign Go
code for prohibited raw template types. Its hostile fixtures cover public
login/TOTP values, TOTP enrollment and recovery material, account/campaign
data, every authenticated role family, creative source views, report
JavaScript contexts, unsafe form actions, and account mail. It also renders all
advertiser/publisher registration and recovery variants with scoped Turnstile
metadata and proves that only the exact approved bootstrap survives the
remote-resource source rule.
Genelet separately tests the fixed CSRF helper and the uniqueness of its raw
HTML boundary.

During review, also identify the source and trust level of each new value,
inspect every context in which it appears, and test a value containing quotes,
closing tags, an event handler, a script element, and an unsafe URL scheme.
