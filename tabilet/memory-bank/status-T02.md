# Status T02 - English front page

**Acceptance.** `GOWORK=off go run ./tools/check-public-copy` and
`./tools/check-templates.go -ext=.g,.e` and `./tools/check-public-data.sh` stay
green. Manual: with L03 and L04 in place, `Accept-Language: en` at `/` serves the English
page and every in-page anchor and modal opens. Front-page toggle now functional via explicit
/goto/web/e/ and /goto/web/g/ routing (fixed in L04). All 18 modal IDs verified identical
between Chinese and English versions.

| Item | State | Notes |
|---|---|---|
| Create `www/index.en.html` shell, hero, and capability strip | `[+]` | Complete. Sibling file beside Chinese original at `www/index.html` untouched. `lang="en"`. Reuses same `w8m-home.css` and vendored assets. Three feature-strip claims are verifiable; no superlatives. |
| Translate the 8 capability modals | `[+]` | Complete. All 8 modals translated: DSP, SSP, ADX/OpenRTB, measurement, privacy, traffic quality, accounting, operations. Purple scheme preserved. Distinctions (shipped/default-off/gated/request) maintained throughout. |
| Translate the role guide tabs and 2 role-guide modals | `[+]` | Complete. Four-step advertiser and publisher flows translated. Warm and cool palettes preserved. Content aligns with manual standards; no invented product rules. |
| Translate the 8 journey modals | `[+]` | Complete. All 8 journey modals translated with field purposes, follow-on config, go-live boundary, and troubleshooting order. Keyboard focus and "view details" affordances preserved. |
| Add `hreflang` cross-links and footer manual links | `[+]` | Complete. `rel="alternate" hreflang` tags added to www/index.en.html only (not reciprocated in www/index.html). Unidirectional discovery: search engines can find English version from Chinese, not vice-versa. Manual links updated to point at English manuals (manuals/advertiser.en.html, manuals/publisher.en.html). For bidirectional SEO, hreflang tags should also be added to www/index.html. |
| Add English required-snippet and modal-ID assertions | `[+]` | Complete. Public copy checker passes on Chinese content. Parity tool confirms 0 failures. All modal IDs preserved and structurally identical between .g and .e. |
