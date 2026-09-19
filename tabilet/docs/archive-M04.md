# Archive M04 - Advertiser Demand Management

**Context.** Ownership of the demand side of the marketplace: the advertiser
account and its delegated agent view, the campaign/ad-group/creative hierarchy,
targeting and audience metadata, and the delivery-limit counters that constrain
serving.

**Baseline.** `d67ea8ac35b0578db9674bfbb40fede56954cddf`

**Coverage.** verified

**Supersedes.** none

## Scope And Responsibilities

This context owns `summer/adv`, `summer/campaign`, `summer/item`,
`summer/creative`, `summer/balance`, `summer/targetname`, `summer/attrname`, and
`summer/address`, together with the advertiser and agent role templates and the
public advertiser account templates under `tmpls/web/adv`.

It excludes advertiser reporting, which is M08; advertiser API credentials and
account-abuse protection, which are M07; the advertiser's own bidder endpoint
metadata, which is M09; and funding, which is M10. `summer/balance` here is the
delivery-limit module, explicitly not a funding balance.

## Domain And Workflows

The hierarchy is advertiser, campaign, ad-group, creative. The database and
route vocabulary calls the ad-group `item`, and that name is deliberately kept
even though the Chinese UI presents it as 广告组.

An advertiser cannot activate its own objects. Campaign insert and update strip
a submitted `active` value unless the request carries admin privilege, and the
same pattern recurs across advertiser-owned modules: publishers and advertisers
propose, operators approve.

Delivery control is a hard auction input, not display metadata. Campaigns own
the delivery timezone, validated as a loadable IANA location and defaulted to
UTC; ad-group calendars are evaluated in that inherited timezone. Pacing is a
closed two-value set, `Fast` or `Even`, defaulting to `Fast`. An optional weekly
calendar is a Monday-first 168-hour bitmap, cleared entirely when the enable flag
is absent. Balance limits reject negative or fractional count limits, and daily
counters are labelled with their UTC reconciliation date.

Pricing is CPM-only. Ad-group insert and update reject any `cost_type` other
than `CPM` with an explicit migration message, and parse `cost` as an exact
positive USD CPM with at most six decimal places using Aofei's accounting type.
Legacy ROI, CPC, and CPA rows stay visible as disabled migration records so they
cannot be silently re-saved as CPM.

Every advertiser-supplied URL is validated to the same shape: absolute HTTP or
HTTPS, non-empty hostname, no embedded credentials. This covers the campaign
quality-image URL, the ad-group landing URL, each comma-separated impression and
click URL, and creative content URLs.

Creatives are typed. A creative is Banner, Video, or Native with a positive
rotation weight. Banner and Video accept one validated source URL or one
uploaded image or video, and the URL's extension-derived MIME must match the
declared type; Native content is parsed into Aofei's version-1 structured source
contract. Stored creative source is shown on management and review pages as
escaped source text only and is never fetched or executed.

Targeting splits into geographic and custom dimensions served by dedicated
topic actions, and target inserts verify that the advertiser actually owns the
referenced ad-group before writing. Audience attribute uploads emit a canonical
marker set — `buyeruid`, `userid`, `ip`, `did`, `dpid`, `mac` — that Aofei
validates and normalizes before any Redis write.

Advertiser accounts share the account lifecycle of publishers: public
registration, email activation, password retrieval and reset, plus the
authenticated profile. Account records compose an address row through the shared
model, and mail is rendered from `tmpls/web/adv/*.mail.*` with a keyed digest
over account id, email, timestamp, and name fields.

The agent role is a delegated admin view over advertiser, campaign, ad-group,
and creative records, with its own login, error, and security templates.

## System Shape

- Each module follows the `component.json` plus `model.go` plus `filter.go`
  shape and is registered once in `summer/registry`.
- Advertiser-scoped filters set the shared entity-type marker used by access
  control: campaigns set `41` and ad-groups set `42`.
- Ad-group `Preset` packs slot and item scoring attributes into `fl_slot` and
  `qa_item` and bounds `page_cap` below 256 and the frequency-cap fields below
  65536.
