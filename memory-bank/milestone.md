# Milestones

## Delivery outcome

A visitor reaching W8M has the static front page selected by a small browser
script, can open the literal sibling language page with one click, and finds a
complete English edition behind that link. The active horizon now delivers that
end to end for both public and authenticated surfaces: land in English, register
in English, read English manuals, and operate every role workspace in English.
English pages use a restrained Latin system type scale while Chinese pages keep
their established CJK typography.

## Lanes

| Lane | Meaning |
|---|---|
| `L` | Language platform — static entry selection, direct toggle, chartag entry links, guards, and policy documents. Reviewed as code. |
| `T` | Translation — producing the English editions of templates, the landing page, and the manuals. Reviewed as copy, and long-lived through parity maintenance. |

Lane letters `A`, `D`, `I`, `P`, `R`, and `S` are reserved: this repository's
prose uses them as Aofei milestone identifiers. Lane `M` is reserved as the
archive lane in `memory-bank/architecture.md`.

## Execution order

```text
L01 -> L02 -> L03 -> T02 -> T01 -> L04 -> T03 -> L05 -> T04 -> T05 -> L06
```

| ID | Milestone | Status file | Depends on | Downstream |
|---|---|---|---|---|
| L01 | English content standard and copy guard | [status-L01](status-L01.md) | — | L04, T01, T02, T03, L05 |
| L02 | `.g`/`.e` structural parity check | [status-L02](status-L02.md) | — | T01, L05 |
| L03 | Front-page negotiation and language cookie | [status-L03](status-L03.md) | — | L04, T02, L05 |
| T02 | English front page | [status-T02](status-T02.md) | L01, L03 | L04, T03, L05 |
| T01 | Public account surface in English | [status-T01](status-T01.md) | L01, L02 | L04, L05 |
| L04 | Language toggle and entry-point links | [status-L04](status-L04.md) | L01, L03, T01, T02 | L05 |
| T03 | English manuals | [status-T03](status-T03.md) | L01, T02 | L05 |
| L05 | English surface review remediation | [status-L05](status-L05.md) | L01-L04, T01-T03 | T04 |
| T04 | Authenticated workspace English completion | [status-T04](status-T04.md) | L05 | T05 |
| T05 | English typography polish | [status-T05](status-T05.md) | T04 | L06 |
| L06 | Public chartag toggle remediation | [status-L06](status-L06.md) | T05 | — |

## Acceptance

Every milestone must leave the repository-wide pipeline green:

```bash
GOWORK=off go test ./...
GOWORK=off go vet ./...
GOWORK=off go run ./tools/check-templates.go -ext=.g,.e
GOWORK=off go run ./tools/check-parity
GOWORK=off go run ./tools/check-public-copy
./tools/check-public-data.sh
git diff --check
```

Per-milestone acceptance, including the added guards and the named manual
browser pass, is recorded in each status file.

## Horizon boundary

L06 closes the English presentation horizon approved by the owner by correcting
the post-deployment public account-flow toggle defect: display language tags
remain `en` and `zh-CN`, while Genelet route chartags are exclusively `e` and
`g`. T04 supplied
205 authenticated role templates in addition to the 23 complete public
templates; T05 polishes their shared English typography without changing those
template structures:

- Advertiser workspace — 67 files (51 action templates, 16 role fragments)
- Publisher workspace — 43 files (32 action, 11 fragments)
- Admin workspace — 74 files (60 action, 14 fragments)
- Agent workspace — 14 files (7 action, 7 fragments)
- Analyst workspace — 7 files (3 action, 4 fragments)

This horizon does not add an authenticated language-toggle control, change
authorization, run a live account flow, publish a release, or deploy a service.

## Candidate Directions

| Direction | Why deferred | Promotion trigger |
|---|---|---|
| Message-catalog i18n replacing the dual template sets | The chartag mechanism already works and the parity check contains the drift risk; replacing it would change the Genelet and Summer rendering contract | A third language is requested, or parity maintenance becomes the dominant cost of template work |
| English editions of the Aofei-sourced operational manuals | Their Chinese sources live in `../aofei/docs/` and are outside this repository's boundary | Non-Chinese-reading operators join and need the operational manuals |

Candidate directions have no lane letter, no ID, no status file, and no launch
entry. When a trigger becomes true, reconsider the candidate and obtain approval
before allocating the next unused permanent ID.

## Review finding severity

P1 and P2 are **engineering review priorities**. They are not product-domain
terms, not milestone execution priority, and not status markers.

- **P1** — a defect that breaks correctness, security, privacy, or data
  integrity for a realistic input or state. Typical examples here: a value
  reaching a template without contextual escaping, a scope derived from request
  input instead of the verified session, money handled as a float, a stored
  creative source fetched or executed by a control-plane page, or an English
  form whose field contract diverges from its Chinese twin.
- **P2** — a defect that degrades a documented contract, guard, or operational
  behavior without an immediate correctness break. Typical examples: a guard
  that no longer covers the surface it claims, a template that parses but omits
  a required account action, a negotiation path with no test, or documentation
  that contradicts the code it governs.

Classification follows impact, likelihood, and affected scope — never fix size.
A one-line change can be P1 and a large refactor can be below P2. Definitions in
`AGENTS.md` or a linked project review policy override these defaults.

**Gate effect:** a P1 or P2 finding blocks milestone completion until fixed and
re-reviewed. Lower-severity findings do not block; record them and, if they are
worth doing, raise them as candidate directions or rows in a later milestone.

## Milestone review procedure

The initial deep-review pass of a milestone is **iteration 1**. After every P1,
P2, or higher-severity fix, rerun the affected verification and review the whole
milestone again — not only the changed lines. The gate passes only when a review
finds no P1, P2, or higher-severity issue.

The gate is limited to **10 iterations**, which never reset across sessions or
reviewers. Persist the current iteration number in the milestone's status notes
so it survives a context change. If iteration 10 still finds a blocking issue,
leave the milestone incomplete and record the findings with a `[!]` blocked row
naming owner, missing input, impact, and unblock condition.

## New review intake

For a code, architecture, or security review received after this harness exists:

1. **Revalidate against current state.** A finding written against an older tree
   may already be fixed, moved, or invalidated. Confirm each one in the current
   repository before acting on it.
2. **Preserve both severities.** Record the source's severity and your local
   severity when they differ, with the reason for the difference.
3. **Get approval before writing.** Propose the disposition of every finding and
   every file action, and wait.
4. **Place confirmed work.** In-scope findings join an open or pending milestone
   whose owner already covers that area. Completed history is never reopened; a
   defect found in finished work gets a remediation milestone that names its
   lineage.
5. **Sequence by severity.** P1, P2, or higher findings enter the
   dependency-closed active horizon. Optional lower-severity findings go to
   Candidate Directions.
6. **Record provenance portably** in the affected milestone and status notes —
   review name, date, and finding identifier. Do not add a copy of the review or
   a separate finding ledger to the repository.

An intake review counts as a bounded-gate iteration only when it was explicitly
requested as the next pass of an already active persisted gate.
