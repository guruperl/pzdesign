# Archive M03 - Summer Component Platform

**Context.** Ownership of the shared mechanism every admin module is built on:
the component declaration contract, the single registry of component-backed
modules, the shared model and filter base behavior, the option dictionaries, the
packed-attribute helpers, and the typed storage accessors.

**Baseline.** `d67ea8ac35b0578db9674bfbb40fede56954cddf`

**Coverage.** verified

**Supersedes.** none

## Scope And Responsibilities

This context owns the root `summer` package and `summer/registry`. It defines
what a module is, how one is registered, how request state is shaped safely, and
how a filter reaches a shared runtime adapter.

It excludes `summer/public_account_protection.go` and its test, which live in
the same package but are owned by M07. It excludes each module's own domain
rules, which belong to M04 through M10, and it excludes the framework itself,
which is the external Genelet module.

## Domain And Workflows

A component-backed module is a directory holding `component.json`, `model.go`,
and `filter.go`, plus one `registry.Entry`. The registry is the single place a
module is declared; `cmd/unify` never keeps a local map. The registry test
enforces both directions of the correspondence, so a `component.json` without an
entry or an entry without a component file fails the ordinary test gate.

Component JSON is data that reaches SQL construction, so it is constrained
rather than free-form. It declares actions with their allowed role groups,
validation fields, permissions, resources, and reauthentication requirements;
role-specific foreign-key signature fields; primary CRUD metadata; per-action
allowed field lists; joined table metadata; a select-expression to output-label
map; and dependent model calls. Table, alias, key, and CRUD field values must be
SQL identifiers, and joined conditions are validated by Genelet before use.
Arbitrary SQL expressions stay confined to component-owned select expressions
and never come from request input.

The lifecycle is Genelet's, and Summer participates at fixed points. Genelet
resolves the action, rejects invalid CSRF on mutating methods, sets model
defaults, reads the action and foreign-key rules from `Filter.GetAll`, replaces
caller-supplied identity claims with verified role metadata, enforces
permission, resource, TOTP, and reauthentication, enforces group access and
foreign-key signatures, then calls `Filter.Preset`, `Filter.Before`, the model
action, and `Filter.After` before appending the security event, sending optional
mail blocks, and rendering.

The standing safety rule for modules is that request-derived values stay in
`url.Values` for Genelet to validate and parameterize. Filters add query
restrictions through `extra url.Values`, never by concatenating request strings
into SQL, and models use Genelet CRUD helpers unless a hand-written query is
unavoidable and every identifier comes from a narrow allowlist.

Shared option data is read-mostly global state, so it is cloned rather than
mutated. `summer.LargeOptions(name)` and `Filter.AfterItemSet` both copy the
shared option rows before setting `selected` or translated labels; writing
request-specific fields directly into `LARGES` would leak one request's state
into another's.

## System Shape

- `summer.Model` embeds `genelet.Model` and overrides `Dashboard`, `Insert`,
  `Edit`, `Update`, `Activate`, `Retrieve`, `Resetpass`, `Updatepass`,
  `CleanupLogin`, `ChangeEmailAdmin`, and `ChangePasswdAdmin`. The account tables
  `pub`, `adv`, and `testing` get address-record composition on insert and edit;
  everything else falls through to the embedded Genelet behavior.
- `summer.Filter` embeds `genelet.Filter` and supplies `Preset`, `Before`,
  `After`, `BalanceBefore`, and `AfterItemSet`.
- `summer/registry` declares twenty-five entries, each a name plus three
  constructors. `Build` returns plain instances; `BuildFactories` loads each
  component from `<ProjectRoot>/summer/<name>/component.json` and returns
  factories that invoke `Initialize` on every new value, panicking on a failed
  initialization.
- `summer/item.go` and `summer/slot.go` define the packed attribute vocabularies
  for item and slot scoring, each with name, score, and value maps plus `Pack`
  and `Unpack` helpers.
- `summer/dictionary.go`, `summer/attrs.go`, `summer/mime.go`, and
  `summer/openrtb25.go` hold shared option data and OpenRTB packing helpers.