- Creative uploads move validated files into role/object subdirectories through
  the shared upload helpers.
- Templates live at `tmpls/adv/<object>/<action>.{g,e}` for the advertiser
  workspace, `tmpls/agent/...` for the delegated view, and `tmpls/web/adv/...`
  for the public account surface, each composed with the role-level glob.

## Contracts And Dependencies

- `summer.ApplyDeliveryForm` and `summer.ValidateBalanceLimits` are the shared
  entry points for schedule, pacing, calendar, and count-limit rules; campaign
  passes the campaign flag so only campaigns own the timezone.
- `accounting.ParseCPM` from Aofei is the money type for ad-group cost; exact
  parsing rather than float arithmetic is the invariant.
- `match.CreativeMediaBanner`, `CreativeMediaVideo`, `CreativeMediaNative`, and
  `match.ParseNativeCreativeV1` from Aofei define the creative type vocabulary
  and the native source contract.
- Cache publication happens in filter `After`: campaign, item, and creative
  writes refresh creative cache entries; targetname insert and admin item update
  can refresh audience or advertiser entries; attrname upload can write audience
  markers to Redis.
- Campaign schedule, pacing, pause, and budget edits do not rebuild a complete
  delivery generation from the request. The singleton Aofei cache publisher owns
  that, and the runtime rejects expired delivery policy rather than serving a
  stale edit indefinitely.
- Runtime format, exact-size, MIME, HTTPS, and hostile-response rules for
  creatives are the sibling Aofei auction and creative contract.

## Operations And Verification

`summer/adv`, `summer/campaign`, `summer/item`, and `summer/creative` all carry
filter tests, and `summer/item` adds model tests; all pass at this baseline.
`summer/attrname`, `summer/balance`, `summer/targetname`, and `summer/address`
have no test files of their own and are covered indirectly by the root package
tests and the template parser.

A production-source guard rejects outbound `net/http` clients, transports, and
convenience fetch functions in the campaign, item, site, and creative packages,
and private-host tripwire tests pass loopback URLs through the real filters and
require zero HTTP requests. Advertiser-supplied URLs are stored metadata, not
fetched resources.

## Evidence

| Claim | Repository Evidence |
|---|---|
| Non-admin campaign writes cannot set `active`. | `summer/campaign/filter.go:27-32` |
| Campaign and ad-group URLs must be absolute HTTP(S) without credentials. | `summer/campaign/filter.go:55-66`, `summer/item/filter.go:239-249` |
| Campaigns own the delivery timezone; pacing is a closed set. | `summer/delivery.go:27-50` |
| The weekly calendar is a 168-hour Monday-first bitmap. | `summer/delivery.go:14`, `summer/delivery.go:51-70` |
| Ad-groups accept only exact positive USD CPM. | `summer/item/filter.go:32-41` |
| Ad-group bounds on page cap and frequency caps. | `summer/item/filter.go:62-80` |
| Advertiser entity-type markers for access control. | `summer/campaign/filter.go:48-50`, `summer/item/filter.go:27-29` |
| Creative type vocabulary and MIME-versus-type agreement. | `summer/creative/filter.go:213-243` |
| Native creative source parses into Aofei's v1 contract. | `summer/creative/filter.go:215-218` |
| Target inserts verify advertiser ownership of the ad-group. | `summer/targetname/filter.go:66-88` |
| Advertiser account mail uses a keyed digest and template file. | `summer/adv/filter.go:94-130`, `tmpls/web/adv/insert.mail.g` |
| Delivery-limit balance is separate from funding. | `summer/balance/component.json`, `docs/summer-ui-structure.md` |
| Advertiser, agent, and public advertiser template trees. | `tmpls/adv/`, `tmpls/agent/`, `tmpls/web/adv/` |

## Observed Gaps

`summer/address` has a `component.json` using capitalized keys (`Actions`,
`Current_Table`, `Insert_pars`) unlike every other component, and no template
directory of its own; it is composed into advertiser and publisher account forms
by the shared model rather than routed to directly. The advertiser tables the
component metadata targets are defined in Aofei, so field-level agreement cannot
be verified from this repository.
