# Archive M05 - Publisher Supply Management

**Context.** Ownership of the supply side of the marketplace: the publisher
account and its seller-transparency metadata, the site and slot inventory
hierarchy, per-slot floors and creative weighting, the integration code
publishers copy into their own properties, and publisher runtime credentials.

**Baseline.** `d67ea8ac35b0578db9674bfbb40fede56954cddf`

**Coverage.** verified

**Supersedes.** none

## Scope And Responsibilities

This context owns `summer/pub`, `summer/site`, `summer/slot`, `summer/weight`,
and `summer/publishercredential`, the publisher role templates, the public
publisher account templates under `tmpls/web/pub`, and the browser delivery
script `www/js/ads.js` as the publisher's integration artifact.

It excludes publisher reporting, which is M08; the block and channel
relationships publishers configure against advertisers, which are M06; account
abuse protection and identity, which are M07; and the auction itself, which is
Aofei.

## Domain And Workflows

The hierarchy is publisher, site, slot. A site is Web or App, and that type is
load-bearing rather than cosmetic: it constrains the supply metadata a publisher
may declare and it selects which integration sample the slot page renders.

Publishers propose, operators approve. Site insert and update strip a submitted
`active` value from non-admin requests. Seller transparency follows the same
rule more strictly: a publisher may propose seller id, type, ASI, name, and
domain, but any non-admin edit forces `seller_authorized=No`, and only an admin
request may set it to `Yes`. A database trigger additionally revokes
authorization when approved values change, so the approval binds to an exact
persisted tuple rather than to the row. The change is audited with a hash of the
five-field tuple plus prior and new authorization state, under two distinct
event names for the publisher proposal and the administrator review. This
transparency metadata does not change settlement ownership.

Supply metadata is a closed vocabulary with explicit unknowns. Sites declare an
inventory environment, a canonical identity that falls back to the foreign id, an
optional public store URL, and an integration mode, with cross-checks that Web
environments and browser-tag integration require a Web site type and App
environments and SDK integration require an App site type. Slots declare media
intent, placement, render context, refresh mode and seconds, ad density, traffic
and source quality, and management control, each defaulting to `Unknown` rather
than being silently omitted. Unknown historical values stay explicit in reports.

Floors are exact money. Slot insert and update parse `bidfloor` as a
non-negative USD CPM with at most six decimal places, and every read path
re-normalizes the stored value through the same accounting type, rejecting NaN,
infinity, and unexpected column types. The Aofei cache makes the floor
server-authoritative; the form is a proposal surface, not the enforcement point.

Slot topics is where a publisher gets working integration code, and it resolves
scope from the database rather than from the request: the site type is read back
by the authenticated publisher and site tuple before any sample is rendered. Web
sites receive generated browser code only; App sites receive contextual SDK and
API examples only. Samples show the four publisher request-signing header
placeholders and the safe authentication mode, never the one-time private
credential.

Publisher credentials are a separate S02-scoped lifecycle with issue, read,
rotate, and revoke actions. Summer sessions and advertiser API credentials are
explicitly not `/pz` runtime credentials.

`summer/weight` maintains per-slot creative rotation weights over `pub_weight`,
joined to ad-group, creative, and campaign rows, with publisher-scoped
foreign-key signatures on `slot_id` and `slot_md5`.

## System Shape

- Publisher account records compose an address row through the shared model and
  follow the same public registration, activation, retrieval, and reset flow as
  advertisers, with Chinese subjects and mail templates under `tmpls/web/pub`.
- Slot `Preset` normalizes the floor and supply metadata, packs slot and item
  scoring attributes into `qa_slot` and `fl_item`, and resolves `size_id`.
- Slot `Before` restricts topic listings to `active IN ('Yes','New')`.
- Slot `After` branches by action: `startnew` and `edit` build cloned option
  lists with Chinese labels, `topics` issues locators and samples, and `insert`
  and `update` delegate channel and access-control side effects to the `chac`
  module with entity type `32`.
- The direct-SSP token issuer is a controller-owned object read from storage;
  the filter fails the action rather than degrading when it is absent. It packs a
  site locator and a per-slot locator and reports its token version and request
  authentication mode, exposing no token key.
- `www/js/ads.js` POSTs the ad-unit request to a `/pz` endpoint derived from its
  own script origin, parses a JSON array response, and renders each unit.

## Contracts And Dependencies

- `accounting.ParseCPM` from Aofei is the floor money type on both write and
  read.
