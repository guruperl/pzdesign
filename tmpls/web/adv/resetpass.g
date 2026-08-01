{{ template "header" .}}
{{ template "advheader" .}}

<div class="account-card account-card-compact theme-advertiser">
  <aside class="account-context">
    <div class="account-context-copy">
      <span class="account-role-mark"><i class="fa fa-lock" aria-hidden="true"></i></span>
      <p class="account-eyebrow">广告主账户</p>
      <h2>密码重置</h2>
      <p>新密码已经保存，下次登录请使用新密码。</p>
    </div>
    <div class="account-context-footer"><a href="/manuals/advertiser.html">查看广告主使用手册</a></div>
  </aside>
  <section class="account-form-panel">
    <span class="account-status-icon"><i class="fa fa-check" aria-hidden="true"></i></span>
    <div class="account-form-heading">
      <span class="account-kicker">密码重置</span>
      <h1>密码已重置</h1>
      <p>请使用新密码登录广告主工作台。</p>
    </div>
    <div class="account-actions">
      <a class="account-action" href="/goto/adv/g/campaign?action=topics">登录广告主工作台</a>
      <a class="account-action-secondary" href="/">返回首页</a>
    </div>
  </section>
</div>

{{ template "footer" .}}
</body>
</html>
