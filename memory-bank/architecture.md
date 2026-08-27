# Architecture

## Layering

Three sibling Go modules cooperate. Genelet is the framework: routing, role and
cookie auth, component-driven CRUD and SQL construction, identity, templates,
uploads, CORS, and framework errors. Summer, in this repository, is the admin
UI and model layer built on it. Aofei is the DSP runtime and the owner of the
MySQL schema, accounting, caches, and the authoritative domain contracts.

Local development resolves the two dependencies through `replace` directives to
`../aofei` and `../genelet`. CI checks both out at explicitly pinned commits so
dependency branches cannot change verification unexpectedly.

## Layout And Ownership

| Path | Owns |
|---|---|
| `cmd/unify/` | The combined HTTP service: controller construction, storage injection, service gating, exact route mux, health and readiness, graceful drain |
| `cmd/identity-admin/` | Operator-only, non-HTTP identity maintenance; actor derived from the effective Unix UID |
| `summer/` (root) | Shared model and filter behavior, dictionaries, packed attribute vocabularies, upload safety, typed storage accessors, public-form abuse defense |
| `summer/registry/` | The single declaration of every component-backed module |
| `summer/<module>/` | One domain module: `component.json`, `model.go`, `filter.go` |
| `tmpls/<role>/<object>/<action>.<tag>` | Action templates, composed with the role-level `*.<tag>` glob |
| `www/` | Static document root: first-party CSS and JS, the public landing page, Chinese manuals, and four vendored asset groups |
| `tools/` | Template parser and source-policy checker, public Chinese copy checker, public-data guard |
| `docs/` | Four maintenance contracts kept current alongside code |

## Request Flow

A request enters `cmd/unify`'s mux. Exact DSP and measurement routes, the
metrics endpoint, health, readiness, the management API mount, and the payment
webhook are matched first; everything else falls through to the Genelet
controller.

For an admin request, Genelet parses `/{script}/{role}/{chartag}/{object}` and
optional id, maps method to action through `DefaultActions`, and resolves the
component. It then rejects invalid CSRF on mutating methods, sets model
defaults, reads the action and foreign-key rules from `Filter.GetAll`, replaces
caller-supplied identity claims with verified role metadata, enforces
permission, exact resource grant, TOTP, and recent reauthentication, enforces
group access and foreign-key signatures, and calls `Filter.Preset`,
`Filter.Before`, the model action, and `Filter.After` before appending the
security event, sending optional mail blocks, and rendering the JSON chartag or
the composed template.

Filters shape request args and side effects; models run queries through Genelet
CRUD helpers. Request-derived values stay in `url.Values` so Genelet validates
and parameterizes them, and only validated identifiers are ever interpolated.

## Language Editions And Negotiation

The chartag — the second path segment — selects the language edition, and
Genelet resolves `<Template>/<role>/<object>/<action>.<chartag>` composed with
the role glob `<Template>/<role>/*.<chartag>`. `g` is Chinese and `e` is
English; both are configured `text/html`. No framework change is needed to
switch language, and account mail already follows the request's chartag.

The public front page is static and therefore outside that mechanism. `cmd/unify`
owns exact `GET /` and `GET /index.html` handlers, registered ahead of the
Genelet catch-all, which negotiate on `Accept-Language`, honor an explicit
language cookie above the browser value, and fall back to the Chinese file when
the English one is absent. Genelet's `staticPage` is unchanged.

Language preference reaches only entry points: which front page is served and
which `/goto/{role}/{g|e}/…` links are emitted. Authenticated requests are never
redirected to a different chartag.

Two guards keep the editions aligned. A structural parity check requires every
`.g` action to have an `.e` twin with matching form targets, hidden action
values, and input field names, carrying an explicit exemption file that shrinks
as translation lands. `tools/check-public-copy` runs a shared walker with
per-language rule sets, so English public files and `.e` templates are guarded
the way Chinese ones already are.

## Storage Adapters

