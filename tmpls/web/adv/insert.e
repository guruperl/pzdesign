{{ template "header" .}}
{{ template "advheader" .}}

<div class="account-card account-card-compact theme-advertiser">
  <aside class="account-context">
    <div class="account-context-copy">
      <span class="account-role-mark"><i class="fa fa-envelope-o" aria-hidden="true"></i></span>
      <p class="account-eyebrow">Advertiser Account</p>
      <h2>Email Verification</h2>
      <p>Verify your registration email before signing in to W8M with your advertiser account.</p>
    </div>
    <div class="account-context-footer"><a href="/manuals/advertiser.html">View the Advertiser User Guide</a></div>
  </aside>
  <section class="account-form-panel">
    <span class="account-status-icon"><i class="fa fa-paper-plane-o" aria-hidden="true"></i></span>
    <div class="account-form-heading">
      <span class="account-kicker">Account Registration</span>
      <h1>Verification Email Sent</h1>
      <p>Open the email and use its verification link to complete account registration.</p>
    </div>
    <div class="account-message">A verification email was sent to <strong>{{index .ARGS.email 0}}</strong>. If you do not see it yet, check your spam folder.</div>
    <div class="account-actions">
      <a class="account-action" href="/goto/adv/e/campaign?action=topics">Go to Advertiser Sign In</a>
      <a class="account-action-secondary" href="/">Back to Home</a>
    </div>
  </section>
</div>

{{ template "footer" .}}
</body>
</html>
