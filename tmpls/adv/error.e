<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>Advertiser Dashboard Notice | W8M</title>
  <link href="/vendor/bootstrap/css/bootstrap.min.css" rel="stylesheet">
  <link href="/css/w8m-account.css?v=20260828-1" rel="stylesheet">
</head>
<body class="w8m-public-account theme-advertiser">
  <main class="account-stage"><div class="container"><div class="account-card account-card-compact theme-advertiser">
    <aside class="account-context"><div class="account-context-copy"><p class="account-eyebrow">Advertiser Dashboard</p>{{if eq .Code 503}}<h2>This Feature Is Not Available Yet</h2><p>This environment has not completed the configuration or data migration required for this feature.</p>{{else}}<h2>We Could Not Complete This Action</h2><p>Check the submitted information or sign in again.</p>{{end}}</div></aside>
    <section class="account-form-panel"><div class="account-form-heading"><span class="account-kicker">Request Result</span>{{if eq .Code 503}}<h1>This Feature Is Not Enabled</h1><p>Existing advertising features are unaffected. This page will become available after the feature is enabled.</p>{{else}}<h1>The Request Was Not Completed</h1><p>If the problem continues, contact technical support and provide the error number below.</p>{{end}}</div><div class="account-actions"><a class="account-action" href="/goto/adv/e/campaign?action=topics">Return to Advertiser Dashboard</a><a class="account-action-secondary" href="mailto:support@w8m.com">Contact Technical Support</a></div><p class="account-support-reference">Error number: {{.Code}}</p></section>
  </div></div></main>
</body>
</html>
