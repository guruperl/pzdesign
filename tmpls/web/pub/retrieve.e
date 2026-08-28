{{ template "header" .}}
{{ template "pubheader" .}}

<div class="account-card account-card-compact theme-publisher">
  <aside class="account-context">
    <div class="account-context-copy">
      <span class="account-role-mark"><i class="fa fa-key" aria-hidden="true"></i></span>
      <p class="account-eyebrow">Publisher Account</p>
      <h2>Password Reset</h2>
      <p>Password reset links are sent only to registered publisher account email addresses.</p>
    </div>
    <div class="account-context-footer"><a href="/manuals/publisher.html">View the Publisher Integration Guide</a></div>
  </aside>
  <section class="account-form-panel">
    <span class="account-status-icon"><i class="fa fa-envelope-o" aria-hidden="true"></i></span>
    <div class="account-form-heading">
      <span class="account-kicker">Password Reset</span>
      <h1>Password Reset Email Sent</h1>
      <p>If this email address is registered, we will send a password reset link.</p>
    </div>
    <div class="account-message">Check your inbox and spam folder, then use the link in the email to set a new password.</div>
    <div class="account-actions">
      <a class="account-action" href="/goto/pub/e/site?action=topics">Back to Publisher Sign In</a>
      <a class="account-action-secondary" href="/">Back to Home</a>
    </div>
  </section>
</div>

{{ template "footer" .}}
</body>
</html>