- `summer/utils.go` and `summer/delivery.go` hold shared formatting and
  delivery-limit helpers; `summer/principal.go` holds verified-principal
  helpers.

## Contracts And Dependencies

Genelet resolves an HTML action template as
`<Template>/<role>/<object>/<action>.<tag>` composed with the role glob
`<Template>/<role>/*.<tag>`, where `object` is the URL segment. The component may
override only the action half through a single-valued `template` key.

Storage adapters are supplied by `cmd/unify` and reached through typed helpers,
so a missing adapter is a no-op and a wrongly typed one is an explicit error
rather than a panic:

- `Redis` is a `radix.Client`, `Nc` is a `*nats.Conn`, `Spread` is the string
  spread root, and `DirectSSPTokenIssuer` is the controller-owned public locator
  issuer.
- `ActionReportingEnabled` and `MarketplaceReportingEnabled` are booleans read
  through named helpers.

`summer.TABLES` is the shared entity-type map used by access-control and channel
modules, binding `3`/`31`/`32` to publisher, site, and slot and `4`/`41`/`42` to
advertiser, campaign, and item.

Upload handling is two-stage: `CleanUploadName` rejects anything that is not a
clean basename and `SafeUploadPath` joins it under the configured directory, so
a module can move a validated upload into a role/object subdirectory without
re-deriving path safety.

Account email is a hard precondition, not a soft feature. `AccountEmailAvailable`
and `RequireAccountEmail` check a complete mail block and its credentials before
account mutation, and `AccountEmailUnavailableError` is the Chinese maintenance
error returned when configuration is absent, incomplete, or rejected.

Filter `After` methods are the cache-publication seam. Item, campaign, and
creative insert or update refresh creative cache entries; targetname insert and
admin item update can refresh audience or advertiser cache entries; publisher
take-down updates publisher cache entries; advertiser attrname upload can feed
canonical audience markers into Redis.

## Operations And Verification

The root package and the registry both carry tests that pass at this baseline,
including the registry's bidirectional component correspondence check. Several
module tests use `go-sqlmock` and `miniredis/v2` so filter and model behavior is
exercised without a live database or Redis. `summer/testdb_test.go` and the
per-module `testdb_test.go` files provide the shared database-backed harness,
which degrades to skips without a `SUMMER` configuration.

Adding a component-backed module means adding the directory, the model and
filter types, `component.json`, and one registry entry. `component.json`, model
field lists, filters, and the active MySQL schema must stay aligned, and the
schema half of that alignment lives in Aofei.

## Evidence

| Claim | Repository Evidence |
|---|---|
| Twenty-five modules are declared once in the registry. | `summer/registry/registry.go:41-70` |
| Factories load components from `ProjectRoot` and initialize each instance. | `summer/registry/registry.go:84-114` |
| Registry and component files are checked against each other. | `summer/registry/registry_test.go` |
| The shared model composes address records for account tables. | `summer/model.go:17-60` |
| Shared filter, option cloning, and item-set helpers. | `summer/filter.go:20-22`, `summer/filter.go:223-234`, `summer/filter.go:375-393` |
| Storage keys are named constants read through typed helpers. | `summer/filter.go:24-38`, `summer/filter.go:236-270` |
| The shared entity-type map used by access control and channels. | `summer/filter.go:121-128` |
| Upload names are cleaned and joined under a safe path. | `summer/filter.go:40-49`, `summer/filter.go:106-119` |
| Account email is verified before account mutation. | `summer/filter.go:51-104` |
| Packed item and slot attribute vocabularies with pack/unpack. | `summer/item.go:223-296`, `summer/slot.go:1-200` |
| Component JSON conventions and the module shape. | `docs/summer-ui-structure.md` |
| Model/filter lifecycle order and CRUD identifier helpers. | `docs/genelet-manual.md` |

## Observed Gaps

The MySQL schema that `component.json` metadata must match is not tracked in
this repository, so component-to-schema alignment cannot be verified here.
Genelet's own validation helpers are external; this archive records the contract
Summer relies on, not its implementation.
