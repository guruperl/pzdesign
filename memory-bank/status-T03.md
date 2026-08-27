# Status T03 - English manuals

**Acceptance.** `GOWORK=off go run ./tools/check-public-copy` passes with both
English manuals in the English arm's file list. `./tools/check-public-data.sh`
and `git diff --check` green. Manual: from `www/index.en.html`, both manual
links resolve, and the advertiser and publisher manuals read as complete English
documents with working in-page navigation.

| Item | State | Notes |
|---|---|---|
| Create `www/manuals/advertiser.en.html` | `[ ]` | Sibling file; the Chinese `advertiser.html` stays untouched. Translate from the Chinese HTML, which is the source of truth for this repository. Its operational content tracks `../aofei/docs/advertiser-dsp-agent-manual.zh-CN.md`; when that reference changes, all three editions move together. Reuse `w8m-manual.css`. |
| Create `www/manuals/publisher.en.html` | `[ ]` | Same for the publisher manual, tracking `../aofei/docs/publisher-manual.zh-CN.md`. Keep the integration examples byte-accurate — sample tag and API code must not be paraphrased in translation. |
| Add `hreflang` cross-links and repoint the English landing page | `[ ]` | Pair each manual with its counterpart, and replace the T02 placeholder labels so `index.en.html` links to the English manuals. Add both files to the English arm's checked file list. |
