# Archive M08 - Marketplace Reporting And Analytics

**Context.** Ownership of every read-only analytical surface in the control
plane: the per-role delivery dashboards, the advertiser conversion and
attribution report, the cross-role marketplace report with its freshness
disclosure, and the administrator experiment view.

**Baseline.** `d67ea8ac35b0578db9674bfbb40fede56954cddf`

**Coverage.** verified

**Supersedes.** none

## Scope And Responsibilities

This context owns `summer/ledger` and the ledger templates under
`tmpls/admin/ledger`, `tmpls/adv/ledger`, `tmpls/pub/ledger`, and
`tmpls/analyst/ledger`, plus the `editPub` publisher detail action.

It excludes financial statements, adjustments, confirmations, corrections, and
manual settlement, which are operator-only Aofei commands, and it excludes the
metric definitions themselves, which are the sibling Aofei analytics contract.
Reporting never changes financial data.

## Domain And Workflows

Scope comes from the session, never from the request. Every marketplace query
reads Genelet's authoritative `_grole` and branches on it: administrators and
analysts get the operator query, advertisers get the advertiser query keyed on
the session `adv_id`, publishers get the publisher query keyed on the session
`pub_id`, and any other role is an error. An advertiser or publisher without its
authenticated account id is refused rather than defaulted, and a request-supplied
`admin_id` cannot upgrade either role.

Report windows are bounded before any query runs. The day must be a UTC date
between 2000-01-01 and today, the lookback between 0 and 90 days, and the row
limit between 1 and 200; defaults are yesterday, zero lookback, and 200 rows,
and every value is written back in canonical form. Time is UTC and currency is
USD throughout.

Money is exact and versioned. The marketplace report publishes a contract block
naming USD, UTC, a per-row accounting version, and the active accounting version
`usd-cpm-impression-v3`, and the underlying queries group and aggregate by
`accounting_version` so rows produced under different accounting rules are never
silently merged.

Freshness is disclosed rather than assumed. A dedicated freshness query reports
delivery-report and daily-log watermarks with a three-state classification —
`current`, `partial`, or `unavailable` — where delivery data older than two
hours and daily data older than one day degrade to `partial`. Advertiser scopes
additionally report an action watermark and the pending middleman callback
backlog; publisher scopes report `not_applicable` for the action state, because
conversion facts are advertiser-owned.

Action facts are queried separately from delivery facts on purpose. Joining them
would multiply conversions across geo and device grouping, so the marketplace
view issues a separate nested call for actions and reconciles counts against
aggregate impressions, clicks, and spend rather than joining.

The experiment view is administrator-only and strictly aggregate. It reports
per-variant exposure with declared primary and guardrail outcomes, experiment and
assignment-algorithm versions, and bounded retention. It never renders assignment
salts, subject hashes, idempotency keys, stop or audit reasons, or per-subject
rows, and it has no bid or budget mutation action. Deletion of expired or
exact-subject data stays command-only.

Reporting is gated on schema availability. `cmd/unify` probes the reporting
tables once at startup, and the filter turns a missing capability into an
explained Chinese 503 before the action runs, separately for conversion
reporting and for marketplace analytics.

The authenticated JSON chartag is an internal UI export with the same scope
rules as the HTML view; it is not the public advertiser API. Agent reports remain
absent until a reviewed delegation relationship exists, and analysts reach the
marketplace view only after an exact permission and resource grant.

## System Shape

- `summer/ledger/model.go` holds the query set: advertiser 24-hour, top-items,
  top-slots, action, and action-breakdown reports; publisher 24-hour, top-slots,
  and top-campaigns reports; middleman 24-hour, top-bidder, top-slot, top-route,
  and top-publisher reports; the marketplace report with its freshness, summary,
  and action companions; and the experiment view.
- `marketplaceScope` is the single scope resolver shared by the marketplace,
  summary, and freshness queries.
- `TopicsMarketplace` runs its own query, decorates rows, publishes the contract
  block, then issues nested `CallOnce` invocations for freshness and, for
  advertiser and administrator roles, for summary and action facts.
- `decorateMarketplaceRows` maps numeric device OS and device type codes to
  their named forms through Aofei's `advice` vocabulary.
- `summer/ledger/filter.go` binds publisher and advertiser foreign-key
  signatures by role in `GetAll`, applies window defaults and validation in
  `Preset`, and enforces the two availability gates in `Before`.

## Contracts And Dependencies

- Component actions declare `report.advertiser.read`, `report.publisher.read`,
  `report.marketplace.read`, `report.middleman.read`, and `experiment.read`
  permissions; `topicsMarketplace` additionally carries a
  `["marketplace","0"]` resource tuple and admits the analyst role.
- JSON report reads require the separate `.export` permission and recent MFA.
- Reporting tables `report_delivery`, `measurement_action`, `mid_callback_retry`,
  `daily_log`, `report_experiment`, `report_experiment_variant`, and
  `report_experiment_outcome` are owned by Aofei; their presence is what the
  startup probe checks.
- `advice.DeviceOS` and `advice.DeviceType` from Aofei supply the device
  vocabulary.
- The authoritative metric, freshness, experiment, retention, benchmark, and
  rollout contract is the sibling Aofei marketplace analytics document.
- Templates state UTC, USD, the accounting version, and the freshness state, and
  render action names and dimensions as ordinary escaped table text, never into
  scripts, chart literals, links, or raw HTML.

## Operations And Verification

`summer/ledger` carries the widest test set in the module: filter tests, model
tests, a template test, and a MySQL integration test. All pass at this baseline,
with the integration test skipping in the absence of a database configuration.

The template test is the guard that keeps report values out of JavaScript
contexts; chart configuration values remain ordinary template data so
`html/template` emits JavaScript escapes.

## Evidence

| Claim | Repository Evidence |
|---|---|
| Scope is resolved from the authoritative session role. | `summer/ledger/model.go:377-395` |
| Advertiser and publisher scopes require their authenticated id. | `summer/ledger/model.go:382-390` |
| The marketplace report branches by role into three distinct queries. | `summer/ledger/model.go:143-162` |
| The contract block names USD, UTC, and the active accounting version. | `summer/ledger/model.go:164-168` |
| Queries group and aggregate by accounting version. | `summer/ledger/model.go:201-260` |
| Freshness is a three-state watermark classification. | `summer/ledger/model.go:397-432` |
| Publisher scopes report no action state; advertiser scopes report backlog. | `summer/ledger/model.go:424-430` |
| Action facts are fetched by a separate nested call, not a join. | `summer/ledger/model.go:169-177` |
| The experiment view is aggregate per variant with declared versions. | `summer/ledger/model.go:440-495` |
| Report windows are bounded and canonicalized before querying. | `summer/ledger/filter.go:66-83` |
| Role foreign-key signatures are bound per role. | `summer/ledger/filter.go:18-28` |
| Both reporting families degrade to an explained Chinese 503. | `summer/ledger/filter.go:85-93` |
| Availability is probed once at startup against the schema. | `cmd/unify/main.go:167-195` |
| Report permissions, the marketplace resource tuple, and analyst access. | `summer/ledger/component.json` |
| Device dimensions are decorated from the Aofei vocabulary. | `summer/ledger/model.go:329-336` |

## Observed Gaps

The reporting tables, the meaning of `usd-cpm-impression-v3`, and the pipeline
that populates them are external to this repository, so metric correctness
cannot be established here — only scope, bounds, disclosure, and escaping. No
in-repo evidence shows whether the reporting schema is present in any given
environment; the startup probe exists precisely because it varies.
