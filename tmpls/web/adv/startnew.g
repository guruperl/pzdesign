{{ template "header" .}}
{{ template "advheader" }}

<div class="account-card theme-advertiser">
  <aside class="account-context">
    <div class="account-context-copy">
      <span class="account-role-mark"><i class="fa fa-bullseye" aria-hidden="true"></i></span>
      <p class="account-eyebrow">广告主账户</p>
      <h2>广告主账户与投放流程</h2>
      <p>创建账户后，按广告活动、广告组和广告素材的层级组织预算、定向与创意。</p>
      <ul class="account-benefits">
        <li>广告活动 → 广告组 → 广告素材</li>
        <li>预算、频次与多维定向管理</li>
        <li>签名展示、点击与花费报表</li>
      </ul>
    </div>
    <div class="account-context-footer">
      <a href="/manuals/advertiser.html">注册前阅读广告主手册</a>
    </div>
  </aside>

  <section class="account-form-panel">
    <div class="account-form-heading">
      <span class="account-kicker">账户注册</span>
      <h1>注册广告主账户</h1>
      <p>提交后请根据邮件完成验证。账户启用、余额和商务规则由平台运营方确认。</p>
    </div>

    <form id="advForm" action="adv" method="post">
      <input type="hidden" name="action" value="insert">
      <div class="account-form-grid">
        <div class="account-field">
          <label for="domain">企业域名</label>
          <div class="account-control"><i class="fa fa-globe" aria-hidden="true"></i><input type="text" name="domain" id="domain" class="form-control" placeholder="advertiser.example.com" autocomplete="url"></div>
        </div>
        <div class="account-field">
          <label for="company">公司名称</label>
          <div class="account-control"><i class="fa fa-building-o" aria-hidden="true"></i><input type="text" name="company" id="company" class="form-control" placeholder="公司或品牌名称" autocomplete="organization"></div>
        </div>
        <div class="account-field account-field-wide">
          <label for="lastname">联系人姓名 <span>*</span></label>
          <div class="account-control"><i class="fa fa-user-o" aria-hidden="true"></i><input type="text" name="lastname" id="lastname" class="form-control" placeholder="负责人或联系人姓名" autocomplete="name" required></div>
        </div>
        <div class="account-field account-field-wide">
          <label for="email">电子邮箱 <span>*</span></label>
          <div class="account-control"><i class="fa fa-envelope-o" aria-hidden="true"></i><input type="email" name="email" id="email" class="form-control" placeholder="name@example.com" autocomplete="email" required></div>
        </div>
        <div class="account-field">
          <label for="passwd">密码 <span>*</span></label>
          <div class="account-control"><i class="fa fa-lock" aria-hidden="true"></i><input type="password" name="passwd" id="passwd" class="form-control" placeholder="输入密码（至少 12 个字符）" autocomplete="new-password" minlength="12" required></div>
        </div>
        <div class="account-field">
          <label for="confirm">确认密码 <span>*</span></label>
          <div class="account-control"><i class="fa fa-lock" aria-hidden="true"></i><input type="password" name="confirm" id="confirm" class="form-control" placeholder="再次输入密码" autocomplete="new-password" minlength="12" required></div>
        </div>
        <div class="account-field account-field-wide">
          <label class="account-check" for="agree"><input type="checkbox" id="agree" name="agree" value="agree" required><span>我已阅读并接受平台用户协议及账户使用规则。</span></label>
        </div>
        {{ if .Other.TurnstileSiteKey }}
        <div class="account-field account-field-wide account-human-check">
          <div class="cf-turnstile" data-sitekey="{{ .Other.TurnstileSiteKey }}" data-action="{{ .Other.TurnstileAction }}" data-appearance="interaction-only" data-language="zh-cn"></div>
          <p>人机验证由 Cloudflare 提供，用于防止批量注册和垃圾邮件。</p>
        </div>
        {{ end }}
      </div>
      <button type="submit" class="account-submit">提交注册申请</button>
      <div class="account-form-links">
        <span>已有广告主账户？</span>
        <a href="/goto/adv/g/campaign?action=topics">登录广告主工作台</a>
      </div>
    </form>
  </section>
</div>

{{ template "footer" }}

{{ if .Other.TurnstileSiteKey }}<script src="https://challenges.cloudflare.com/turnstile/v0/api.js" async defer></script>{{ end }}
<script>
$(function () {
  $('#advForm').validate({
    rules: {
      lastname: 'required',
      passwd: { required: true, minlength: 12 },
      confirm: { required: true, minlength: 12, equalTo: '#passwd' },
      email: { required: true, email: true },
      agree: 'required'
    },
    messages: {
      lastname: '请输入联系人姓名',
      passwd: { required: '请输入密码', minlength: '密码至少需要 12 个字符' },
      confirm: { required: '请再次输入密码', minlength: '密码至少需要 12 个字符', equalTo: '两次输入的密码不一致' },
      email: '请输入有效的电子邮箱',
      agree: '请先接受平台用户协议及账户使用规则'
    },
    errorElement: 'em',
    errorPlacement: function (error, element) {
      error.addClass('invalid-feedback');
      error.appendTo(element.closest('.account-field'));
    },
    highlight: function (element) { $(element).addClass('is-invalid').removeClass('is-valid'); },
    unhighlight: function (element) { $(element).addClass('is-valid').removeClass('is-invalid'); }
  });
});
</script>
</body>
</html>
