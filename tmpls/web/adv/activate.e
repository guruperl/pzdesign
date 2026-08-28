{{ template "header" .}}
{{ template "advheader" .}}

<div class="account-card account-card-compact theme-advertiser">
  <aside class="account-context">
    <div class="account-context-copy">
      <span class="account-role-mark"><i class="fa fa-bullseye" aria-hidden="true"></i></span>
      <p class="account-eyebrow">Advertiser Account</p>
      <h2>Account Verification Complete</h2>
      <p>After signing in, you can create campaigns, ad groups, and creatives, and view delivery reports.</p>
    </div>
    <div class="account-context-footer"><a href="/manuals/advertiser.html">View the Advertiser User Guide</a></div>
  </aside>
  <section class="account-form-panel">
    <span class="account-status-icon"><i class="fa fa-check" aria-hidden="true"></i></span>
    <div class="account-form-heading">
      <span class="account-kicker">Email Verification</span>
      <h1>Advertiser Account Activated</h1>
      <p>Email verification is complete. You can now sign in to the advertiser workspace.</p>
    </div>
    <div class="account-actions">
      <a class="account-action" href="/goto/adv/e/campaign?action=topics">Sign In to the Advertiser Workspace</a>
      <a class="account-action-secondary" href="/">Back to Home</a>
    </div>
  </section>
</div>

{{ template "footer" .}}
</body>
</html>
