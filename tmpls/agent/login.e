<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no">
  <meta name="description" content="W8M agency workspace sign-in">
  <meta name="theme-color" content="#0b1f33">
  <title>Agency Workspace Sign-in | W8M</title>
  <link href="/vendor/bootstrap/css/bootstrap.min.css" rel="stylesheet">
  <link href="/vendor/font-awesome/css/font-awesome.min.css" rel="stylesheet" type="text/css">
  <link href="/css/w8m-account.css?v=20260828-1" rel="stylesheet">
</head>

<body class="w8m-public-account theme-internal">
  <header class="account-topbar">
    <div class="container">
      <a class="account-brand" href="/">W8M <small>Agency Workspace</small></a>
      <nav class="account-topnav" aria-label="Agency sign-in navigation">
        <a href="mailto:support@w8m.com">Technical Support</a>
        <a href="/">Back to Home</a>
      </nav>
    </div>
  </header>

  <main class="account-stage">
    <div class="container">
      <div class="account-card account-card-compact theme-internal">
        <aside class="account-context">
          <div class="account-context-copy">
            <span class="account-role-mark"><i class="fa fa-check-square-o" aria-hidden="true"></i></span>
            <p class="account-eyebrow">Authorized Account</p>
            <h2>Agency Review and Oversight</h2>
            <p>Review delegated advertisers, campaigns, and ad groups, and complete authorized review work.</p>
          </div>
        </aside>

        <section class="account-form-panel">
          <div class="account-form-heading">
            <span class="account-kicker">Account Sign-in</span>
            <h1>Agency Workspace Sign-in</h1>
            <p>Enter your agency account username and password.</p>
          </div>
          {{if .Errorstr}}<div class="account-alert"><i class="fa fa-info-circle" aria-hidden="true"></i>
            {{if or (eq .Errorstr "Sign In to your account") (eq .Errorstr "Login required.")}}Enter your username and password.
            {{else if eq .Errorstr "Login is expired."}}Your session has expired. Sign in again.
            {{else if eq .Errorstr "Too many failed logins."}}Too many sign-in attempts. Try again later.
            {{else if or (eq .Errorstr "Login incorrect. Please try again.") (eq .Errorstr "Login failed. Please try again.")}}The username or password is incorrect. Try again.
            {{else if eq .Errorstr "Please make sure your browser supports cookie."}}Cookies must be enabled to sign in. Check your browser settings.
            {{else}}We could not sign you in. Check your information and try again.
            {{end}}
          </div>{{end}}
          <form method="post" action="/goto/agent/e/{{ .LoginName }}">
            <input type="hidden" name="{{ .GoURIName }}" value="{{ .GoURI }}">
            <div class="account-field">
              <label for="agent-login-name">Agency Username</label>
              <div class="account-control"><i class="fa fa-user-o" aria-hidden="true"></i><input id="agent-login-name" class="form-control" name="{{.Login}}" type="text" placeholder="Enter your agency username" autocomplete="username" autofocus required></div>
            </div>
            <div class="account-field">
              <label for="agent-login-password">Password</label>
              <div class="account-control"><i class="fa fa-lock" aria-hidden="true"></i><input id="agent-login-password" class="form-control" name="{{.Password}}" type="password" placeholder="Enter your password" autocomplete="current-password" required></div>
            </div>
            <div class="account-field"><label for="agent-login-totp">Authenticator or Recovery Code</label><div class="account-control"><i class="fa fa-shield" aria-hidden="true"></i><input id="agent-login-totp" class="form-control" name="{{.TOTP}}" type="text" placeholder="Enter only when two-factor authentication is enabled" autocomplete="one-time-code"></div></div>
            <button type="submit" class="account-submit">Sign in to the Agency Workspace</button>
          </form>
        </section>
      </div>
    </div>
  </main>

  <footer class="account-footer"><div class="container"><p>&copy; 2026 W8M Network Inc.</p><a href="mailto:support@w8m.com">support@w8m.com</a></div></footer>
</body>
</html>
