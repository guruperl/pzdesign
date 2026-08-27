{{ template "header" .}}
{{ template "pubheader" }}

<div class="account-card account-card-compact theme-publisher">
  <aside class="account-context">
    <div class="account-context-copy">
      <span class="account-role-mark"><i class="fa fa-envelope-o" aria-hidden="true"></i></span>
      <p class="account-eyebrow">Publisher Account</p>
      <h2>Check Your Email</h2>
      <p>A password reset link has been sent to your registered email.</p>
    </div>
    <div class="account-context-footer"><a href="/goto/pub/e/site?action=topics">Back to Log In</a></div>
  </aside>
  <section class="account-form-panel">
    <div class="account-form-heading">
      <span class="account-kicker">Password Reset</span>
      <h1>Reset Email Sent</h1>
      <p>Check your inbox for the reset link. The link is valid for 24 hours.</p>
    </div>
  </section>
</div>

{{ template "footer" }}
</body>
</html>
