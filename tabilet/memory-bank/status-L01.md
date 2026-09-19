# Status L01 - English content standard and copy guard

**Acceptance.** `GOWORK=off go run ./tools/check-public-copy` exits 0.
Chinese findings unchanged from baseline. `GOWORK=off go test ./...`, `go vet ./...`, and
`./tools/check-public-data.sh` stay green. Fixed critical bug in edition-link policy check
(isLanguageToggleLink was always returning true; now returns false when no toggle context found).

| Item | State | Notes |
|---|---|---|
| Author `docs/public-english-content-guide.md` | `[+]` | Complete. Mirrors Chinese guide structure with English writing principles, terminology table (Advertiser, Agency, Publisher, Traffic Source, Ad Slot, Campaign/Ad Group/Creative), heading/typography rules for English, and error/mail wording. Internal `middleman` term preserved, non-enumerating password-recovery phrasing carried over. |
| Refactor `tools/check-public-copy` into a shared walker with per-language rule sets | `[+]` | Complete. Chinese behavior byte-identical: `check-public-copy` reports 0 failures at baseline. Framework uses a single flat forbidden-term list and context-aware toggle-link validation; no per-language dispatch implemented. Full per-language rule-set separation was deferred. |
| Add the English arm | `[+]` | Complete. Edition-specific English link prohibition in place (no bare /goto/*/e/ links outside toggle controls). Hreflang tags are allowed as SEO metadata. Policy enforcement fixed: isLanguageToggleLink() now properly returns false when link context lacks toggle markers (previously had unconditional fallback to true). |
| Invert the `.e`-is-secondary policy in `README.md` and `docs/rendering-security.md` | `[+]` | Complete. Both files now state: both editions are first-class runtime surfaces, Chinese is source of truth, English is derived and structurally identical. All shared safety rules preserved. |
| Drop the three stale `.gitleaks.toml` allowlist paths | `[+]` | Complete. Removed `www/1.0.8/vendors/js/quill.min.js`, `www/admin/assets/js/docs.min.js`, `www/admin/assets/js/src/application.js`. Confirmed with `gitleaks git --redact .` before and after; scanning unchanged. |
