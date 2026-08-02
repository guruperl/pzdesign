{{ template "header" .}}
{{ template "pubheader" }}

<div class="account-card theme-publisher">
  <aside class="account-context">
    <div class="account-context-copy">
      <span class="account-role-mark"><i class="fa fa-globe" aria-hidden="true"></i></span>
      <p class="account-eyebrow">流量方（发布商）账户</p>
      <h2>流量方账户与接入流程</h2>
      <p>创建账户后，登记流量源和广告位，再使用平台生成的网页代码或 API 请求接入。</p>
      <ul class="account-benefits">
        <li>网站 / App → 流量源 → 广告位</li>
        <li>网页广告码与 SDK/API 接入</li>
        <li>填充、展示、点击与收益报表</li>
      </ul>
    </div>
    <div class="account-context-footer">
      <a href="/manuals/publisher.html">注册前阅读流量方接入手册</a>
    </div>
  </aside>

  <section class="account-form-panel">
    <div class="account-form-heading">
      <span class="account-kicker">账户注册</span>
      <h1>注册流量方账户</h1>
      <p>提交后请根据邮件完成验证。账户启用和商务结算规则由平台运营方确认。</p>
    </div>

    <form id="pubForm" action="pub" method="post">
      <input type="hidden" name="action" value="insert">
      <div class="account-form-grid">
        <div class="account-field">
          <label for="domain">主域名或 App Bundle</label>
          <div class="account-control"><i class="fa fa-globe" aria-hidden="true"></i><input type="text" name="domain" id="domain" class="form-control" placeholder="publisher.example.com" autocomplete="url"></div>
        </div>
        <div class="account-field">
          <label for="company">公司名称</label>
          <div class="account-control"><i class="fa fa-building-o" aria-hidden="true"></i><input type="text" name="company" id="company" class="form-control" placeholder="公司或发布商名称" autocomplete="organization"></div>
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
      </div>
      <button type="submit" class="account-submit">提交注册申请</button>
      <div class="account-form-links">
        <span>已有流量方账户？</span>
        <a href="/goto/pub/g/site?action=topics">登录流量方工作台</a>
      </div>
    </form>
  </section>
</div>

{{ template "footer" }}

<script>
$(function () {
  $('#pubForm').validate({
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
