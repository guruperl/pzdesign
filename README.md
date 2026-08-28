# pzdesign

`pzdesign` is the Go module `github.com/guruperl/pzdesign`. It owns the
Summer admin packages, UI templates, and static assets used by the sibling
Aofei/Winter DSP checkout. It depends on the external Genelet framework module
`github.com/guruperl/genelet`.

## Layout

- `docs/` contains Genelet framework and Summer module maintenance references.
- `tmpls/` contains Go `html/template` files arranged as
  `tmpls/<role>/<object>/<action>.g`.
- `cmd/unify/` contains the combined Summer/Genelet admin and Aofei DSP HTTP
  service command.
- `summer/` contains admin UI models, filters, component JSON, registry code,
  and module tests.
- `tmpls/<role>/*.g` contains shared role-level layout fragments such as
  headers, sidebars, and footers.
- `*.g` templates are the Chinese-language UI templates.
- `*.e` templates are English-language variants. Chinese is the source of
  truth; the public/account English surface is complete, while authenticated
  role workspaces remain partial and are governed by exact parity exceptions.
- `www/` is the static document root used by the UI templates.
- `tools/check-templates.go` parses the templates with Go's `html/template`,
  rejects unsafe URL/resource/stored-markup source patterns, and prevents raw
  template types outside Genelet's one reviewed boundary.

## Static Assets

Runtime asset groups under `www/`:

- `sb2/` contains the SB Admin 2 assets referenced by advertiser templates.
- `admin/` contains Bootstrap admin assets referenced by admin and agent
  templates.
- `1.0.8/` contains publisher and web console assets.
- `css/`, `js/`, `img/`, and `vendor/` support the public landing page and
  legacy creative/demo pages.
- `www/css/w8m-account.css` is the shared public registration/login theme:
  advertiser entry pages use the landing page's coral role color and publisher
  entry pages use its teal role color. Keep authenticated dashboard styling
  separate from this public account surface.
- `www/index.html` is the English static directory index. Its early script
  selects `/index.zh.html` for a Chinese primary browser language only when the
  visible path is `/`; direct requests for either named index file stay literal.
- `manuals/` contains the public Chinese and English advertiser/agency and
  publisher/supply-side web manuals.
  Their operational content follows the sibling Aofei references
  `docs/advertiser-dsp-agent-manual.zh-CN.md` and
  `docs/publisher-manual.zh-CN.md`; keep both editions aligned when user-facing
  behavior changes.
- [docs/public-chinese-content-guide.md](docs/public-chinese-content-guide.md)
  defines the terminology, descriptive-heading style, account/error wording,
  and typography rules for public pages, account emails, and authenticated
  Chinese templates.
- [docs/rendering-security.md](docs/rendering-security.md) inventories public,
  authenticated, report, creative-review, and mail rendering paths and defines
  the contextual-escaping, trusted-HTML, URL, asset, and hostile-test rules.
- R02 marketplace reports live in `summer/ledger` and the role templates under
  `tmpls/{admin,adv,pub}/ledger`. Their authoritative metric, freshness,
  experiment, and rollout contract is the sibling Aofei document
  `docs/marketplace-analytics-experiments.md`.
- P02 seller/site/slot supply controls live in `summer/{pub,site,slot}` and the
  matching publisher/admin templates. Seller approval is operator-only,
  publisher edits revoke approval, and all values remain ordinary escaped text.
  The authoritative cache, `schain`, privacy, report, and rollout contract is
  the sibling Aofei document `docs/publisher-activation.md`.
- `uploads/` is ignored and should stay empty in the public repository; runtime
  uploads belong in the application upload directory.

Keep template-referenced paths stable. Before removing files, search `tmpls/`
and non-generated files in `www/` for the URL path.

## Aofei Integration

From the sibling `aofei` checkout, local Summer config generation can point to
this repository:

```bash
AOFEI_PZDESIGN_ROOT=/srv/aofei/pzdesign ./scripts/aofei-local.sh up
```

The generated Summer config should use:

```text
ProjectRoot:   /srv/aofei/pzdesign
Template:     /srv/aofei/pzdesign/tmpls
DocumentRoot: /srv/aofei/pzdesign/www
```

The module depends on Aofei through the stable `github.com/guruperl/aofei/adminapi`
facade for Summer UI helpers, while `cmd/unify` imports `dsp` as the HTTP service
integration point. Local development uses the `replace` in `go.mod` to resolve
that dependency to `../aofei`.

