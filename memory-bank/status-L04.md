# Status L04 - Language toggle and entry-point links

**Acceptance.** `GOWORK=off go run ./tools/check-templates.go -ext=.g,.e` and
`GOWORK=off go run ./tools/check-public-copy` both pass with the replaced link
rule. `GOWORK=off go test ./...` green. Manual: from the Chinese front page,
one click reaches the English front page and one more returns (fixed via explicit
/goto/web/e/ and /goto/web/g/ routing); inside all six role workspaces (admin,
adv, agent, analyst, pub, web) the toggle swaps the chartag in place and keeps
the current object and action; a fresh visit after toggling honors the stored
preference.

| Item | State | Notes |
|---|---|---|
| Replace the `/goto/*/e/` prohibition in `check-public-copy` | `[+]` | Complete. Removed blanket prohibition from forbidden list. Added context-aware check that allows these links only within toggle-context markers (class contains "toggle"/"lang" or data-lang-toggle attribute). Fixed bug where `isLanguageToggleLink` always returned true by restructuring it to return false when no toggle context found. Stray deep links in body copy now rejected. |
| Add the toggle to the public header fragments and both front pages | `[+]` | Complete. Added toggle to both front pages: www/index.html (→ English) and www/index.en.html (→ Chinese). Labeled in target language. Keyboard accessible with data-lang-toggle attribute. Fixed routing: explicit handlers for `/goto/web/g/` and `/goto/web/e/` now serve the correct front-page file directly. |
| Add the toggle to all six role header fragments in both chartags | `[+]` | Complete. All six role header pairs now have toggle markup: admin/start.g|e, adv/start.g|e, agent/start.g|e, analyst/start.g|e, pub/start.g|e, web/start.g|e. Toggle uses data-lang-toggle attribute (no assembled hrefs per checker rules). JavaScript handler in end.g|e swaps chartag: `/goto/role/g/` ↔ `/goto/role/e/`. |
| Emit language-correct entry links | `[+]` | Complete. Chinese front page emits `/goto/web/g/` and `/goto/adv/g/` entry links. English front page emits `/goto/web/e/` and `/goto/adv/e/` entry links. Verified across all 18 account templates. |
| Confirm no mid-session redirect was introduced | `[+]` | Complete. Language negotiation (Accept-Language + w8m_lang cookie) applies only to front page entry. Authenticated/workspace URLs with explicit chartag (g or e) render that language regardless of preference. Shared link `/goto/adv/g/...` always shows Chinese. No redirect loop. |
