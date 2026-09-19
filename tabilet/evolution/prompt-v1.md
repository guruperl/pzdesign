# Direction v1 - Bilingual W8M control plane

## Request

Make W8M bilingual, with Chinese as the source of truth:

1. The front page and the Go template surface are in Chinese today.
2. Use the Chinese pages as source of truth and translate the Chinese set of
   pages and templates into an English set.
3. When a web visitor's browser indicates Chinese, return the Chinese front
   page; otherwise return the English front page.
4. A language button lets a visitor switch between Chinese and English.

## Decisions taken

- **English surface strategy:** regenerate the `.e` template set from the
  current `.g` templates — identical markup, stylesheets, and data contract,
  English copy only. The Genelet chartag mechanism already selects the edition,
  so no framework change is needed.
- **Role scope:** all six roles get an English edition — web, adv, pub, agent,
  analyst, and admin.
- **Public scope:** English front page and both English manuals, at full content
  parity with the Chinese landing page including all 18 modals.
- **Negotiation ownership:** a new exact `GET /` and `GET /index.html` handler in
  `cmd/unify`, ahead of the Genelet catch-all. Genelet is not modified.
- **Preference model:** an explicit toggle stores a language cookie that outranks
  `Accept-Language`. The preference reaches entry points only; the chartag in a
  URL stays authoritative, so a shared link always renders the language it names.
- **File layout:** sibling `.en.html` files — `www/index.en.html`,
  `www/manuals/advertiser.en.html`, `www/manuals/publisher.en.html` — leaving
  every existing Chinese URL unchanged.
- **Copy governance:** author `docs/public-english-content-guide.md` mirroring the
  Chinese guide, and extend `tools/check-public-copy` with an English arm.
- **Drift prevention:** a full structural parity check in CI requiring every `.g`
  action to have an `.e` twin with matching form targets, hidden action values,
  and input field names.
- **Acceptance:** the automated pipeline plus a named manual browser pass over
  `Accept-Language` negotiation, the toggle round-trip, and cookie persistence.

## Horizon

The active horizon delivers the public bilingual journey end to end — land in
English, register in English, read English manuals, toggle both ways. Translating
the six role workspaces is approved scope sequenced as the next horizon.
