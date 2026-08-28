<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="utf-8">
  <meta http-equiv="X-UA-Compatible" content="IE=edge">
  <meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no">
  <meta name="description" content="W8M publisher workspace sign-in">
  <meta name="theme-color" content="#0b1f33">
  <title>Publisher Sign-in | W8M</title>
  <link href="/vendor/bootstrap/css/bootstrap.min.css" rel="stylesheet">
  <link href="/vendor/font-awesome/css/font-awesome.min.css" rel="stylesheet" type="text/css">
  <link href="/css/w8m-account.css?v=20260801-3" rel="stylesheet">
</head>

<body class="w8m-public-account theme-publisher">
  <header class="account-topbar">
    <div class="container">
      <a class="account-brand" href="/">W8M <small>Advertising Platform</small></a>
      <nav class="account-topnav" aria-label="Account page navigation">
        <a href="/manuals/publisher.en.html">Publisher Manual</a>
        <a href="/goto/web/e/pub?action=startnew">Create Account</a>
        <a href="/">Back to Home</a>
      </nav>
    </div>
  </header>

  <main class="account-stage">
    <div class="container">
      <div class="account-card theme-publisher">
        <aside class="account-context">
          <div class="account-context-copy">
            <span class="account-role-mark"><i class="fa fa-globe" aria-hidden="true"></i></span>
            <p class="account-eyebrow">Publisher Workspace</p>
            <h2>Traffic Integration Management</h2>
            <p>Manage websites, apps, ad slots, integration code, and traffic reports.</p>
            <ul class="account-benefits">
              <li>Maintain websites, apps, and source hosts</li>
              <li>Generate web ad code and API examples</li>
              <li>View fill, impressions, clicks, and revenue</li>
            </ul>
          </div>
          <div class="account-context-footer"><a href="/manuals/publisher.en.html">Open the Publisher Manual</a></div>
        </aside>

        <section class="account-form-panel">
          <div class="account-form-heading">
            <span class="account-kicker">Account Sign-in</span>
            <h1>Publisher Account Sign-in</h1>
            <p>Use your registered email and password to enter the publisher workspace.</p>
          </div>

          {{if .Errorstr}}<div class="account-alert"><i class="fa fa-info-circle" aria-hidden="true"></i>
            {{if or (eq .Errorstr "Sign In to your account") (eq .Errorstr "Login required.")}}Enter your registered email and password.
            {{else if eq .Errorstr "Login is expired."}}Your session has expired. Sign in again.
            {{else if eq .Errorstr "Too many failed logins."}}Too many sign-in attempts. Try again later.
            {{else if or (eq .Errorstr "Login incorrect. Please try again.") (eq .Errorstr "Login failed. Please try again.")}}The email or password is incorrect. Try again.
            {{else if eq .Errorstr "Please make sure your browser supports cookie."}}Cookies must be enabled to sign in. Check your browser settings.
            {{else}}We could not sign you in. Check your information and try again.
            {{end}}
          </div>{{end}}

          <form method="post" action="{{ .LoginName }}">
            <input type="hidden" name="{{ .GoURIName }}" value="{{ .GoURI }}">
            <div class="account-field">
              <label for="pub-login-email">Email</label>
              <div class="account-control"><i class="fa fa-envelope-o" aria-hidden="true"></i><input id="pub-login-email" class="form-control" name="{{ .Login }}" type="email" placeholder="name@example.com" autocomplete="username" autofocus required></div>
            </div>
            <div class="account-field">
              <label for="pub-login-password">Password</label>
              <div class="account-control"><i class="fa fa-lock" aria-hidden="true"></i><input id="pub-login-password" class="form-control" name="{{ .Password }}" type="password" placeholder="Enter your password" autocomplete="current-password" required></div>
            </div>
            <div class="account-field"><label for="pub-login-totp">Authenticator or Recovery Code</label><div class="account-control"><i class="fa fa-shield" aria-hidden="true"></i><input id="pub-login-totp" class="form-control" name="{{.TOTP}}" type="text" placeholder="Enter only when two-factor authentication is enabled" autocomplete="one-time-code"></div></div>
            <button type="submit" class="account-submit">Sign in to the Publisher Workspace</button>
            <div class="account-form-links">
              <a href="/goto/web/e/pub?action=startretrieve">Forgot password?</a>
              <a href="/goto/web/e/pub?action=startnew">Create a publisher account</a>
            </div>
          </form>
        </section>
      </div>
    </div>
  </main>

  <footer class="account-footer"><div class="container"><p>&copy; 2026 W8M Network Inc.</p><a href="mailto:support@w8m.com">support@w8m.com</a></div></footer>
</body>
</html>
