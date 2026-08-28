{{ template "header" .}}
{{ template "pubheader" .}}

<div class="account-card account-card-compact theme-publisher">
  <aside class="account-context">
    <div class="account-context-copy">
      <span class="account-role-mark"><i class="fa fa-globe" aria-hidden="true"></i></span>
      <p class="account-eyebrow">Publisher Account</p>
      <h2>Account Verification Complete</h2>
      <p>After signing in, you can create traffic sources and ad slots, and get web ad code or API integration examples.</p>
    </div>
    <div class="account-context-footer"><a href="/manuals/publisher.html">View the Publisher Integration Guide</a></div>
  </aside>
  <section class="account-form-panel">
    <span class="account-status-icon"><i class="fa fa-check" aria-hidden="true"></i></span>
    <div class="account-form-heading">
      <span class="account-kicker">Email Verification</span>
      <h1>Publisher Account Activated</h1>
      <p>Email verification is complete. You can now sign in to the publisher workspace.</p>
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
