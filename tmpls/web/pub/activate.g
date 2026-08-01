{{ template "header" .}}
{{ template "pubheader" .}}

<div class="account-card account-card-compact theme-publisher">
  <aside class="account-context">
    <div class="account-context-copy">
      <span class="account-role-mark"><i class="fa fa-globe" aria-hidden="true"></i></span>
      <p class="account-eyebrow">流量方（发布商）账户</p>
      <h2>账户验证完成</h2>
      <p>登录后可以创建流量源和广告位，并获取网页广告码或 API 接入样例。</p>
    </div>
    <div class="account-context-footer"><a href="/manuals/publisher.html">查看流量方接入手册</a></div>
  </aside>
  <section class="account-form-panel">
    <span class="account-status-icon"><i class="fa fa-check" aria-hidden="true"></i></span>
    <div class="account-form-heading">
      <span class="account-kicker">邮箱验证</span>
      <h1>流量方账户已激活</h1>
      <p>邮箱验证已完成。您现在可以登录流量方工作台。</p>
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
