# Status L07 - Bilingual public Privacy Policy and Terms

State: `[+]` Complete

## Goal

Publish discoverable Chinese and English Privacy Policy and Terms of Service
pages at stable public URLs, connect advertiser and publisher registration to
those documents, and prevent language, link, or disclosure drift.

## Tasks

| Item | State | Notes |
|---|---|---|
| L07.1 Add bilingual policy documents | `[+]` | Added English `/privacy.html` and `/terms.html` plus Chinese `.zh.html` siblings, with reciprocal language metadata and matching section order. Privacy copy follows the current Aofei privacy/data-governance behavior and discloses Gmail API `gmail.send`-only use. |
| L07.2 Link the public account journey | `[+]` | Advertiser and publisher registration now link the matching Terms and Privacy editions; home, manuals, login, error, and shared public account footers expose both documents. |
| L07.3 Guard, verify, and review | `[+]` | The copy checker requires all legal pages, core disclosures, stable language-specific links, reciprocal alternates, safe registration new-tab links, and ordered section parity. The parity guard permits only the exact approved legal URL pairs. Repository-wide verification and review pass. |
| Post-closeout plain-text account links | `[+]` | A live English advertiser registration exposed that HTML template rendering changed a URL-escaped space into an HTML character reference inside a `text/plain` Gmail message. Genelet now renders mail files as text templates; all eight advertiser/publisher activation/reset templates prove both legacy and opaque-token query strings parse and round-trip names, addresses, and proofs without semicolon-bearing fragments. The exact public account routes reconstruct that artifact in already issued complete legacy proof URLs before the existing signed-digest validation. |

## Acceptance

- English URLs are `/privacy.html` and `/terms.html`; Chinese URLs are
  `/privacy.zh.html` and `/terms.zh.html`, and every page has a literal language
  link and reciprocal `hreflang` metadata.
- Both advertiser and publisher registration forms preserve their field/action
  contract while linking the Terms and Privacy Policy for acknowledgment.
- The Privacy Policy accurately describes the current contextual-by-default,
  privacy-signal, identifier, retention, external-provider, and Gmail API
  boundaries documented by Aofei.
- Home, manual, login, error, and shared account footers expose the documents in
  the current page language.
- Build, unit tests, vet, race, staticcheck, template/parity/copy/data guards,
  credential scan, and diff hygiene pass, followed by a clean bounded review.

## Boundaries

- The text is an operator-authored legal draft and does not represent legal
  advice or counsel approval. Appropriate legal review remains a production
  release prerequisite.
- No Google Cloud Console mutation, OAuth verification submission, credential
  generation, secret change, live registration, deployment, service restart,
  release, push, or commit is part of L07.
- Source completion does not prove that the stable URLs are live; deployment and
  verification evidence remain in the private W8M operating boundary.
- The owner separately authorized the source commit and W8M deployment on
  2026-09-08; immutable release and activation evidence remains owned by the
  private infrastructure repository.

## Review-fix gate

- Iteration 1 found that the expanded home/manual footer links needed explicit
  narrow-screen wrapping and that a first parity normalization accepted legal
  filenames as substrings rather than exact URLs. Responsive rules and revised
  asset keys were added; the normalization now permits only the exact four legal
  paths, with negative coverage for modified and arbitrary static links. The
  same pass found the analyst login lacked the legal footer present on all other
  login surfaces, so its Chinese and English twins were completed.
- Iteration 2 reviewed the full corrected source and found no remaining
  P1/P2-or-higher source issue. The documents use no runtime data, user input,
  new script, secret, or unsafe rendering boundary; registration action and
  field contracts remain unchanged.
- Post-closeout iteration 3 found the live plain-text link compatibility
  defect and one P2 in the first correction: selecting text-template rendering
  for every file-backed message would remove contextual escaping from an
  explicitly `text/html` message. It also required the outstanding-link seam
  to keep the downstream URL and request-target views consistent and match
  only the four exact public account paths.
- Post-closeout iteration 4 is clean. Genelet selects text or HTML rendering
  from the effective message content type, all browser templates retain their
  existing contextual HTML escaping, and both mail modes have regression
  coverage. The already-issued-link seam is restricted to GET activation/reset
  requests carrying the complete legacy shape and cannot bypass its downstream
  digest validation. Both languages, roles, and default-off legacy/opaque
  branches are covered without activating S07.

## Verification evidence

Passed on 2026-09-08 with `GOWORK=off` where applicable:

```text
GOWORK=off go build ./...
GOWORK=off go test ./...
GOWORK=off go vet ./...
GOWORK=off go test -race ./cmd/unify
GOWORK=off GOTOOLCHAIN=go1.23.5 staticcheck -checks=all,-ST1000,-ST1003,-ST1006 ./...
GOWORK=off go run ./tools/check-templates.go -ext=.g,.e
GOWORK=off go run ./tools/check-parity
GOWORK=off go run ./tools/check-public-copy
./tools/check-public-data.sh
gitleaks git --redact .
git diff --check
```

Observed results: build, tests, vet, race, and staticcheck pass; all 342 action
templates parse with zero failures; parity and public-copy report zero failures;
the public-data guard passes; Gitleaks reports no leaks across 181 commits; the
referenced local legal-page assets exist; and diff hygiene passes.
