{{ template "header" .}}
{{ template "advheader" .}}

<div class="account-card account-card-compact theme-advertiser">
  <aside class="account-context">
    <div class="account-context-copy">
      <span class="account-role-mark"><i class="fa fa-bullseye" aria-hidden="true"></i></span>
      <p class="account-eyebrow">广告主账户</p>
      <h2>账户验证完成</h2>
      <p>登录后可以创建广告活动、广告组和广告素材，并查看投放报表。</p>
    </div>
    <div class="account-context-footer"><a href="/manuals/advertiser.html">查看广告主使用手册</a></div>
  </aside>
  <section class="account-form-panel">
    <span class="account-status-icon"><i class="fa fa-check" aria-hidden="true"></i></span>
    <div class="account-form-heading">
      <span class="account-kicker">邮箱验证</span>
      <h1>广告主账户已激活</h1>
      <p>邮箱验证已完成。您现在可以登录广告主工作台。</p>
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