The CI workflow pins its sibling Aofei and Genelet checkouts to reviewed
commits so moving dependency branches cannot change pzdesign verification
unexpectedly. Update those `ref` values in `.github/workflows/verify.yml` when
intentionally adopting a new dependency revision, and verify the repositories
in the same change. CI fetches the primary repository history and checks
committed whitespace over the pull-request
merge-base-to-head or push before-to-after range. Keep `git diff --check` as the
local closeout check for uncommitted changes.

Run the combined service from this checkout with Aofei's generated configs:

```bash
GOWORK=off SUMMER="$PWD/../aofei/etc/summer.local.json" \
  AOFEI="$PWD/../aofei/etc/aofei.local.json" \
  go run ./cmd/unify
```

`cmd/unify` preserves the Aofei config `is_local` value unless `-local` is
passed explicitly; `-local` also loads the local static snapshots before
serving requests.

`SIGINT` and `SIGTERM` stop new HTTP work, allow up to 15 seconds for in-flight
handlers, and then close the Aofei controller so queued audits and owned
service connections drain in order. A shutdown timeout force-closes remaining
connections and exits with an error. `GET /healthz` is process liveness;
`GET /readyz` is lifecycle and local-generation readiness, becomes unavailable
before drain, and is the regional load-balancer target. Neither endpoint
returns dependency or configuration details. Shared dependency state remains
on protected metrics so one shared outage does not withdraw every HTTP node.

When Aofei `hosted_payments.enabled` is explicitly enabled, `cmd/unify`
constructs the provider service, mounts exact `POST /webhooks/stripe`, and
registers `summer/hostedpayment` pages for administrator, advertiser, and
publisher roles. The feature remains disabled by default and its navigation is
hidden while unavailable. Templates display only A01 statements, bounded
states, and opaque provider identifiers; hosted URLs are one-time redirects
and full card/bank data, raw webhooks, signatures, and secrets must never enter
this repository or its page model. See
`../aofei/docs/hosted-funding-payout.md`.

Public `/bid/{domain}` and `/pz` traffic is wrapped by Aofei's configured
per-partner QPS/burst/concurrency/body/timeout gate. `/debug/vars` is available
only to direct peers in `metrics_allowed_cidrs` and must also be denied by the
public edge. See the sibling Aofei
`docs/production-traffic-observability.md` contract.

For a local `systemctl --user` service, set `WorkingDirectory` to this checkout
and pass the Aofei config paths explicitly. For example, the port-8200 local
service uses:

```ini
WorkingDirectory=/srv/aofei/pzdesign
Environment=GOWORK=off
ExecStart=/usr/local/go/bin/go run ./cmd/unify -s /srv/aofei/aofei/.local/aofei.8200.json -g /srv/aofei/aofei/.local/summer.8200.json
```

The matching Summer config must set `ProjectRoot` to the pzdesign checkout so
component loading resolves `summer/*/component.json`.

Public advertiser/publisher registration and password retrieval require a
complete `Blks._gmail` mail block. For Gmail API delivery, set `Transport` to
`gmail-api`, keep only non-secret `From` and optional `Reply-To` metadata in
JSON, and inject `GOOGLE_CLIENT_ID`, `GOOGLE_CLIENT_SECRET`, and
`GOOGLE_REFRESH_TOKEN` through an owner-only deployment environment file.
Credentials are checked before account mutation. If mail configuration is
absent, incomplete, or rejected by Google, those actions return a Chinese
maintenance error. Login, activation links already issued, and authenticated
workspaces remain available. Removing the block is the supported emergency
email-disable control after credential exposure. Legacy SMTP blocks remain
compatible.

Public account abuse protection is independently default-off. When
`PUBLIC_ACCOUNT_PROTECTION_ENABLED=true`, `cmd/unify` requires Redis, complete
Turnstile site/secret keys, exact allowed hostnames, and reviewed trusted-proxy
CIDRs at startup. Advertiser/publisher registration and recovery validate the
single-use token and fixed action before password hashing or shared/provider
work, then atomically consume pseudonymous IP/email/global Redis quotas before
Gmail or database mutation. Only the public site key enters templates. Follow
the sibling Aofei `docs/public-account-abuse-protection.md` activation,
monitoring, rotation, and rollback contract; no Cloudflare or Turnstile secret
belongs in this repository.

