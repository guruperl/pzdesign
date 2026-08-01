{{ template "header" .}}
{{ template "pubheader" .}}

<div class="account-card account-card-compact theme-publisher">
  <aside class="account-context">
    <div class="account-context-copy">
      <span class="account-role-mark"><i class="fa fa-lock" aria-hidden="true"></i></span>
      <p class="account-eyebrow">流量方（发布商）账户</p>
      <h2>密码重置</h2>
      <p>新密码已经保存，下次登录请使用新密码。</p>
    </div>
    <div class="account-context-footer"><a href="/manuals/publisher.html">查看流量方接入手册</a></div>
  </aside>
  <section class="account-form-panel">
    <span class="account-status-icon"><i class="fa fa-check" aria-hidden="true"></i></span>
    <div class="account-form-heading">
      <span class="account-kicker">密码重置</span>
      <h1>密码已重置</h1>
      <p>请使用新密码登录流量方工作台。</p>
    </div>
    <div class="account-actions">
      <a class="account-action" href="/goto/pub/g/site?action=topics">登录流量方工作台</a>
      <a class="account-action-secondary" href="/">返回首页</a>
    </div>
  </section>
</div>

{{ template "footer" .}}
</body>
</html>
