# Product

`pzdesign` is the control-plane surface of the W8M advertising platform. It is
the Go module `github.com/guruperl/pzdesign`, and it delivers the Summer admin
UI and model layer, the HTML template tree, the static asset tree, and the
combined HTTP service command that serves both the admin surfaces and the
sibling Aofei DSP endpoints.

It is one of three sibling checkouts. Aofei owns the DSP runtime, the MySQL
schema, accounting, and the authoritative domain contracts. Genelet owns the web
framework. This repository owns what an operator, an advertiser, an agent, an
analyst, or a publisher sees and edits.

## Users And Surfaces

| Role | What they do here |
|---|---|
| `adv` advertiser | Manage the account, campaigns, ad-groups, creatives, targeting, audience attributes, delivery limits, owned external bidder endpoints, API credentials, and read their own reports |
| `pub` publisher | Manage the account and seller metadata, sites, slots, floors, creative weighting, access control, integration code, credentials, and read their own reports |
| `agent` | Delegated administrator view over advertisers, campaigns, ad-groups, and creatives |
| `analyst` | Read-only reporting, reachable only after an exact permission and resource grant; no product mutation |
| `admin` | Full maintenance, approvals, routing configuration, cache publication triggers, and operational health views |
| public `web` | Chinese and English landing pages, manuals, registration, activation, password recovery, and reset for advertisers and publishers |

## Domain Terminology

Advertiser is `adv` — never 商家 or 商户. Publisher is 流量方 (`pub`) — never
媒体主 or 流量源公司. The delivery hierarchy is campaign, ad-group, creative,
where the database and route name for an ad-group is `item`. Supply is site,
slot. External demand is publicly named 外部 DSP / ADX 接入; `middleman` is an
internal code, configuration, and operations term only. Money is USD, time is
UTC, and pricing is CPM.

English terms map one-to-one onto the Chinese vocabulary and carry the same
constraints: 广告主 is Advertiser, 代理商 is Agency, 流量方 is Publisher, 流量源
is Traffic Source, 广告位 is Ad Slot, and 广告活动 / 广告组 / 广告素材 are
Campaign / Ad Group / Creative. `middleman` stays internal in both languages.

## Language Editions

A **language edition** is a rendering of the same product in one language. It is
expressed as the Genelet **chartag**, the second segment of every route
(`/goto/{role}/{chartag}/{object}`): `g` is Chinese and `e` is English. Both are
configured as `text/html`.

- **Chinese is the source of truth.** English is derived from it. The completed
  public/account surface has an English twin with the same form targets, hidden
  action values, and input field names. Authenticated role workspaces remain
  partial and are tracked by exact parity exceptions until a later translation
  horizon closes them.
- **The chartag in the URL is authoritative.** A shared or bookmarked link always
  renders the language it names. Nothing rewrites a language mid-session.
- **The language preference is an entry-point decision.** A visitor's browser
  languages choose `/`; the front-page language links target the literal
  sibling files `/index.html` and `/index.en.html`, which are authoritative and
  do not negotiate or write a cookie. Explicit account-flow choices may store a
  non-identifying `w8m_lang` preference that outranks the browser on later `/`
  visits. Negotiated responses vary on `Accept-Language` and `Cookie` and are
  private/no-cache. Authenticated role workspaces do not offer a global toggle
  while their English action set is incomplete.
- Account mail follows the chartag of the request that triggered it, so a
  registration started in English produces English mail.

## Business Invariants

- Accounts propose; operators approve. Advertisers and publishers cannot set
  their own `active` state, and any publisher edit to seller metadata revokes
  authorization until an administrator re-approves the exact tuple.
- Scope comes from the verified session, never from the request. Advertiser and
  publisher scopes are overwritten with the authenticated account id before any
  domain call, and a request-supplied id cannot upgrade a role.
- Money is exact. Floors and ad-group costs parse through Aofei's accounting
  types as USD CPM with at most six decimal places, and reports group by
  accounting version rather than merging rows produced under different rules.
- Reporting reads; it never writes financial data. Auditable statements,
  adjustments, corrections, and manual settlement are operator-only Aofei
  commands.
- Rendered values stay ordinary escaped strings. Exactly one trusted HTML
  boundary exists, in Genelet's fixed CSRF input renderer.
- Stored creative source and publisher review URLs are displayed as escaped
  source and never fetched or executed by a control-plane page.
- A template or a hidden navigation item is never an authorization boundary;
  every gate is server-side.
- The repository is public and carries no live account details, runtime logs,
  uploaded media, production paths, or secrets.

## Capability States

Shipping and enabled: advertiser and publisher account lifecycle, the campaign
and creative hierarchy, supply management with floors and integration samples,
access control and channel policy, external bidder profiles and middleman
routing, and per-role reporting where the reporting schema exists.

Present but default-off, each gated by Aofei configuration and refusing to run
without the Summer identity boundary: identity hardening with TOTP and named
permissions, public account abuse protection, the advertiser management API and
its credential lifecycle, traffic-quality review, and hosted funding and payout.

Shipping: the English public edition, including the static front page, manuals,
advertiser/publisher account lifecycle, account mail, login/error guidance,
language negotiation, and public toggle. The authenticated advertiser,
publisher, administrator, agent, and analyst workspaces still have a partial
English template set; their global language controls are deliberately absent so
users cannot be routed into a missing action twin.

Deliberately absent: any form collecting full card or bank credentials. The
`payment`, `cc`, `cheque`, `alipay`, and `wechat` modules are retired,
unregistered, and untracked, and the legacy advertiser account-balance action is
gone. `summer/balance` is a delivery-limit module, not a funding balance.

## Non-Goals

Chinese and English are the only two language editions; no third language and
no general i18n framework are in scope, and translation stays a template-set
concern rather than a runtime message catalog.

This repository does not own the MySQL schema, the auction, bid or delivery
logic, Redis payload contracts, cache publication, accounting, provider
integrations, or production secrets. It does not define reporting metrics; it
displays them with their scope, bounds, and freshness disclosed. A site-wide
Content Security Policy is deliberately deferred in favor of the narrow
iframe sandbox and permissions policy on the delivery sink.
