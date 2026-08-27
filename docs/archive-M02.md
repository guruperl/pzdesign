# Archive M02 - HTTP Service Composition And Lifecycle

**Context.** Ownership of the single combined HTTP process: how the Aofei DSP
controller, the Genelet admin controller, and the optional Aofei services are
assembled into one server, which exact routes exist, and how the process starts,
reports health, and drains.

**Baseline.** `d67ea8ac35b0578db9674bfbb40fede56954cddf`

**Coverage.** verified

**Supersedes.** none

## Scope And Responsibilities

This context owns `cmd/unify`: flag and environment configuration, controller
construction, storage-adapter injection, optional-service gating, the exact
route multiplexer, `/pz` CORS, health and readiness endpoints, and graceful
shutdown ordering.

It excludes the operator identity CLI `cmd/identity-admin`, which belongs to
M07, and it excludes the behavior of the Aofei services it merely constructs and
mounts. The component contract it feeds is owned by M03.

## Domain And Workflows

One binary serves two families of traffic. Public advertising traffic reaches
exact DSP routes handled by the Aofei controller. Everything else falls through
to the Genelet catch-all, which renders the Summer admin and public account
surfaces. Because the two share a process, they also share a database handle,
Redis client, NATS connection, and spread root.

Every optional capability is default-off and gated by Aofei configuration rather
than by a pzdesign flag. Four services follow the identical pattern: construct
from Aofei config, refuse to proceed if the service is enabled but the Summer
identity boundary is absent, then publish the result into Genelet storage so
component filters can find it. A nil service is a normal, supported state, and
the corresponding UI stays unavailable rather than failing.

Configuration is layered, not merged blindly. The DSP controller is
authoritative for server port, server URL, document root, and connection array;
Genelet keeps its own value when it has one and inherits the DSP value only when
its field is empty. The Aofei `is_local` value is preserved unless `-local` was
explicitly passed on the command line, which is why the code distinguishes a set
flag from a default one.

Shutdown is ordered. A signal stops new HTTP work, in-flight handlers get up to
fifteen seconds, and only then does the Aofei controller close so queued audits
and owned service connections drain in order. A timeout force-closes remaining
connections and exits with an error.

## System Shape

- `main` parses flags, installs a `SIGINT`/`SIGTERM` notify context, and calls
  `run`.
- `run` builds a development zap logger, constructs the Aofei `dsp.Controller`
  from the `-s`/`AOFEI` config, applies the uploaded-audience TTL and the local
  mode flag, then builds the Genelet controller from the `-g`/`SUMMER` config.
- `getGenelet` loads the Genelet config and calls `registry.BuildFactories` with
  the config's `ProjectRoot`, which is why the Summer config must point at this
  checkout for `summer/*/component.json` to resolve.
- Storage injection publishes the public-account protector, the two reporting
  availability booleans, the identity service, the publisher auth service, the
  direct-SSP token issuer, the management API service, the traffic-quality
  service, the hosted-payment service, and the shared `Redis`, `Nc`, and
  `Spread` adapters.
- `newServeMuxWithServices` registers the exact routes; `newServeMux` and
  `newServeMuxWithManagementAPI` are thin wrappers that pass fewer services.
- `serviceHealth` holds an `accepting` atomic plus the controller reference and
  serves `/healthz` and `/readyz`.
- `runHTTPServer` owns the listener, the shutdown timeout, and the
  before-shutdown callback that flips readiness off.

## Contracts And Dependencies

The route table is exact-match by method and path:

- `POST /bid/{domain}` and `POST /pz` are wrapped by the Aofei traffic gate with
  partner keys `adx:<domain>` and `ssp`; `OPTIONS /pz` answers the CORS
  preflight with 204.
- `GET /win`, `/loss`, `/clk`, `/imp` and `POST /action` are the measurement
  callbacks; `GET /mid/win`, `/mid/loss`, `/mid/bill`, `/mid/click` are the
  middleman callbacks.
- `GET /debug/vars` is wrapped by the controller's metrics handler, which
  restricts it to configured direct peers.
- `GET /healthz` is process liveness. `GET /readyz` reports lifecycle and
  local-generation readiness and goes unavailable before drain, making it the
  regional load-balancer target. Neither endpoint returns dependency or
  configuration detail.
- `/api/v1/` mounts the management API when the service exists; otherwise `/api/`
  returns 404 so the surface does not silently fall through to the admin UI.
- `POST /webhooks/stripe` mounts only when hosted payments exist; `/webhooks/`
  otherwise returns 404. The raw signed webhook is owned here, never by a Summer
  action or a human session.
- `/` is the Genelet handler.

`pzCORS` sets a wildcard origin with `POST, OPTIONS` methods and a `Content-Type`
allowed header, scoped to the `/pz` publisher endpoint only.

The HTTP server sets a 5s read-header timeout, 15s read and write timeouts, a
60s idle timeout, and a 1 MiB header cap.

Reporting availability is probed once at startup with two `information_schema`
queries: the marketplace probe requires all four of `report_delivery`,
`measurement_action`, `mid_callback_retry`, and `daily_log`; the action probe
checks the action-reporting schema. The results become storage booleans, so a
missing schema degrades the UI to an explained unavailable state rather than a
query error.

## Operations And Verification

`cmd/unify` is the only package CI runs with `-race`. Its test file covers the
mux composition, service gating, local-flag handling, and graceful shutdown
paths and passes at this baseline.

Documented run modes are a foreground `go run ./cmd/unify` with `SUMMER` and
`AOFEI` environment variables, and a `systemctl --user` unit whose
`WorkingDirectory` is this checkout with explicit `-s` and `-g` config paths.

Shared dependency state is deliberately kept on protected metrics rather than in
readiness, so one shared outage does not withdraw every HTTP node at once.

## Evidence

| Claim | Repository Evidence |
|---|---|
| One binary serves DSP routes and the Genelet catch-all. | `cmd/unify/main.go:1-2`, `cmd/unify/main.go:355-360` |
| The 15-second drain budget is a named constant. | `cmd/unify/main.go:41` |
| Optional services refuse to run without the identity boundary. | `cmd/unify/main.go:100-119` |
| Storage adapters published for Summer filters. | `cmd/unify/main.go:80-126` |
| Genelet inherits DSP server fields only when its own are empty. | `cmd/unify/main.go:127-138` |
| Component factories load from the config's `ProjectRoot`. | `cmd/unify/main.go:372-390`, `summer/registry/registry.go:88-104` |
| The exact route table, traffic gate keys, and 404 fallbacks. | `cmd/unify/main.go:321-361` |
| `/pz` CORS is scoped to that endpoint. | `cmd/unify/main.go:363-370` |
| Health is liveness; readiness flips before drain. | `cmd/unify/main.go:205-228`, `cmd/unify/main.go:157-161` |
| Reporting availability is a startup schema probe. | `cmd/unify/main.go:167-195` |
| `-local` is honoured only when explicitly set. | `cmd/unify/main.go:280-307` |
| HTTP server timeout and header limits. | `cmd/unify/main.go:141-148` |
| Race testing is applied to this package in CI. | `.github/workflows/verify.yml:49-50` |

## Observed Gaps

The Aofei and Genelet configuration files this command consumes are not tracked
here; the README documents their generated paths under `../aofei/etc/`. No
in-repo evidence establishes production values for the traffic gate, metrics
CIDR allowlist, or TLS termination, all of which are edge and Aofei concerns.
