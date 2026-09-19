# Status C02 - Campaign dashboard template mapping

State: `[+]` Complete

## Goal

Render the query-free advertiser campaign landing with the existing topics
template in both language editions. The owner requested this narrow mapping
on 2026-09-19 after attribution of a missing dashboard template. An initial
uncommitted draft was withdrawn at the owner’s request; the owner then confirmed
that both the normal explicit topics route and this independent fallback repair
are required. This source task resumes that narrow repair.

## Tasks

| Item | State | Notes |
|---|---|---|
| C02.1 Map dashboard rendering and verify existing action semantics | `[+]` | Supported template override implemented. Native controller tests cover both editions, default/explicit action selection, account scope, role rejection and unchanged action-specific filtering. Repository acceptance and bounded review 1 pass. |

## Acceptance and boundaries

- Query-free GET and explicit dashboard render the existing campaign topics page
  in Chinese and English without duplicate templates or a global default change.
- The action remains dashboard for permissions, filters and model dispatch.
  Explicit topics retains its active-state and pagination behavior.
- Synthetic controller tests, repository tests/vet, template/parity/copy/data
  guards, Gitleaks and diff checks pass.
- No dependency revision, schema, deployment, account operation or live login
  belongs to this source correction. C01 and L07 stay completed history.

## Review-fix gate

Iteration 1 passes with no open P1/P2. The only runtime change is the campaign
component's template override; action groups, FK scope, filters, default actions
and templates are unchanged. Query-free and explicit dashboard GETs render both
editions. Spoofed account input is replaced by synthetic trusted identity, and
unauthenticated/agent requests are rejected. Explicit topics keeps its existing
active-state filter and pagination defaults.

Focused tests, full tests/vet, 342-template parsing, parity, public-copy/data
guards, Gitleaks history and staged-diff scans, and whitespace checks pass with
Go 1.26.6. Initial controller fixtures lacked the synthetic company/email session
attributes required by the shared header; adding those fixture attributes fixes
the test setup. No production header or authentication code changed.

This closes the source repair only. Release activation and actual authenticated
browser verification remain outside C02; the public action=topics entry remains
the preferred normal route.
