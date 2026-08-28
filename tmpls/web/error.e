<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no">
  <meta name="description" content="W8M request status">
  <meta name="theme-color" content="#0b1f33">
  <title>Request Status | W8M</title>
  <link href="/vendor/bootstrap/css/bootstrap.min.css" rel="stylesheet">
  <link href="/vendor/font-awesome/css/font-awesome.min.css" rel="stylesheet" type="text/css">
  <link href="/css/w8m-account.css?v=20260828-1" rel="stylesheet">
</head>

<body class="w8m-public-account theme-internal">
  <header class="account-topbar">
    <div class="container">
      <a class="account-brand" href="/">W8M <small>Advertising Platform</small></a>
      <nav class="account-topnav" aria-label="Error page navigation">
        <a href="mailto:support@w8m.com">Technical Support</a>
        <a href="/">Return Home</a>
      </nav>
    </div>
  </header>

  <main class="account-stage">
    <div class="container">
      <div class="account-card account-card-compact theme-internal">
        <aside class="account-context">
          <div class="account-context-copy">
            <span class="account-role-mark"><i class="fa fa-info" aria-hidden="true"></i></span>
            <p class="account-eyebrow">Request Status</p>
            <h2>We Could Not Complete This Action</h2>
            <p>Review the guidance or return home and choose the correct account entry.</p>
          </div>
        </aside>

        <section class="account-form-panel">
          <span class="account-status-icon"><i class="fa fa-exclamation" aria-hidden="true"></i></span>
          <div class="account-form-heading">
            <span class="account-kicker">Request Result</span>
            {{if eq .Code 404}}
              <h1>The Page Does Not Exist or the Link Has Expired</h1>
              <p>Check the address. For an email link, start account verification or password reset again.</p>
            {{else if eq .Code 405}}
              <h1>This Request Method Is Not Supported</h1>
              <p>Return to the previous page and use the button or form provided there.</p>
            {{else if eq .Code 429}}
              <h1>Too Many Requests</h1>
              <p>Wait before trying again and do not repeatedly submit the same request.</p>
            {{else if or (eq .Code 401) (eq .Code 403)}}
              <h1>This Request Is Not Authorized</h1>
              <p>Use the correct account entry and a valid link, then sign in or try again.</p>
            {{else if or (eq .Code 400) (eq .Code 1037) (eq .Code 1040)}}
              <h1>Some Information Is Missing or Invalid</h1>
              <p>Return to the previous page and check all required fields and formats.</p>
            {{else if eq .Code 3102}}
              <h1>The Submitted Information Could Not Be Verified</h1>
              <p>Check that both passwords match, or open the newest verification link from your email.</p>
            {{else if eq .Code 3104}}
              <h1>This Account Information Is Already in Use</h1>
              <p>Use different account information or return to the appropriate login page.</p>
            {{else}}
              <h1>The Request Is Temporarily Unavailable</h1>
              <p>Try again later. If the problem continues, contact technical support and provide the error number below.</p>
            {{end}}
          </div>
          <div class="account-actions">
            <a class="account-action" href="/">Return Home</a>
            <a class="account-action-secondary" href="mailto:support@w8m.com">Contact Technical Support</a>
          </div>
          <p class="account-support-reference">Error number: {{.Code}}</p>
        </section>
      </div>
    </div>
  </main>

  <footer class="account-footer"><div class="container"><p>&copy; 2026 W8M Network Inc.</p><a href="mailto:support@w8m.com">support@w8m.com</a></div></footer>
</body>
</html>
