# Status T02 - English front page

**Acceptance.** `GOWORK=off go run ./tools/check-public-copy` asserts, in its
English arm, all 8 capability modal IDs, both role-guide modal IDs, all 8
journey modal IDs, and the English required snippets. `GOWORK=off go run
./tools/check-templates.go -ext=.g,.e` and `./tools/check-public-data.sh` stay
green. Manual: with L03 in place, `Accept-Language: en` at `/` serves the English
page and every in-page anchor and modal opens.

| Item | State | Notes |
|---|---|---|
| Create `www/index.en.html` shell, hero, and capability strip | `[ ]` | Sibling file beside the Chinese original, which stays at `www/index.html` untouched. `lang="en"`. Reuse the same `w8m-home.css` and vendored assets — this is a translation, not a redesign. The three feature-strip claims must stay verifiable: no "latest", "best", or unmeasurable superlatives. |
| Translate the 8 capability modals | `[ ]` | DSP, SSP, external DSP/ADX, OpenRTB, measurement and analytics, privacy and identity, traffic quality, accounting and payments, management API, and production operations. Keep the shared purple visual scheme. Preserve the distinction between shipped, default-off, partner-gated, and on-request — an English reader must not conclude a default-off capability is production-open. |
| Translate the role guide tabs and 2 role-guide modals | `[ ]` | Four-step advertiser and publisher flows. Advertiser keeps the warm palette, publisher the cool palette. Content follows the manuals; do not invent product rules on the landing page. |
| Translate the 8 journey modals | `[ ]` | Advertiser campaign, ad group, creative, reporting; publisher source, slot, integration, validation. Each states field purpose, follow-on configuration, the go-live boundary, and a troubleshooting order. Keyboard focus and visible "view details" affordances must survive translation. |
| Add `hreflang` cross-links and footer manual links | `[ ]` | `rel="alternate" hreflang` pairs on both `index.html` and `index.en.html`. Manual links point at the English manuals from T03; until T03 lands, label them as Chinese rather than leaving a dead English link. |
| Add English required-snippet and modal-ID assertions | `[ ]` | Extend the L01 English arm with the same class of structural assertions the Chinese arm makes over `www/index.html`, so the two landing pages stay in step. |
