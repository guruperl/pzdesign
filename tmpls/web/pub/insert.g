{{ template "header" .}}
{{ template "pubheader" .}}

<div class="account-card account-card-compact theme-publisher">
  <aside class="account-context">
    <div class="account-context-copy">
      <span class="account-role-mark"><i class="fa fa-envelope-o" aria-hidden="true"></i></span>
      <p class="account-eyebrow">流量方（发布商）账户</p>
      <h2>邮箱验证</h2>
      <p>验证注册邮箱后，才能使用流量方账户登录 W8M。</p>
    </div>
    <div class="account-context-footer"><a href="/manuals/publisher.html">查看流量方接入手册</a></div>
  </aside>
  <section class="account-form-panel">
    <span class="account-status-icon"><i class="fa fa-paper-plane-o" aria-hidden="true"></i></span>
    <div class="account-form-heading">
      <span class="account-kicker">账户注册</span>
      <h1>验证邮件已发送</h1>
      <p>请打开邮件并使用其中的验证链接完成账户注册。</p>
    </div>
    <div class="account-message">验证邮件已发送至：<strong>{{index .ARGS.email 0}}</strong>。如果暂时没有收到，请检查垃圾邮件目录。</div>
    <div class="account-actions">
      <a class="account-action" href="/goto/pub/g/site?action=topics">前往流量方登录</a>
      <a class="account-action-secondary" href="/">返回首页</a>
    </div>
  </section>
</div>

{{ template "footer" .}}
</body>
</html>
