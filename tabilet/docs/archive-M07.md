# Archive M07 - Identity, Permission, And Abuse Defense

**Context.** Ownership of who may act and how that is proven: the account
security portal, the operator-only identity maintenance interface, public-form
abuse defense, advertiser API credential lifecycle, and the traffic-quality
review surface whose entire authorization model is identity-derived.

**Baseline.** `d67ea8ac35b0578db9674bfbb40fede56954cddf`

**Coverage.** verified

**Supersedes.** none

## Scope And Responsibilities

This context owns `summer/security`, `summer/manage`, `summer/apicredential`,
`summer/trafficquality`, `summer/public_account_protection.go` and its test, and
`cmd/identity-admin`, together with the `security` and `trafficquality`
templates present for all five roles.

It excludes the identity implementation itself, which lives in Genelet, and the
management-API and traffic-quality domains, which live in Aofei. It also
excludes the process wiring that constructs these services, which is M02.

## Domain And Workflows

Identity hardening is optional and off in the checked-in example. When enabled
after the S02 schema migration, the signed role cookie is paired with an opaque
database session, TOTP or a one-time recovery code is required at login for
roles that require it, named action and resource permissions are enforced,
logout becomes POST with CSRF, and redacted security evidence is recorded
immutably. The same 32-byte environment key must be present on every HTTP node.

Every Summer module inherits the same authorization vocabulary. An action names
`permission_<role>`, `permission`, or falls back to the stable
`<component>.<action>` default; an optional two-element `resource` tuple binds a
grant to an exact object, with `$f:<field>` resolved only after verified auth
args have replaced caller-supplied identity; and `reauth:["mfa"]` marks
privileged mutation and export actions. A template or a hidden navigation item is
never an authorization boundary.

The gated modules all share one shape. Each reads its Aofei service from
storage, returns a Chinese 503 when the service is absent, resolves a verified
principal, refuses to continue if the principal is invalid, then replaces
request-supplied scope with the verified account id before calling the domain
service. The domain service re-checks permission, scope, MFA, evidence, version,
and maker/checker independently, so the filter is a second gate rather than the
only one.

Scope replacement is the recurring invariant. An advertiser's API credential
requests are forced to the authenticated advertiser id, and a mismatch between
the principal's resource binding and the requested advertiser is a 403 rather
than a silent narrowing. Traffic-quality advertiser and publisher routes
overwrite `adv_id`, `pub_id`, `scope_type`, and `scope_id` from the actor before
the scope is even parsed, and a global scope is never reachable from a scoped
role.

Roles are not symmetric. Advertisers and publishers see only their own disclosed
cases and may appeal. Agents and analysts need exact resource grants. Only
recent-MFA administrators may create rule versions, change rollout, resolve
cases and appeals, activate or roll back enforcement, and recommend or approve
billing. Pages render bounded summaries and fixed classifications, never
identity digests, raw request evidence, or secrets.

Secrets are shown once and never stored by the UI. Issue and rotate place a new
API token only in the escaped response that produced it; the filter never
persists or logs plaintext. The account security portal returns TOTP enrollment
material and recovery codes as response-only values.

Public forms are defended independently of identity, and that defense is also
default-off. When enabled, startup requires Redis, a complete Turnstile site and
secret key pair, at least one exact allowed hostname, and at least one reviewed
trusted-proxy CIDR. Registration and recovery validate a single-use token bound
to a fixed action before password hashing or any shared work, then atomically
consume pseudonymous IP, email, and global Redis quotas before Gmail or database
mutation. Only the public site key reaches template data. The validated purpose
is carried in the request context, so a token validated for one purpose cannot
admit a submission for another.

Operator identity maintenance is deliberately not an HTTP surface.
`cmd/identity-admin` has no actor-id flag: the kernel-reported effective Unix UID
must map to a reviewed administrator id in the restricted Summer
`Identity.MaintenanceActors` configuration, and the launcher UID is prepended to
every stored reason. Passwords and encryption keys are never command-line flags.

## System Shape

- `summer/security` exposes `dashboard`, `enroll`, `confirm`, `rotateRecovery`,
  and `disable` for all five roles, each with a named `account.security.*`
  permission, `no_db`/`no_method` options, and a shared `page` template
  override. Enrollment, confirmation, and disable require recent
  reauthentication; recovery rotation requires MFA.
- `summer/apicredential` exposes `topics`, `issue`, `rotate`, and `revoke`,
  publishes the seven management-API scopes as form options, bounds credential
  lifetime to 1–365 days, and records an audit event with prior and next state
  for each mutation.
- `summer/trafficquality` exposes advertiser, publisher, and partner topic
  views plus rule creation, rollout mode changes with canary basis points
  bounded to 0–10000, case and appeal resolution, enforcement, rollback, and
  maker/checker billing recommendation and approval.
- `summer/public_account_protection.go` builds an immutable, concurrency-safe
  protector from environment variables with six named quota scopes, and exposes
  three entry points: `VerifyPublicAccountHuman` before validation,
  `AdmitPublicAccountSubmission` before mutation, and
  `AddPublicAccountProtectionView` to place only the site key into templates.
