{{ template "header" .}}
{{ template "pubheader" .}}

<div class="account-card account-card-compact theme-publisher">
  <aside class="account-context">
    <div class="account-context-copy">
      <span class="account-role-mark"><i class="fa fa-lock" aria-hidden="true"></i></span>
      <p class="account-eyebrow">Publisher Account</p>
      <h2>Password Reset</h2>
      <p>Your new password has been saved. Use it the next time you sign in.</p>
    </div>
    <div class="account-context-footer"><a href="/manuals/publisher.html">View the Publisher Integration Guide</a></div>
  </aside>
  <section class="account-form-panel">
    <span class="account-status-icon"><i class="fa fa-check" aria-hidden="true"></i></span>
    <div class="account-form-heading">
      <span class="account-kicker">Password Reset</span>
      <h1>Password Reset Complete</h1>
      <p>Use your new password to sign in to the publisher workspace.</p>
    </div>
    <div class="account-actions">
      <a class="account-action" href="/goto/pub/e/site?action=topics">Sign In to the Publisher Workspace</a>
      <a class="account-action-secondary" href="/">Back to Home</a>
    </div>
  </section>
</div>

{{ template "footer" .}}
</body>
</html>
