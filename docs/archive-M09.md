# Archive M09 - External Demand Integration

**Context.** Ownership of the middleman surfaces that connect this marketplace
to external demand: advertiser-owned bidder endpoint profiles, the operator
approval that activates them, and the administrator routing configuration that
decides which external demand sees which traffic.

**Baseline.** `d67ea8ac35b0578db9674bfbb40fede56954cddf`

**Coverage.** verified

**Supersedes.** none

## Scope And Responsibilities

This context owns `summer/bidder` and `summer/midroute`, together with
`tmpls/adv/bidder`, `tmpls/admin/bidder`, and `tmpls/admin/midroute`.

It excludes the auction and the actual outbound bid requests, which are Aofei's,
and it excludes Redis route-cache publication, which is a separate singleton
command. The UI here maintains configuration and reports on cache state; it does
not publish routes.

Public naming matters in this context: the outward feature name is external
DSP/ADX demand integration, and `middleman` stays an internal code,
configuration, and operations term.

## Domain And Workflows

A bidder profile is advertiser-owned but operator-activated. Advertisers may
create and edit their own endpoint metadata — bidder name, endpoint URL, OpenRTB
version, buyer seat, and timeout — through the advertiser bidder routes. Every
field an advertiser must not control is stripped from the form before validation
for any non-admin role: the three synthetic reporting ids, the credential
reference, the credential status, and the active flag. Credential status and
active status remain visible but read-only; credential references and synthetic
reporting ids are admin-only.

The partner contract is pinned. OpenRTB version is fixed at `2.5`, defaulted on
insert and rejected for any other value, and the form renders it read-only. The
endpoint URL must be absolute HTTP or HTTPS with a valid host, no embedded user
info, and no fragment. The buyer seat is optional and normalized. Timeout is
bounded to a positive value not exceeding the maximum, defaulting on insert.

Approval is a transaction with revalidation, not a flag flip. Administrator
approval requires a credential reference that is a portable environment-variable
name — never a header value or a secret — then loads the persisted profile,
re-runs the same endpoint validation against the stored fields rather than
against the request, creates or validates the inactive synthetic
campaign/item/creative reporting chain, and only then marks the credential
active and the bidder active, all inside one committed transaction.

Routing is administrator-only and hierarchical: a route group carries a trigger
mode, a total timeout, a margin percentage and floor, and an active flag, and it
owns nested route-bidder and route-target rows over `mid_route_bidder` and
`mid_route_target`. Group listings report bidder and target counts alongside the
route-cache status.

Cache state is reported, never changed. Route edits write MySQL only. The topics
and health actions read the Redis route cache and compare its route high-water
mark against the database's, classifying the result as `fresh`, `stale`, or
`unknown`, and surfacing the cache key, entry counts, generation timestamp,
source, and checksum. A missing Redis adapter degrades to an explicit
`cache_error` rather than failing the page. Publication remains the singleton
`cmd/redis-cache` job, and the read-only `-validate-middleman` check is still
required after publication and before activating traffic; the health page alone
is not an activation gate.

Health is a fixed set of diagnostic queries with issue types and severities. It
flags active groups with no active target, active targets referencing missing or
inactive inventory or size metadata, and synthetic reporting chains whose
campaign, item, or creative is enabled as ordinary local demand — a
misconfiguration that would let a reporting placeholder compete for real
traffic. Health never reads credential secret values.

## System Shape

- `summer/bidder` provides `startnew`, `insert`, `topics`, `edit`, `update`,
  `approve`, and `delete` over `adv_bidder`, with a role-sensitive `Preset` and
  a shared `validateEndpointFields` used by both the request path and the
  approval path.
- `summer/midroute` provides group CRUD plus nested `bidders`, `targets`, and
  their per-row start/insert/edit/update/delete actions, a `health` action, and
  option loaders for bidders and sizes.
- `loadRouteCacheStatus` is called by both `Topics` and `Health` and publishes a
  `midroute_cache_status` map into template data.
- `routeCacheFreshness` compares generation time and high-water marks and is
  deliberately conservative: an unparsable timestamp is `unknown`, an empty
  high-water mark on either side is `stale`.

## Contracts And Dependencies

- `match.ValidMiddlemanCredentialRefName` from Aofei defines what a credential
  reference may be; both the form path and the approval path use it.
- `adminapi.HashNameMiddlemanRoutesV2`,
  `adminapi.DBGetMiddlemanRouteHighWater`, and
  `adminapi.MiddlemanRouteCacheFromRedis` are the Aofei facade functions this
  context reads; `radix.Client` is reached through a typed storage helper that
  distinguishes absent from wrongly typed.
- Tables `adv_bidder`, `mid_route_group`, `mid_route_bidder`, and
  `mid_route_target` are Aofei-owned, as is the `middleman:routes:v2` cache key.
- Admin bidder approval accepts only an environment-variable name for
  `credential_ref`; header values remain deployment-owned.
- The middleman callback routes `/mid/win`, `/mid/loss`, `/mid/bill`, and
  `/mid/click` are mounted by `cmd/unify` and handled by the Aofei controller,
  outside this context.

## Operations And Verification

`summer/bidder` carries filter, model, template, and database-harness tests, and
`summer/midroute` carries filter, model, and template tests; all pass at this
baseline. The template tests are what keep bidder endpoints and credential
references out of clickable or script contexts — a stored endpoint must not be
made clickable or fetched merely to preview it.

## Evidence

| Claim | Repository Evidence |
|---|---|
| Non-admin roles cannot submit synthetic ids, credentials, or active state. | `summer/bidder/filter.go:28-36` |
| Endpoint URLs must be absolute HTTP(S) without user info or fragment. | `summer/bidder/filter.go:78-112` |
| OpenRTB version defaults to and is pinned at 2.5. | `summer/bidder/filter.go:114-135` |
| Timeout is bounded and defaulted on insert. | `summer/bidder/filter.go:163-187` |
| Credential references must be environment-variable names. | `summer/bidder/filter.go:59-76`, `summer/bidder/model.go:41-44` |
| Approval revalidates the persisted profile, not the request. | `summer/bidder/model.go:55-66` |
| Approval builds the synthetic chain and activates in one transaction. | `summer/bidder/model.go:68-84` |
| Route groups carry trigger mode, timeout, margin, and counts. | `summer/midroute/model.go:19-30` |
| Health reads cache status plus fixed diagnostic queries. | `summer/midroute/model.go:32-43`, `summer/midroute/model.go:523-540` |
| Cache status reports key, watermarks, source, and checksum. | `summer/midroute/model.go:439-481` |
| Missing Redis degrades to an explicit cache error. | `summer/midroute/model.go:453-461` |
| Freshness classification is conservative about unknown inputs. | `summer/midroute/model.go:496-521` |
| The UI never publishes routes; a singleton command does. | `docs/summer-ui-structure.md` |
| Public naming keeps `middleman` internal. | `docs/public-chinese-content-guide.md` |

## Observed Gaps

The Redis route-cache payload contract, the `cmd/redis-cache` publisher, and the
`-validate-middleman` check live in Aofei, so this repository can show what the
UI reads and reports but not how a route becomes live. No in-repo evidence
records which environment variables hold bidder credentials; by design only their
names are stored.