- `summer/manage` provides the administrator `login_as` action.
- `cmd/identity-admin` supports `create-analyst`, `grant`, `revoke`,
  `reset-totp`, `prune-audit`, and `prune-api-audit`.

## Contracts And Dependencies

- `genelet.NewIdentityService` is constructed once in `cmd/unify` and published
  to storage as `Identity`; a nil service makes these surfaces unavailable
  rather than open.
- `f.AuthorizedPrincipal()` is the shared accessor for a verified principal; all
  four gated modules derive role and account id from it rather than from form
  values.
- `managementapi.Service`, `quality.Service`, and `genelet.IdentityService`
  own the domain rules; Summer supplies form parsing, scope binding, and audit
  metadata through `_gaudit_*` request args.
- Six quota scopes are configurable by environment with defaults: IP 10 per 10
  minutes and 50 per day, email 5 per hour and 20 per day, global 200 per hour
  and 1000 per day. Each override must parse to between 1 and 1,000,000.
- Four `expvar` maps publish public-account submission, Turnstile rejection,
  rate-limit, and dependency-error counters.
- Turnstile verification posts to the fixed Cloudflare siteverify URL with a
  2 KiB token cap, a 64 KiB response cap, and a 2-second Redis timeout.
- The public registration page loads exactly one remote script, the byte-for-byte
  approved Turnstile bootstrap, which the template checker special-cases; the
  widget receives only the escaped public site key and one fixed action.
- Genelet's fixed CSRF hidden-input renderer is surfaced by these filters as
  `CSRFInput` in template data.

## Operations And Verification

`summer/security`, `summer/apicredential`, `summer/trafficquality`, the root
package's public-account protection tests, and `cmd/identity-admin` all carry
tests that pass at this baseline; `summer/trafficquality` adds a component test
that checks its declared permissions, resources, and reauthentication metadata.
`summer/manage` has no test file.

Activation is contract-driven and staged. The sibling Aofei documents for
identity access security, public account abuse protection, the advertiser
management API, and traffic-quality anti-fraud own the enablement, monitoring,
rotation, and rollback procedures, and no Cloudflare, Turnstile, or identity
secret belongs in this repository.

`-action=prune-api-audit` provides bounded management-API evidence retention
when run against the separated maintenance database configuration, defaulting to
400 days when the config omits a retention period.

## Evidence

| Claim | Repository Evidence |
|---|---|
| Gated modules return a Chinese 503 when their service is absent. | `summer/security/filter.go:24-26`, `summer/apicredential/filter.go:19-21`, `summer/trafficquality/filter.go:29-31` |
| Authorization derives from a verified principal, not form input. | `summer/security/filter.go:15-21`, `summer/apicredential/filter.go:22-28` |
| Advertiser scope is forced to the authenticated id; mismatch is 403. | `summer/apicredential/filter.go:44-56` |
| Credential lifetime is bounded and tokens are response-only. | `summer/apicredential/filter.go:60-72` |
| Every credential mutation records prior and next audit state. | `summer/apicredential/filter.go:70-96`, `summer/apicredential/filter.go:106-113` |
| Traffic-quality scope is overwritten from the actor before parsing. | `summer/trafficquality/filter.go:254-268` |
| A scoped role can never reach global scope. | `summer/trafficquality/filter.go:277-288` |
| Rollout canary is bounded to basis points. | `summer/trafficquality/filter.go:58-62` |
| Security actions declare permissions and reauthentication levels. | `summer/security/component.json` |
| Public-form protection is purpose-bound to registration and recovery. | `summer/public_account_protection.go:222-234` |
| A token validated for one purpose cannot admit another. | `summer/public_account_protection.go:272-289` |
| Only the public site key reaches template data. | `summer/public_account_protection.go:291-294` |
| Six named quota scopes with bounded environment overrides. | `summer/public_account_protection.go:192-219` |
| Hostname and trusted-proxy configuration is validated at startup. | `summer/public_account_protection.go:151-190` |
| Abuse counters are published as `expvar` maps. | `summer/public_account_protection.go:34-42` |
| The operator CLI derives its actor from the effective Unix UID. | `cmd/identity-admin/main.go:147-158` |
| Every maintenance reason carries launcher attribution and is bounded. | `cmd/identity-admin/main.go:160-168` |
| Management-API audit pruning defaults to 400 days. | `cmd/identity-admin/main.go:127-140` |
| Permission, resource, and reauth vocabulary for all modules. | `docs/genelet-manual.md`, `docs/summer-ui-structure.md` |

## Observed Gaps

The identity schema, permission vocabulary, session and TOTP storage, and the
management-API and traffic-quality domain rules live in Genelet and Aofei, so
only the calling contract is verifiable here. No in-repo evidence establishes
whether any of these capabilities is enabled in a running deployment; every
checked-in signal points to default-off.
