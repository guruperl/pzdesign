# Summer UI Structure

Summer is the admin UI/model layer on top of Genelet. It provides module models,
filters, component JSON, option dictionaries, upload handling, and cache update
hooks for advertiser, publisher, bidder endpoint, campaign, item, slot,
creative, delivery-limit, ledger, and access-control workflows. Manual billing
and settlement are operator-only Aofei commands rather than Summer modules.
Its source lives in this module under `summer/`.

## Module Layout

Most modules use the same shape:

```text
summer/{module}/component.json
summer/{module}/model.go
summer/{module}/filter.go
```

The root `summer` package provides shared model/filter behavior, dictionaries,
OpenRTB option packing helpers, upload helpers, and shared tests. The
`summer/registry` package declares every component-backed module once and is
used by `cmd/unify` to build model, storage-model, and filter maps.

Add a new component-backed module by adding the module directory, model/filter
types, `component.json`, and one `summer/registry.Entry`. The registry test
checks that every `component.json` has a matching entry and every entry has a
component file.

## Component JSON Conventions

Components define:

- `actions`: action names, allowed role groups, validation fields, and options.
- `fks`: role-specific foreign-key signature fields.
- `current_table`, `current_key`, `current_keys`, `current_id_auto`: primary
  CRUD metadata.
- `insert_pars`, `update_pars`, `edit_pars`, `topics_pars`: allowed fields for
  each CRUD action.
- `current_tables`: joined table metadata for topic/list queries.
- `topics_hash`: SQL select expression to output-label mapping.
- `nextpages`: dependent model calls used to populate related UI data.

Table, alias, key, and CRUD field values must be SQL identifiers. Joined table
conditions are validated by Genelet before use. Keep arbitrary SQL expressions
limited to component-owned select expressions, not request input.

## Actions And Roles

Genelet chooses the action from the HTTP method defaults or request action
parameter. Summer filters then shape request args and side effects for each
role:

- `admin`: full maintenance flows and cache publication actions.
- `adv`: advertiser-facing campaign, item, creative, target, delivery-limit,
  and account flows, including owned middleman bidder endpoint metadata.
- `pub`: publisher-facing site, slot, access-control, and take-down flows.
- `agent`: delegated admin flows.
- `analyst`: read-only report access only after an exact permission/resource
  grant; it has no product mutation groups.

When Genelet identity is enabled, every action has a server-side permission
name. Use `permission_<role>` when roles need different capabilities,
`permission` for a shared capability, or rely on the stable
`<component>.<action>` default. Use a two-element `resource` tuple to bind a
grant to an exact object; `$f:<field>` resolves the id after verified auth args
replace request identity. Use `reauth:["mfa"]` on privileged mutation/export
actions. A template or hidden navigation item is never an authorization
boundary.

The `hostedpayment` module is a non-CRUD A02 workflow shared by `admin`, `adv`,
and `pub`. Its component actions name separate `payment.*` permissions,
resource-bind advertiser/publisher mutations to authenticated identity, and
require recent MFA. The filter delegates maker/checker, exact statement scope,
amount, idempotency, provider state, and reconciliation enforcement to Aofei's
`hostedpayment.Service`; templates never call a provider or infer completion
from a redirect. Shared navigation checks only service availability and remains
hidden while A02 is disabled; authorization is still server-side. Advertiser
pages use the warm workspace palette and publisher pages use the cool/green
palette. The raw signed webhook is owned by `cmd/unify`, not by a Summer action
or human session.

Advertisers can manage owned `adv_bidder` endpoint metadata through
`/goto/adv/g/bidder?action=topics|startnew|insert|edit|update`. Advertiser
writes are limited to bidder name, endpoint URL, OpenRTB version, seat, and
timeout. Credential status and active status are visible but read-only; credential
refs and synthetic reporting IDs are admin-only.

I01 fixes that partner contract at OpenRTB `2.5`: forms render the version
read-only, filters reject any other value, normalize the optional buyer seat
and 1-5000 ms timeout, and reject endpoint credentials or fragments. Admin
approval revalidates persisted profile fields before activating credentials and
the synthetic reporting chain.

The retired `payment`, `cc`, `cheque`, `alipay`, and `wechat` modules are not
registered and have no active templates. Do not restore forms that collect full
card or bank credentials. Aofei's `cmd/accounting` owns auditable statement,
adjustment, confirmation, correction, and manual settlement recording. The
legacy advertiser account-balance action and balance column are also absent
from active Summer routes/views; campaign/ad-group delivery limits remain the
separate `balance` module and are not a funding balance.

R01 adds the advertiser-only analytical report at
`/goto/adv/g/ledger?action=topicsAdvActions`. The ledger component validates
the authenticated `adv_id`, groups only that advertiser's `measurement_action`
facts, and reconciles action/attribution counts and purchase value against
aggregate impressions, clicks, and spend. It never changes financial data.
Action names and dimensions are rendered as ordinary escaped table text and
are not embedded into scripts, chart literals, links, or raw HTML.

