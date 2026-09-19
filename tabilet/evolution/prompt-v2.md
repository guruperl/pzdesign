# Direction v2 - Public legal and Google user-data surface

## Request

Create and add Privacy Policy and Terms of Service pages in `pzdesign` after the
operator confirmed that W8M did not expose those documents and needed a public
privacy URL for the existing Gmail API account-mail integration.

## Decisions taken

- **Stable URLs:** English uses `/privacy.html` and `/terms.html`; Chinese uses
  `/privacy.zh.html` and `/terms.zh.html`.
- **Bilingual structure:** Chinese and English documents use reciprocal
  `hreflang` metadata and the same ordered section identifiers.
- **Registration contract:** advertiser and publisher signup explicitly link
  the matching Terms and Privacy editions without changing form actions or
  fields.
- **Discovery:** home, manual, login, error, and shared account footers expose
  both documents in the current language.
- **Privacy truth:** disclosures follow the current Aofei privacy/data-governance
  contract, including contextual-by-default handling and concrete retention
  boundaries.
- **Google user data:** the Privacy Policy states that the Gmail API integration
  requests `gmail.send` only for platform account mail and does not read Gmail,
  contacts, Drive, or profile data or use Google API data for targeting, sale,
  transfer, or general-purpose AI training.
- **Governance:** automated checks enforce files, URLs, links, language metadata,
  section parity, and core disclosures. Operator legal review and live
  deployment remain outside source completion.

## Horizon

The direction ends with a verified source change in `pzdesign`. It does not
change Google Cloud Console settings, generate credentials, submit OAuth
verification, deploy W8M, or establish counsel approval.