Summer/Genelet identity hardening is optional and the checked-in Aofei example
keeps it disabled. When enabled after the S02 schema migration, `cmd/unify`
pairs the signed role cookie with an opaque database session, enforces required
TOTP/recovery and named action/resource permissions, protects logout with
POST+CSRF, and records immutable redacted security evidence. The same 32-byte
environment key must be present on every HTTP node. `cmd/identity-admin` is the
restricted non-HTTP interface for analyst creation, exact grants, TOTP reset,
and bounded retention. It has no actor-id flag: the kernel-reported effective
Unix UID must map to a reviewed administrator id in the restricted Summer
`Identity.MaintenanceActors` configuration, and the launcher UID is included
in every stored reason. Follow the sibling Aofei
`docs/identity-access-security.md` contract before activation. The same binary
also exposes `-action=prune-api-audit` for bounded management-API evidence
retention when run with the separated maintenance database configuration.

The external advertiser `/api/v1` is separately disabled by default. When I03
is enabled, `cmd/unify` initializes Aofei's management API before the Genelet
catch-all and makes its credential lifecycle service available to the
`apicredential` component. Advertisers and administrators issue, rotate, or
revoke least-privilege tokens only under S02 permission plus recent MFA; tokens
are shown once and never reused as browser sessions. See the sibling Aofei
`docs/advertiser-management-api.md` contract.

S03 traffic-quality review is also disabled by default. When Aofei enables it,
`cmd/unify` requires the S02 identity service and exposes the registered
`trafficquality` component. Advertisers and publishers see only their own
disclosed cases and may appeal; exact-grant agents/analysts have scoped reads;
recent-MFA administrators own rule versions, rollout, review, enforcement,
rollback, and maker/checker billing recommendations. Templates never render
event/partner digests or raw identity evidence. Follow the sibling Aofei
`docs/traffic-quality-anti-fraud.md` contract before activation.

Bidder portal pages live under:

- `tmpls/adv/bidder/*.g`
- `tmpls/admin/bidder/*.g`

## Documentation

- [docs/genelet-manual.md](docs/genelet-manual.md) covers Genelet config,
  routes, auth, CRUD, uploads, CORS, and error handling.
- [docs/summer-ui-structure.md](docs/summer-ui-structure.md) covers Summer
  module layout, component conventions, registry use, UI options, and cache
  side effects.
- [docs/rendering-security.md](docs/rendering-security.md) is the required
  maintenance contract for values rendered into HTML, attributes, URLs,
  JavaScript, creative review, and account mail.
- The sibling Aofei
  [identity-access-security.md](../aofei/docs/identity-access-security.md)
  covers session/TOTP data, permission vocabulary, operator commands,
  enablement, and rollback.
- The sibling Aofei
  [traffic-quality-anti-fraud.md](../aofei/docs/traffic-quality-anti-fraud.md)
  covers the closed signal taxonomy, rule rollout, evidence/appeal boundary,
  billing recommendations, serving snapshots, retention, and rollback.

## Checks

Run the template parser after editing templates:

```bash
GOWORK=off go test ./...
GOWORK=off go test ./cmd/unify
GOWORK=off go run ./tools/check-templates.go -ext=.g,.e
GOWORK=off go run ./tools/check-public-copy
./tools/check-public-data.sh
gitleaks git --redact .
```

Parsing and security-source policies are mandatory for both language variants.
The public/account `.e` surface is supported. Authenticated `.e` workspaces are
incomplete, expose no global language toggle, and must remain parse-clean and
fail closed at every recorded parity exception until their translation horizon
is completed.

The public-copy check requires complete Chinese and English
advertiser/publisher account-action matrices, applies edition-specific copy
rules across `.g` and `.e`, rejects raw framework errors, and parses HTML links
so opposite-edition routes appear only in exact language toggles or `hreflang`
alternate elements. The parity check separately compares parsed field names and
hidden action values.

`.github/workflows/verify.yml` runs tests, vet, both template parsers, and
staticcheck and the public-copy guard on pushes and pull requests. It checks out public Aofei beside this
repository so the local `go.mod` replace directive resolves on a clean runner;
staticcheck keeps the established `ST1000`, `ST1003`, and `ST1006` legacy style
exclusions. Secret-history scanning pins Gitleaks v8.27.2 so installation stays
compatible with the workflow's Go 1.23.5 toolchain.

See [SECURITY.md](SECURITY.md) for private vulnerability reporting and the
repository data boundary.
