# Agent Instructions

## Read order

1. `memory-bank/product.md` — what W8M is, its roles, domain model, and invariants.
2. `memory-bank/architecture.md` — layout, request flow, ownership, contracts.
3. `memory-bank/tech-stack.md` — stack, dependencies, and every runnable command.
4. `memory-bank/milestone.md` — active work index, acceptance, review procedure.
5. The `memory-bank/status-<LANE><NN>.md` file for the milestone you are on.

## Essential commands

```bash
GOWORK=off go test ./...
GOWORK=off go vet ./...
GOWORK=off go run ./tools/check-templates.go -ext=.g,.e
GOWORK=off go run ./tools/check-public-copy
./tools/check-public-data.sh
gitleaks git --redact .
git diff --check
```

Full command set, including the DB-backed and race variants, is in
`memory-bank/tech-stack.md`.

## Boundaries

- This repository is the Summer admin UI and model layer, its templates and
  static assets, and the combined HTTP service. It does not own the MySQL
  schema, the auction, cache publication, accounting, or provider integrations.
- Aofei (`../aofei`) and Genelet (`../genelet`) are sibling modules resolved by
  `replace`. Do not edit them from this repository. CI pins both by commit; a
  dependency bump is a deliberate, separately verified change.
- The repository is public. No live account details, runtime logs, uploaded
  media, production paths, or secrets — in any file, including tests.

## Hard rules

- Chinese `.g` templates are the source of truth. English `.e` templates are
  derived from them and must not diverge structurally.
- Request and database values stay ordinary strings under contextual escaping.
  Genelet's fixed CSRF input renderer is the only trusted HTML boundary; never
  introduce another raw `html/template` type.
- Stored creative source and publisher review URLs are displayed as escaped
  source only. Never fetch or execute them from a control-plane page.
- Scope comes from the verified session, never from request parameters.
- Money parses through Aofei's accounting types. No float arithmetic on money.
- A template or a hidden navigation item is never an authorization boundary.
- Keep template-referenced paths stable. Search `tmpls/` and non-generated
  `www/` for a URL path before removing a file.

## Archive lifecycle

`docs/archive-M01.md` through `docs/archive-M11.md` are **frozen evidence** at
commit `d67ea8ac35b0578db9674bfbb40fede56954cddf`. Current product and system
truth lives in `memory-bank/product.md` and `memory-bank/architecture.md`. Read
a linked archive only when historical baseline evidence is relevant, and never
update one to reflect later code changes — corrections go into a successor
archive. Archive lanes and IDs are a separate namespace from milestone status
IDs and never appear in the milestone index, a status file, or launch input.

## Work cadence

One status row is one commit. Take the next pending row in the current
milestone, implement it, run the milestone's acceptance commands, update the
row marker in its status file, and commit. Follow the bounded review-fix gate
in `memory-bank/milestone.md` before marking a milestone complete.

`GOAL.md` is an optional protocol for running several milestones in order, and
`memory-bank/suggested.txt` is disposable launch input for it. Both can be
deleted; the memory bank works one row at a time without them.
