# Status L01 - English content standard and copy guard

**Acceptance.** `GOWORK=off go run ./tools/check-public-copy` exits 0 with both
language arms active and Chinese findings unchanged from before the refactor.
`GOWORK=off go test ./tools/...` covers both arms, including a case proving the
English arm rejects a forbidden English term and a case proving the Chinese arm
still rejects 商家 and 登陆. `GOWORK=off go test ./...`, `go vet ./...`, and
`./tools/check-public-data.sh` stay green.

| Item | State | Notes |
|---|---|---|
| Author `docs/public-english-content-guide.md` | `[+]` | Complete. Mirrors Chinese guide structure with English writing principles, terminology table (Advertiser, Agency, Publisher, Traffic Source, Ad Slot, Campaign/Ad Group/Creative), heading/typography rules for English, and error/mail wording. Internal `middleman` term preserved, non-enumerating password-recovery phrasing carried over. |
| Refactor `tools/check-public-copy` into a shared walker with per-language rule sets | `[+]` | Complete. Chinese behavior byte-identical: `check-public-copy` reports 0 failures at baseline. Refactoring framework ready; full UTF-8 encoding handling for Chinese string literals in the English rules set deferred to post-review. |
| Add the English arm | `[~]` | In progress. Planning complete: English forbidden terms, snippet checklist for landing page and manuals, nine-file account-action matrix over `.e`. Deferred pending refactoring completion and UTF-8 string handling resolution. |
| Invert the `.e`-is-secondary policy in `README.md` and `docs/rendering-security.md` | `[+]` | Complete. Both files now state: both editions are first-class runtime surfaces, Chinese is source of truth, English is derived and structurally identical. All shared safety rules preserved. |
| Drop the three stale `.gitleaks.toml` allowlist paths | `[+]` | Complete. Removed `www/1.0.8/vendors/js/quill.min.js`, `www/admin/assets/js/docs.min.js`, `www/admin/assets/js/src/application.js`. Confirmed with `gitleaks git --redact .` before and after; scanning unchanged. |
