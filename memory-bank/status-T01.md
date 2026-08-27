# Status T01 - Public account surface in English

**Acceptance.** The parity check passes with all `tmpls/web` entries removed
from its exemption file. `GOWORK=off go run ./tools/check-templates.go
-ext=.g,.e` reports zero failures and `GOWORK=off go run ./tools/check-public-copy`
passes both arms, including the nine-file account-action matrix over `.e`.
Manual: a full English registration, activation, recovery, and reset round-trip
against a local service, with the account mail arriving in English.

| Item | State | Notes |
|---|---|---|
| Regenerate the 5 `tmpls/web` role fragments from their `.g` twins | `[ ]` | These are the layout, header, and footer definitions every public action composes with. They currently sit on the legacy CoreUI stack while `.g` uses `w8m-account.css`; the regenerated `.e` must reference the same stylesheet and carry `lang="en"`. |
| Regenerate `tmpls/web/adv/*.e` (9 files) | `[ ]` | `startnew`, `insert`, `activate`, `startretrieve`, `retrieve`, `startreset`, `resetpass`, and the two `.mail.e` templates. Every `.g` here uses the `account-card theme-advertiser` design and none of the current `.e` does — this is a regeneration, not a copy edit. Coral advertiser role color. |
| Regenerate `tmpls/web/pub/*.e` (9 files) | `[ ]` | Same set for the publisher, teal role color. Publisher mail subjects follow the same pattern as the Chinese ones. |
| Verify the Turnstile bootstrap survives byte-identical | `[ ]` | `adv/startnew`, `adv/startretrieve`, `pub/startnew`, and `pub/startretrieve` already carry it in both editions. The template checker removes only the exact approved string before applying the remote-resource rule, so any whitespace or attribute change fails the build. Only the public site key may reach the template. |
| Preserve the reset-form field contracts | `[ ]` | The copy checker already asserts reset-form fields; the L02 parity check now also compares hidden `action` values and input `name` sets. A translated form that posts different field names is a P1. |
| Remove `tmpls/web` entries from the parity exemption file | `[ ]` | The exemption file shrinks in the same commit that makes the entries unnecessary, so CI proves the gap is closed rather than merely re-listed. |