`cmd/unify` publishes shared runtime state into `Controller.Storage`, and Summer
reads it through typed helpers so a missing adapter is a no-op and a wrongly
typed one is an explicit error:

`Redis` (`radix.Client`), `Nc` (`*nats.Conn`), `Spread` (string root),
`Identity`, `PublisherAuth`, `DirectSSPTokenIssuer`, `ManagementAPI`,
`TrafficQuality`, `HostedPayment`, `PublicAccountProtector`, and the two
reporting-availability booleans probed against the schema at startup.

## Optional Services

Identity hardening, public account abuse protection, the management API,
traffic-quality review, and hosted payments are all default-off. Each is
constructed from Aofei configuration, each refuses to start when enabled without
the Summer identity boundary, and each corresponding UI returns an explained
Chinese 503 while its service is absent.

## Verification

`.github/workflows/verify.yml` runs tests, race tests on `cmd/unify`, vet,
staticcheck with three legacy style exclusions, both template parsers, the
public-copy guard, the public-data guard, a pinned Gitleaks history scan, and a
committed whitespace check. The `.g`/`.e` parity check joins that list as part
of the active work. Every step sets `GOWORK=off`. The same checks run
locally, and `git diff --check` covers uncommitted whitespace.

## Archive baselines

Archive files are frozen repository snapshots. Current product and system truth
lives in this memory bank; use each archive only at its recorded baseline.

| Archive Lane | Context |
|---|---|
| M | Cross-cutting contexts of the single `pzdesign` delivery boundary. `M` is the only lane in use: this repository's prose already uses `A`, `D`, `I`, `P`, `R`, and `S` as Aofei milestone letters, so those letters are reserved and not allocated as archive lanes. |

| Archive | Context | Baseline | Coverage | Supersedes |
|---|---|---|---|---|
| [M01](../docs/archive-M01.md) | Module boundary, dependencies, and repository verification | `d67ea8ac35b0578db9674bfbb40fede56954cddf` | verified | none |
| [M02](../docs/archive-M02.md) | HTTP service composition and lifecycle | `d67ea8ac35b0578db9674bfbb40fede56954cddf` | verified | none |
| [M03](../docs/archive-M03.md) | Summer component platform | `d67ea8ac35b0578db9674bfbb40fede56954cddf` | verified | none |
| [M04](../docs/archive-M04.md) | Advertiser demand management | `d67ea8ac35b0578db9674bfbb40fede56954cddf` | verified | none |
| [M05](../docs/archive-M05.md) | Publisher supply management | `d67ea8ac35b0578db9674bfbb40fede56954cddf` | verified | none |
| [M06](../docs/archive-M06.md) | Cross-party access control and channel policy | `d67ea8ac35b0578db9674bfbb40fede56954cddf` | verified | none |
| [M07](../docs/archive-M07.md) | Identity, permission, and abuse defense | `d67ea8ac35b0578db9674bfbb40fede56954cddf` | verified | none |
| [M08](../docs/archive-M08.md) | Marketplace reporting and analytics | `d67ea8ac35b0578db9674bfbb40fede56954cddf` | verified | none |
| [M09](../docs/archive-M09.md) | External demand integration | `d67ea8ac35b0578db9674bfbb40fede56954cddf` | verified | none |
| [M10](../docs/archive-M10.md) | Funding and settlement boundary | `d67ea8ac35b0578db9674bfbb40fede56954cddf` | verified | none |
| [M11](../docs/archive-M11.md) | Presentation surface and rendering safety | `d67ea8ac35b0578db9674bfbb40fede56954cddf` | verified | none |

## External Contexts

`../aofei` and `../genelet` are separate delivery units and are not archived
here. The authoritative contracts for accounting, auction and creative rules,
identity access security, public account abuse protection, the advertiser
management API, traffic-quality anti-fraud, publisher activation, hosted funding
and payout, marketplace analytics, and production traffic observability live
under `../aofei/docs/`.