R02 adds `topicsMarketplace` for authenticated admin, advertiser, and
publisher chartags plus the admin-only `topicsExperiments` view. Scope is
selected from Genelet's authoritative `_grole`: advertiser queries always use
the session `adv_id`, publisher queries always use the session `pub_id`, and a
request-supplied `admin_id` cannot upgrade either role. Agent reports remain
absent until S02 supplies a reviewed delegation relationship. The authenticated
JSON chartag is an internal UI export with the same scope, not the future I03
public API.

`summer/apicredential` is the sole HTML lifecycle surface for the I03 service
credentials. It remains inert unless `cmd/unify` initialized the Aofei
management API and S02 identity. Component metadata requires named
issue/read/rotate/revoke permissions, exact advertiser resource scope, recent
MFA, CSRF, and a reason. The filter derives advertiser scope from verified
identity and places a new token only in the escaped response that issued or
rotated it; it never persists or logs plaintext. The separate `/api/v1`
handler—not a Summer JSON chartag—owns the public contract.

`summer/slot` receives a narrow controller-owned direct-SSP token issuer from
`cmd/unify`. Before it renders or offers a download, the topics action resolves
the active site by the authenticated publisher/site tuple. The issuer emits
historical v1 locators only while the Aofei gate is disabled and current-epoch
v2 locators when enabled; it exposes no token key. App samples show the four
publisher request-signing header placeholders and the safe authentication mode,
but never the one-time private credential. `summer/publishercredential`
remains the separate S02-scoped issue/read/rotate/revoke surface; Summer
sessions and I03 advertiser credentials are not `/pz` runtime credentials.

`summer/trafficquality` is the S03 review surface and remains inert unless
`cmd/unify` initialized Aofei's traffic-quality service and S02 identity.
Advertiser/publisher routes replace request scope with the verified account id;
agent/analyst routes require exact resource grants. Only recent-MFA
administrators can create rule versions, change rollout, resolve cases/appeals,
activate or roll back enforcement, or recommend/approve billing, and the
Aofei domain repeats permission, scope, MFA, evidence, version, and
maker/checker checks. Pages render only bounded summaries and fixed
classifications, never identity digests, raw request evidence, or secrets. The
full contract is `../aofei/docs/traffic-quality-anti-fraud.md`.

Marketplace templates state UTC, USD, accounting version, and
current/partial/unavailable freshness. Action facts are queried separately so
geo/device grouping cannot multiply conversions. The experiment page is
read-only and aggregates per-variant exposure and declared primary/guardrail
outcomes plus bounded retention; it never renders assignment salts, subject
hashes, idempotency keys, or audit reasons and has no bid/budget mutation
action. Expired/exact-subject deletion remains command-only. The source, metric,
retention, benchmark, and rollout contract is the sibling Aofei document
`docs/marketplace-analytics-experiments.md`.

Admins review bidders through
`/goto/admin/g/bidder?action=topics|edit|update|approve`. Approval requires a
credential ref, creates or validates the inactive synthetic campaign/item/
creative reporting chain, marks the credential active, and activates the bidder.
Admins assign middleman traffic through
`/goto/admin/g/midroute?action=topics`, with nested route-bidder and
route-target actions for `mid_route_bidder` and `mid_route_target`.

Filters should add query restrictions through `extra url.Values`, not by
concatenating request strings into SQL. Models should use Genelet CRUD helpers
unless a hand-written query is necessary and all identifiers come from a narrow
allowlist.

## UI Options

Shared option data lives in `summer.LARGES` and dictionary helpers. Request
state must use `summer.LargeOptions(name)` or `Filter.AfterItemSet`; both clone
the shared option rows before setting `selected` or translated labels. Do not
write request-specific fields directly into `LARGES`.

Slot and item filters pack/unpack OpenRTB option masks for language, MIME,
device, position, expandable, creative, and channel fields. Size helpers convert
between packed `size_id` and width/height values.

Publisher slot forms also own `pub_slot.bidfloor` as a finite non-negative USD
CPM value and normalize it to six decimals. The Aofei cache makes this floor
server-authoritative. Slot topics preserve the parent site type: `Web` sites
show generated browser code only, while `App` sites show contextual SDK/API
examples only. Generated browser delivery uses `www/js/ads.js`, which places
filled markup in an opaque-origin sandboxed iframe and exposes deterministic
filled/no-fill/error container states.

P02 keeps seller and supply metadata on that same publisher ownership model.
Publisher account forms accept proposed public seller id, type, ASI, name, and
domain; every publisher edit writes `seller_authorized=No`. Only the admin
publisher form can approve the exact persisted tuple, and a database trigger
also revokes authorization when approved values change. This transparency does
not change settlement ownership.

Publisher site forms use controlled environment and integration-mode options,
a constrained canonical identity, and an optional public HTTP(S) review URL.
Slot forms use controlled media intent, placement, render context, refresh,
density, traffic/source quality, and management-control values; timed refresh
is limited to 15--3,600 seconds. Filters preserve legacy values when a secondary
English form omits the new controls, reject hostile or incompatible input, and
leave seller/supply output under ordinary contextual escaping. Marketplace
reports show the same closed categories and only an operator-authorized seller
id/type; unknown historical values remain explicit.