- `acl.SellerMetadata`, `acl.SiteSupplyMetadata`, and `acl.SlotSupplyMetadata`
  from Aofei own the validation vocabularies; Summer supplies defaults and the
  role-based authorization rule.
- `dsp.DirectSSPTokenIssuer` from Aofei issues public locators. It emits
  historical v1 locators while the Aofei gate is disabled and current-epoch v2
  locators when enabled.
- `www/js/ads.js` is the single named browser-side delivery sink. It clears the
  container, and for a non-empty string result creates exactly one iframe with
  `sandbox="allow-scripts allow-forms allow-popups
  allow-popups-to-escape-sandbox"`, `referrerpolicy="no-referrer"`, and an
  `allow` attribute denying camera, microphone, geolocation, payment, USB,
  serial, Bluetooth, and clipboard access, then assigns the markup to `srcdoc`.
  Omitting `allow-same-origin` gives the frame an opaque origin, and omitting
  top and parent navigation keeps the publisher page under publisher control.
  The container is stamped `data-pz-state` as `filled`, `no-fill`, or `error`,
  making the three outcomes deterministic. The result is never assigned to the
  host page's `innerHTML`.
- Publisher take-down updates publisher cache entries through the filter `After`
  seam.
- The authoritative cache, `schain`, privacy, report, and rollout contract is the
  sibling Aofei publisher-activation document.

## Operations And Verification

`summer/pub`, `summer/site`, `summer/slot`, `summer/publishercredential`, and
`summer/weight` all carry tests that pass at this baseline, including model
tests for `pub`, `slot`, and `weight` and a component test for
`publishercredential`. The `testdb_test.go` harness in `summer/pub` and
`summer/weight` supplies database-backed cases that skip without a `SUMMER`
configuration.

The delivery sink is locked down by focused source and Node fixtures covering
the single sink, the exact sandbox and permissions attributes, hostile-markup
containment, and the deterministic fill states, plus a repository-wide scan for
raw DOM insertion APIs and native WebView renderer APIs.

Publisher `store_url` and site review URLs are stored metadata that the control
plane never fetches; the private-host tripwire tests and the outbound-client
guard cover the site package alongside campaign, item, and creative.

## Evidence

| Claim | Repository Evidence |
|---|---|
| Non-admin site writes cannot set `active`. | `summer/site/filter.go:25-30` |
| Environment and integration mode must agree with site type. | `summer/site/filter.go:44-56` |
| Publisher edits force `seller_authorized=No`; only admin may authorize. | `summer/pub/filter.go:74-95` |
| Seller changes are audited with a tuple hash and two event names. | `summer/pub/filter.go:178-198`, `summer/pub/filter.go:230-240` |
| Slot floors are exact non-negative USD CPM on write. | `summer/slot/filter.go:33-43` |
| Stored floors are re-normalized and hostile numeric types rejected. | `summer/slot/filter.go:303-338` |
| Slot supply metadata defaults to `Unknown` and is validated. | `summer/slot/filter.go:44-62`, `summer/slot/filter.go:95-101` |
| Slot topics resolves site type from the publisher/site tuple in SQL. | `summer/slot/filter.go:186-197` |
| Web sites get browser code, App sites get API samples. | `summer/slot/filter.go:225-232` |
| The token issuer is required, versioned, and exposes no key. | `summer/slot/filter.go:200-211` |
| Slot writes delegate channel and access-control effects to `chac`. | `summer/slot/filter.go:236-265` |
| Slot listings are limited to active and new inventory. | `summer/slot/filter.go:110-118` |
| The single delivery sink, its sandbox, and its three states. | `www/js/ads.js:65-92` |
| Publisher credentials are a separate issue/rotate/revoke surface. | `summer/publishercredential/component.json` |
| Creative rotation weights join ad-group, creative, and campaign. | `summer/weight/component.json` |

## Observed Gaps

`summer/weight` has no template directory of its own, and `tmpls/pub/white/`
contains `topics` and `insert` templates for a URL object `white` that has no
registry entry or `component.json`. Genelet resolves templates as
`<Template>/<role>/<object>/<action>.<tag>` from the URL object segment, so no
in-repo evidence shows which of the two names a running route uses. Both remain
parse-clean under the template checker.

The `pub_slot` and `pub_site` schema, the trigger that revokes seller
authorization, and the Aofei-side floor cache are external to this repository.
