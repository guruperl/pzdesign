# Status L04 - Language toggle and entry-point links

**Acceptance.** `GOWORK=off go run ./tools/check-templates.go -ext=.g,.e` and
`GOWORK=off go run ./tools/check-public-copy` both pass with the replaced link
rule. `GOWORK=off go test ./...` green. Manual: from the Chinese front page,
one click reaches the English front page and one more returns; inside an
advertiser and a publisher workspace the toggle swaps the chartag in place and
keeps the current object and action; a fresh visit after toggling honors the
stored preference.

| Item | State | Notes |
|---|---|---|
| Replace the `/goto/*/e/` prohibition in `check-public-copy` | `[ ]` | The current rule forbids `/goto/adv/e/`, `/goto/pub/e/`, `/goto/agent/e/`, and `/goto/admin/e/` anywhere in Chinese pages, which blocks the toggle outright. Replace it with a rule that permits such a link only in the toggle control and still rejects stray deep links into the other edition from body copy. |
| Add the toggle to the public header fragments and both front pages | `[ ]` | `tmpls/web/*.{g,e}`, `www/index.html`, and `www/index.en.html`. The control sets the language preference and navigates to the counterpart page. It must be keyboard reachable with a visible focus state, and labelled in the target language. |
| Add the toggle to all six role header fragments in both chartags | `[ ]` | admin, adv, agent, analyst, pub, and web. The toggle swaps only the chartag segment of the current path and preserves role, object, action, and query. Build the href in the template with the segment written directly rather than assembling it with `print` — the checker rejects assembled query strings in URL contexts. |
| Emit language-correct entry links | `[ ]` | The workspace and registration links currently hardcode `g` — `/goto/adv/g/campaign?action=topics` and `/goto/pub/g/site?action=topics` appear 14 times each, plus the two `/goto/web/g/...` registration links and one agent link. Each edition emits its own chartag, and the negotiated front page therefore hands a visitor an entry link in their language. |
| Confirm no mid-session redirect was introduced | `[ ]` | The preference reaches entry points only. A request to `/goto/adv/g/...` from a viewer whose preference is English must still render Chinese, so a shared link always shows the language it names. Genelet's local-redirect validation stays untouched. |
