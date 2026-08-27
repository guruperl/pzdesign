# W8M English Content Guidelines

These guidelines apply to W8M English-language pages and account mail, including the landing page, user manuals, registration, login, email verification, password reset, error pages, and authenticated workspaces. Follow them when adding new pages and editing existing templates.

## Writing Principles

- Headlines describe the page content or current task, not with slogans, promises, or emotional appeals.
- Body copy states what users can do now, then describes limitations, next steps, and whom to contact.
- Describe the system by user-observable behavior; database, cache, and key storage implementation appears only in operations documentation.
- Industry terminology is acceptable on first use with context or explanation.
- Buttons use specific actions: "Send password reset email", "Log in to advertiser workspace", not vague terms like "Continue" or "Get started now".
- Do not promise outcomes, fill rates, traffic quality, real-time delivery, or campaign performance not covered in product contracts.

## Standard Terminology

| Use | Meaning and constraints |
|---|---|
| Advertiser | An `adv` account. Never "merchant", "vendor", or alternate forms. |
| Agency | An `agent` account or delegated reviewer; not equivalent to an advertiser account or external DSP. |
| Publisher | A `pub` account. On first mention, the full form is acceptable; later reference to "publisher" alone. Never "media owner" or alternate forms. |
| Traffic Source | A website, app, or platform-approved upstream connection managed by a publisher. |
| Ad Slot | An advertising display position managed and accessible by a publisher; avoid "ad inventory" as an account name. |
| Campaign, Ad Group, Creative | Advertiser delivery tiers; when needed, first mention may note the English equivalents. Database and route names remain `item` internally. |
| External DSP / ADX Demand Integration | The unified public-facing capability name; "middleman" is an internal code, configuration, and operations term only. |
| Log in | Unified spelling. Never "log in to", "sign in", or alternate forms. |
| Sign up, password reset | Unified account-flow terminology. |

## Headlines and Typography

- The home page main headline is "W8M advertising delivery and traffic access platform".
- Advertiser login pages use "advertising delivery management"; publisher login pages use "traffic access management".
- Status pages use result-oriented headlines: "verification email sent", "account activated", "password reset email sent", "password reset".
- Home page main headline: 42px desktop maximum, 34px mobile maximum; section headlines 32px desktop, 28px mobile; account-page headlines 30px desktop, 28px mobile.
- Body text should generally be at least 16px with line height appropriate for English reading; 14px is acceptable in information-dense modals with detail lists, but must use at least 1.7× line height, with headlines, descriptions, status text, and action entry points remaining at least 16px. All-caps English text, excessive letter-spacing, and decorative subheads are not used on public pages.
- Headlines, navigation, and action controls use a consistent English sans-serif font stack; introductions, explanations, card body text, modal body text, and FAQs use a similar but reading-optimized sans-serif stack. Capability cards and platform ability cards may use 14px and at least 1.6× line height for supplementary text, maintaining a clear hierarchy between title and detail-link entry.

## Home Page Platform Capabilities

- The home page top feature bar states "DSP, SSP, and ADX unified workflow", "OpenRTB 2.5 controlled compatibility and open API", "privacy signals, traffic quality, and observability", covering verifiable platform scope without "latest", "most advanced", or other unverifiable claims.
- "Platform Capabilities" uses eight clickable cards and corresponding detail modals, covering DSP, SSP, external DSP / ADX, OpenRTB, measurement and analytics, privacy and identity, traffic quality, accounting and payments, management API, and production operations.
- Eight platform capability cards and their modals use a unified visual treatment; feature type and enable boundaries are stated in headline and body text, not color-coded.
- Home page does not display internal milestone numbers. Copy describes implemented behavior only and distinguishes between "launched", "off by default", "partner-gated", and "provided per request".
- OpenRTB is written uniformly as "OpenRTB 2.5 controlled compatibility specification"; never imply support for all optional extensions or external compliance certification.
- App delivery uses the current `/pz` protocol and JSON/OpenRTB responses; without maintainable release artifacts, do not name SDKs/API examples as already-provided native Android/iOS SDKs.
- Two-factor authentication, fine-grained permissions, traffic quality, advertiser management API, hosted payments, and external demand-side traffic explain enable prerequisites; never claim live-production status based on code availability alone.
- Single-region availability describes technical mechanism and evidence requirements only; without continuous production measurement and vendor recovery records, do not claim 99.9% uptime or production RPO/RTO.

## Home Page Role Guides

- "Usage Guides" begin with advertiser and publisher tabs outlining a four-step flow, then provide one detailed modal per role; modal content follows the complete English manual and does not introduce product rules on the landing page.
- Advertiser modals explain the account, campaign, ad group, creative, and targeting configuration sequence, clarifying the boundaries between "saved", operations review, running cache, and live production delivery.
- Both advertiser and publisher eight-step flows use clickable cards and independent modals. Cards must have visible "view details" affordances and support keyboard focus; modals explain field purpose, follow-on configuration, go-live boundary, and troubleshooting order.
- Publisher modals explain traffic sources, ad slots, web ad tag, and App/API integration, emphasizing the latest credentials, source verification, privacy signals, secure rendering, and proper no-fill semantics.
- Both modals retain links to the workspace and complete manual; the home page provides only a summary sufficient for initial configuration and troubleshooting — complete field documentation, examples, error tables, and acceptance checklists remain in the role manual.
- Advertiser uses a warm color palette; publisher uses a cool palette. Modals reorganize vertically on mobile and maintain body text at least 16px, visible keyboard focus, and clear close buttons.

## Errors and Account Mail

- Public error pages explain the user's next steps and do not display raw framework, database, or configuration errors; error numbers can be cited for support reference.
- Password recovery results always use "If that email address is registered, we'll send a password reset link", never confirming whether an account exists.
- Mail subject lines list brand and account type first, then task: e.g. "W8M advertiser account email verification".
- Mail uses "Hello [name]:" opening, explains link purpose, and signs "W8M advertising platform"; when no expiration is configured, omit a specific time limit.

## Maintenance Checklist

After editing English pages, run:

```bash
GOWORK=off go run ./tools/check-templates.go -ext=.e
GOWORK=off go run ./tools/check-public-copy
git diff --check
```

Markdown manuals in Aofei at `docs/advertiser-dsp-agent-manual.en.md` and `docs/publisher-manual.en.md` are the content baseline; HTML versions in `www/manuals/` should update in the same change when user-facing behavior changes.

Copy and database fields are always rendered as ordinary strings to `html/template`, never converted to raw HTML for formatting preservation. Creative-review and approval pages display only escaped creative source content — they do not load or execute creative code. For changes involving links, reports, scripts, mail, or creative display, also follow [rendering-security.md](rendering-security.md) and run its hostile-input regression tests.
