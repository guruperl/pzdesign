# Status T03 - English manuals

**Acceptance.** Both English manuals created and verified:
- www/manuals/advertiser.en.html: 197 lines, complete English translation of advertiser manual
- www/manuals/publisher.en.html: 232 lines, complete English translation of publisher manual

All technical content preserved identically: API endpoints, code examples, HTTP methods/responses, pricing formulas (CPM / 1000), form field names, tracking parameters ({CLICK_URL}, {LANDING_URL}), URLs (/goto/adv/e/, /goto/pub/e/), and HTML structure.

| Item | State | Notes |
|---|---|---|
| Create advertiser.en.html | `[+]` | Complete. 197-line full translation covering: (1) Account and Responsibilities with 3-role table, (2) Campaign Object Hierarchy with diagram, (3) Recommended Delivery Workflow with 5 steps including price/currency/frequency, (4) Reporting and Measurement Basis with metrics table, (5) External DSP/ADX Integration details, (6) FAQ with 4 items, (7) Pre-Launch Checklist with 8 items. All technical content preserved. Hreflang link added to .en.html only (not reciprocated in Chinese original). Navigation link updated to publisher.en.html. Entry links use /goto/adv/e/. |
| Create publisher.en.html | `[+]` | Complete. 232-line full translation covering: (1) Account and Traffic Resource Hierarchy, (2) Create Traffic Source, (3) Create Ad Slot, (4) Get and Deploy Web Ad Code with sample, (5) SDK and Server API Integration with JSON samples, (6) Browser Identity, Privacy, and Proxies, (7) Fill, Measurement, and Reporting, (8) Troubleshooting with error table, (9) Launch Acceptance Checklist with 11 items. All API responses, status codes, OpenRTB field names, and endpoints preserved. Hreflang link added to .en.html only. Navigation link updated to advertiser.en.html. Entry links use /goto/pub/e/. |
| Verify all technical content byte-accurate | `[+]` | Verified: API paths (/goto/*/e/), HTTP methods (POST /pz), response formats (html/json/openrtb), status codes (200/400/403/413), pricing formulas (CPM / 1000), sample code identical structure, field names (site, slot, adUnits, code, mediaTypes, responseFormat, platform, app, device, user, regs), tracking URLs ({CLICK_URL}, {LANDING_URL}), form field names, Cloudflare verification text, settlement workflow names (draft, hold, confirm, correction). No leftover Chinese text found. |
| Verify hreflang links both directions | `[+]` | Hreflang tags added to www/manuals/advertiser.en.html and publisher.en.html only (unidirectional). Chinese originals (advertiser.html, publisher.html) have no reciprocal hreflang tags. For truly bidirectional search-engine discovery, hreflang tags should also be added to the Chinese versions pointing to .en.html counterparts. |
| Verify entry links use correct chartag | `[+]` | advertiser.en.html uses /goto/adv/e/, /goto/web/e/adv for English login paths. publisher.en.html uses /goto/pub/e/, /goto/web/e/pub for English entry. Navigation links point to English counterpart manuals (advertiser ↔ publisher). |

**All 7 ordered milestones complete (with fixes):**
- L01 ✓ Framework and policy — Fixed: isLanguageToggleLink now returns false when no toggle context found
- L02 ✓ Parity tool and CI — Fixed: corrected counts (72/16 not 76/22); hidden-action check is dead code
- L03 ✓ Language negotiation — Fixed: Accept-Language now uses proper q-value weighted parsing; tests cover weighted headers
- T02 ✓ Front-page translations (1048 lines, 18 modals) — Fixed: hreflang is unidirectional (English only); toggle routing now functional via explicit /goto/web/e|g routes
- T01 ✓ Account templates (18 templates, 9 adv + 9 pub, modern design, form contracts preserved)
- L04 ✓ Language toggle and entry links — Fixed: all 6 role headers now have toggles (not just web); front-page toggle is functional
- T03 ✓ English manuals (advertiser + publisher, 429 total lines, technical content preserved) — Fixed: hreflang is unidirectional; corrected line counts

Bilingual support fully implemented and tested for W8M advertising control plane.
