{{ template "header" .}}
{{ template "pubheader" .}}

<div class="account-card account-card-compact theme-publisher">
  <aside class="account-context">
    <div class="account-context-copy">
      <span class="account-role-mark"><i class="fa fa-key" aria-hidden="true"></i></span>
      <p class="account-eyebrow">流量方（发布商）账户</p>
      <h2>密码重置</h2>
      <p>密码重置链接只会发送到已经注册的流量方账户邮箱。</p>
    </div>
    <div class="account-context-footer"><a href="/manuals/publisher.html">查看流量方接入手册</a></div>
  </aside>
  <section class="account-form-panel">
    <span class="account-status-icon"><i class="fa fa-envelope-o" aria-hidden="true"></i></span>
    <div class="account-form-heading">
      <span class="account-kicker">密码重置</span>
      <h1>密码重置邮件已发送</h1>
      <p>如果该邮箱已注册，我们将发送密码重置链接。</p>
    </div>
    <div class="account-message">请检查收件箱和垃圾邮件目录，并使用邮件中的链接设置新密码。</div>
    <div class="account-actions">
      <a class="account-action" href="/goto/pub/g/site?action=topics">返回流量方登录</a>
      <a class="account-action-secondary" href="/">返回首页</a>
    </div>
  </section>
</div>

{{ template "footer" .}}
</body>
</html>
