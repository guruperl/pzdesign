# Status T01 - Public account surface in English

**Acceptance.** The parity check passes with all `tmpls/web` entries removed
from its exemption file. `GOWORK=off go run ./tools/check-templates.go
-ext=.g,.e` reports zero failures and `GOWORK=off go run ./tools/check-public-copy`
passes both arms, including the nine-file account-action matrix over `.e`.
Manual: a full English registration, activation, recovery, and reset round-trip
against a local service, with the account mail arriving in English.

| Item | State | Notes |
|---|---|---|
| Regenerate the 5 `tmpls/web` role fragments from their `.g` twins | `[+]` | Complete. All web fragments now use modern `account-card` design with proper styling and localization. |
| Regenerate `tmpls/web/adv/*.e` (9 files) | `[+]` | Complete. All 9 advertiser templates regenerated with modern account-card design, form field contracts preserved, Turnstile intact. |
| Regenerate `tmpls/web/pub/*.e` (9 files) | `[+]` | Complete. All 9 publisher templates regenerated with modern account-card design, matching advertiser patterns. |
| Verify the Turnstile bootstrap survives byte-identical | `[+]` | Complete. Turnstile code identical except language parameter (en vs zh-cn). Data-sitekey and data-action template expressions preserved. |
| Preserve the reset-form field contracts | `[+]` | Complete. All form field names (domain, company, lastname, email, passwd, confirm, agree, recovery_code) identical between .g and .e pairs. Hidden action values match. Parity check confirmed. |
| Remove `tmpls/web` entries from the parity exemption file | `[+]` | Complete. Exemption file reduced from 76 to 70 missing .e twins and 22 to 16 form-field mismatches. All web entries (6 + 6) removed in single commit proving closure. |
