# Archive M10 - Funding And Settlement Boundary

**Context.** Ownership of the line between the control-plane UI and real money:
the hosted funding and payout workflow, the deliberate absence of every retired
card and bank collection surface, and the rule that auditable accounting lives
in operator commands rather than in this repository.

**Baseline.** `d67ea8ac35b0578db9674bfbb40fede56954cddf`

**Coverage.** verified

**Supersedes.** none

## Scope And Responsibilities

This context owns `summer/hostedpayment` and the hosted-payment templates for
the administrator, advertiser, and publisher roles, plus the standing prohibition
represented by the retired `summer/payment`, `summer/cc`, `summer/cheque`,
`summer/alipay`, and `summer/wechat` directories.

It excludes the provider integration and the domain enforcement, which are
Aofei's `hostedpayment.Service`; the signed webhook endpoint, which `cmd/unify`
owns; and statement, adjustment, confirmation, correction, and manual settlement
recording, which are Aofei's `cmd/accounting`. It also excludes
`summer/balance`, which is a delivery-limit module and not a funding balance.

## Domain And Workflows

The module is a non-CRUD workflow shared by three roles rather than a table
editor. Every action declares `no_db` and `no_method` options and renders a
shared `page` template, so the filter — not a model CRUD call — drives the work
by delegating to the Aofei service.

The capability is default-off. It exists only when Aofei
`hosted_payments.enabled` is explicitly set, and when absent the filter returns
an explained Chinese 503. Shared navigation checks only service availability and
stays hidden while the feature is unavailable; that hiding is presentation, and
authorization remains server-side regardless.

Authorization is identity-derived and scope-replacing. The actor comes from a
verified principal, the advertiser and publisher scopes are overwritten with the
authenticated account id, and only an administrator may name a different party,
which must still be a valid advertiser or publisher tuple. A role that is not
advertiser, publisher, or administrator is not a financial account role at all.
Recent MFA is required for every mutating action in the workflow, and permissions
are collected from the role configuration into an explicit set rather than
assumed.

Money movement is maker/checker with optimistic versioning. Bindings and
operations are proposed, then independently approved, then executed, and every
approval and execution submits both an id and a version so a stale form cannot
act on a changed object. Idempotency is carried by a request key supplied on
proposal and reused on submission. Every step writes an audit event with prior
and next state.

Completion is never inferred from the browser. Provider onboarding and checkout
are one-time redirects returned as HTTP 303 from the filter, and the success
message states explicitly that the final result comes from the signed callback
and reconciliation. Templates display only statements, bounded states, and
opaque provider identifiers.

The data boundary is absolute: full card and bank data, raw webhooks,
signatures, and secrets must never enter this repository or its page model. The
retired modules are the historical form of that rule — `payment`, `cc`,
`cheque`, `alipay`, and `wechat` remain as empty, unregistered, untracked
directories with no templates, and forms that collect full card or bank
credentials must not be restored. The legacy advertiser account-balance action
and balance column are likewise absent from active routes and views.

## System Shape

- Twelve-plus actions cover the funding customer and payout onboarding
  lifecycle (`fundingCustomer`, `payoutOnboarding`, `refreshOnboarding`,
  `approveBinding`), the operation lifecycle (`proposeFunding`, `proposePayout`,
  `proposeRefund`, `approveOperation`, `executeOperation`, `cancelOperation`),
  and reconciliation (`reconcile`, `resolveReconciliation`), plus `topics` and a
  secret-readiness check.
- `paymentActor` builds the Aofei actor, its scope, its permission set, and its
  recent-MFA state from the verified principal and the role configuration.
- `formIdentity` enforces the id-plus-version pair on every action that acts on
  an existing binding or operation.
- Redirects are returned as `genelet.Gerror{Code: 303}` carrying the provider
  URL, so the redirect flows through the framework's error path rather than
  through raw template output.
- Template data exposes only scope, role booleans, a message, the CSRF input,
  and the service's own bounded structures.

## Contracts And Dependencies

- `hostedpayment.Service` from Aofei owns maker/checker enforcement, exact
  statement scope, amount validation, idempotency, provider state, and
  reconciliation; the filter delegates rather than reimplements.
- Component actions name separate `payment.*` permissions, resource-bind
  advertiser and publisher mutations to the authenticated identity through
  `resource_adv` and `$f:adv_id`, and require `reauth:["mfa"]`.
- `POST /webhooks/stripe` is mounted by `cmd/unify` only when the service
  exists; otherwise `/webhooks/` returns 404. The raw signed webhook is never a
  Summer action or a human session.
- Statements displayed here are the A01 accounting artifacts produced by Aofei's
  `cmd/accounting`; this UI reads them and never writes them.
- Advertiser pages use the warm workspace palette and publisher pages the
  cool/green palette, matching the role conventions of the wider UI.

## Operations And Verification

`summer/hostedpayment` carries both a filter test and a component test; the
component test is what holds the permission, resource, MFA, and option metadata
in place. Both pass at this baseline.

The empty retired directories are untracked, so they exist only in a working
checkout and cannot reappear in the published tree without new files and a new
registry entry — a change the registry correspondence test would surface.

The activation, provider, and rollback contract is the sibling Aofei hosted
funding and payout document.

## Evidence

| Claim | Repository Evidence |
|---|---|
| The service is optional; its absence is an explained Chinese 503. | `summer/hostedpayment/filter.go:30-32` |
| The actor and scope derive from a verified principal. | `summer/hostedpayment/filter.go:220-233` |
| Advertiser and publisher scope is overwritten with the account id. | `summer/hostedpayment/filter.go:242-252` |
| Only administrators may name another party, and it must be valid. | `summer/hostedpayment/filter.go:254-264` |
| Every mutating action in the workflow requires recent MFA. | `summer/hostedpayment/filter.go:268-278`, `summer/hostedpayment/component.json` |
| Approval and execution require an id and a version. | `summer/hostedpayment/filter.go:288-296` |
| Proposal, approval, and execution each write prior/next audit state. | `summer/hostedpayment/filter.go:91-120` |
| Provider URLs are one-time 303 redirects, not template links. | `summer/hostedpayment/filter.go:63-79`, `summer/hostedpayment/filter.go:113-118` |
| Completion is attributed to callback and reconciliation, not redirect. | `summer/hostedpayment/filter.go:119-120` |
| Actions are non-CRUD, `no_db`, and share one page template. | `summer/hostedpayment/component.json` |
| Advertiser mutations are resource-bound to the authenticated id. | `summer/hostedpayment/component.json` |
| The webhook is mounted by the service command, gated on availability. | `cmd/unify/main.go:349-354` |
| Retired funding modules are empty, unregistered, and untracked. | `summer/registry/registry.go:41-70`, `docs/summer-ui-structure.md` |
| Auditable accounting is an operator command, not a Summer module. | `docs/summer-ui-structure.md` |

## Observed Gaps

The provider integration, statement model, amount and idempotency enforcement,
and reconciliation logic live in Aofei, so this repository establishes the
calling contract and the display boundary but not the correctness of a money
movement. No in-repo evidence shows the feature enabled anywhere; the checked-in
Aofei example keeps it off.
