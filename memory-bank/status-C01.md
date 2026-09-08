# Status C01 - Administrator landing and default-off projection repair

State: `[+]` Complete

## Goal

Restore administrator access after the 2026-09-08 W8M incident without
activating S07, changing account data, or weakening the destination route's
ordinary authentication and authorization checks.

## Tasks

| Item | State | Notes |
|---|---|---|
| C01.1 Preserve the historical administrator landing | `[+]` | Exact English and Chinese `GET /goto/admin/{e,g}/admin` requests redirect to the matching advertiser-administration topics route. Tests prove methods, suffixes, roles, and other paths still reach Genelet. |
| C01.2 Restore the default-off account projection | `[+]` | `cmd/unify` omits a disabled protector from shared storage, and Summer defensively treats an injected typed-nil pointer as absent. Tests retain the real enabled-protector path. |
| C01.3 Verify and review the complete repair | `[+]` | Build, tests, vet, pinned-toolchain staticcheck, race, template/parity/copy/data guards, Gitleaks, and diff hygiene pass. Review iteration 1's HEAD-method gap was fixed; iteration 2 is clean. |

## Acceptance

- A successful login continued to either historical administrator landing URL
  reaches the existing advertiser-administration list in the same language.
- The redirect is exact and cannot bypass Genelet authorization or become an
  open redirect.
- A Summer configuration with S07 disabled selects legacy plaintext account
  projections; only an initialized protector selects ciphertext projections.
- Build, unit tests, vet, race, staticcheck, template/parity/copy/data guards,
  credential scan, and diff hygiene pass, followed by a clean bounded review.

## Boundaries

- No schema, account row, credential, cache, feature activation, frontend,
  Cloudflare/DNS, certificate, or external traffic change is part of C01.
- Source completion does not itself authorize commit, push, release construction,
  or W8M activation; those retain their private deployment controls and evidence.
- No evolution version is needed because C01 restores already documented route
  and default-off optional-service behavior rather than changing direction.

## Evidence

- The live journal showed successful administrator authentication followed by
  a redirect to the nonexistent `admin` component and HTTP 404.
- The existing error-page return route then reached the advertiser list but
  failed because a typed-nil `*genelet.AccountProtector` stored in an interface
  was treated as enabled even though the current Summer config kept S07 off.
- Focused uncached tests cover the mux and storage boundary, including race
  detection. The repository-wide suite passes: 342 templates parse, parity and
  public-copy report zero failures, the public-data guard passes, and Gitleaks
  reports no leak across 180 commits. Local Go is 1.26.1, so staticcheck 0.5.1
  was run successfully with the documented `GOTOOLCHAIN=go1.23.5`.

## Review-fix gate

- Iteration 1 found that Go's `GET` mux pattern also accepts `HEAD`, contrary to
  the exact-GET compatibility contract. Exact `HEAD` patterns now retain the
  Genelet path, and the non-interference test covers that method.
- Iteration 2 reviewed the complete corrected diff after the full gate and
  found no remaining P1/P2-or-higher source issue. The redirect target is
  constant, language-preserving, cache-disabled, and still protected by the
  destination route; enabled and disabled protector states remain distinct.