D01 advertiser campaign and item forms also validate UTC start/end ranges,
IANA campaign delivery timezones, `Fast`/`Even` deterministic pacing, and an
optional Monday-first 168-hour calendar. Campaigns own the timezone; item
calendars are evaluated in that inherited timezone. Balance forms reject
negative or fractional count limits and label current daily counters with their
UTC reconciliation date. These fields are hard auction controls, not display
metadata.

D02 advertiser item forms expose only reviewed positive USD CPM. Legacy
ROI/CPC/CPA rows remain visible as disabled migration records and cannot be
silently saved as CPM. Creative forms require an explicit Banner, Video, or
Native type and positive rotation weight. Banner/Video accept one validated
source URL or one image/video upload; Native fields serialize to the Aofei
version-1 structured source contract. Review modals remain source-only. Runtime
format, exact-size, MIME, HTTPS, and hostile-response rules plus the populated
data rollout are documented in
[Aofei's auction and creative contract](../../aofei/docs/auction-pricing-creatives.md).

## Cache Side Effects

Summer filter `After` methods publish cache updates for selected admin actions:

- item/campaign/creative insert/update refreshes creative cache entries.
- targetname insert and admin item update can refresh audience or advertiser
  cache entries.
- publisher take-down updates publisher cache entries.
- advertiser attrname upload can feed uploaded audience values into Redis. The
  form emits canonical `buyeruid`, `userid`, `ip`, `did`, `dpid`, or `mac`
  markers; Aofei validates and normalizes the bounded marker set before writes.

Storage adapters are supplied by `cmd/unify` through `model.Storage`:

```text
Redis  -> radix.Client
Nc     -> *nats.Conn
Spread -> string spread root
DirectSSPTokenIssuer -> controller-owned public locator issuer
```

Summer accesses those through typed helper functions so a missing adapter is a
no-op and a wrong adapter type is an explicit error.

Middleman route edits write MySQL only. They do not refresh `middleman:routes:v2`
or legacy `middleman:routes` from the UI or from `cmd/unify`; the singleton
`cmd/redis-cache -cache=redis|all` job remains responsible for publishing route
changes to Redis, with `cmd/redis-cache -cache=routes` available for route-only
refresh. The
`midroute` topics and health actions show Redis route-cache freshness and route
configuration health, but they do not execute cache refreshes or read credential
secret values. D03 health also flags active targets that reference missing or
inactive inventory/size metadata and synthetic reporting chains whose campaign,
item, or creative is enabled as ordinary local demand. Admin bidder approval
accepts only a portable environment-variable name for `credential_ref`; header
values remain deployment-owned. The Aofei read-only
`cmd/redis-cache -validate-middleman` check is still required after publication
and before traffic activation; the UI health page alone is not an activation
gate.

Campaign schedule, pacing, pause, and budget edits also require the singleton
full Aofei cache publisher; the Summer request does not rebuild a complete RAdv
generation. With the checked-in 900-second delivery maximum age, production
publishes every five minutes. The Aofei runtime rejects expired delivery policy
instead of using an old edit indefinitely.

## Local Usage

Summer code, HTML templates, and static assets are tracked in this checkout.
The sibling Aofei local helper generates Summer config with `ProjectRoot`
pointing here, `Template` at `tmpls/`, and `DocumentRoot` at `www/`. The active
renderer is Go `html/template`.

Ordinary request and database values must remain untyped strings under
contextual escaping. Creative management/review pages display stored markup and
URLs as escaped source rather than executing or fetching them. Genelet's fixed
CSRF hidden-input renderer is the sole approved `template.HTML` conversion;
application code must not introduce raw template types. See
[rendering-security.md](rendering-security.md) for the entrypoint inventory,
URL/asset policy, hostile fixtures, and required checks.

Start local services and load sample data:

```bash
(cd ../aofei && ./scripts/aofei-local.sh reset-sample)
```

Run focused admin checks:

```bash
GOWORK=off SUMMER="$PWD/../aofei/etc/summer.local.json" \
  go test ./summer ./summer/pub ./summer/slot ./summer/weight
```

Run the unified service with generated configs:

```bash
GOWORK=off SUMMER="$PWD/../aofei/etc/summer.local.json" \
  AOFEI="$PWD/../aofei/etc/aofei.local.json" \
  go run ./cmd/unify
```

## Maintenance Workflow

- Keep `component.json`, model field lists, filters, and the active MySQL schema
  aligned.
- Use `summer/registry` for component-backed modules instead of adding local
  maps in `cmd/unify`.
- Keep request-derived SQL inputs in `url.Values` and let Genelet validate and
  parameterize them.
- Update [genelet-manual.md](genelet-manual.md) when framework route, auth,
  CRUD, CORS, upload, or error behavior changes.
- Update this document when Summer module layout, registry, action behavior,
  UI option conventions, or cache side effects change.
- Follow [rendering-security.md](rendering-security.md) whenever a filter or
  model adds data to page, mail, report, chart, URL, or preview output.
