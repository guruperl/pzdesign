{{ template "header" .}}
{{ template "advheader" .}}

<div class="account-card account-card-compact theme-advertiser">
  <aside class="account-context">
    <div class="account-context-copy">
      <span class="account-role-mark"><i class="fa fa-lock" aria-hidden="true"></i></span>
      <p class="account-eyebrow">广告主账户</p>
      <h2>设置新密码</h2>
      <p>请为广告主账户设置新密码，并确保两次输入一致。</p>
    </div>
    <div class="account-context-footer"><a href="/goto/adv/g/campaign?action=topics">返回广告主登录</a></div>
  </aside>
  <section class="account-form-panel">
    <div class="account-form-heading">
      <span class="account-kicker">密码重置</span>
      <h1>设置新密码</h1>
      <p>当前密码规则要求至少 5 个字符。</p>
    </div>
    <form id="advReset" action="adv" method="post">
      <input type="hidden" name="action" value="resetpass">
      <input type="hidden" name="adv_id" value="{{index .ARGS.adv_id 0}}">
      <input type="hidden" name="email" value="{{index .ARGS.email 0}}">
      <input type="hidden" name="stamp" value="{{index .ARGS.stamp 0}}">
      <input type="hidden" name="firstname" value="{{index .ARGS.firstname 0}}">
      <input type="hidden" name="lastname" value="{{index .ARGS.lastname 0}}">
      <input type="hidden" name="md5" value="{{index .ARGS.md5 0}}">
      <div class="account-field">
        <label for="passwd">新密码</label>
        <div class="account-control"><i class="fa fa-lock" aria-hidden="true"></i><input type="password" name="passwd" id="passwd" class="form-control" placeholder="输入新密码" autocomplete="new-password" minlength="5" required></div>
      </div>
      <div class="account-field">
        <label for="confirm">确认新密码</label>
        <div class="account-control"><i class="fa fa-lock" aria-hidden="true"></i><input type="password" name="confirm" id="confirm" class="form-control" placeholder="再次输入新密码" autocomplete="new-password" minlength="5" required></div>
      </div>
      <button type="submit" class="account-submit">保存新密码</button>
    </form>
  </section>
</div>

{{ template "footer" .}}
<script>
$(function () {
  $('#advReset').validate({
    rules: {
      passwd: { required: true, minlength: 5 },
      confirm: { required: true, minlength: 5, equalTo: '#passwd' }
    },
    messages: {
      passwd: { required: '请输入新密码', minlength: '密码至少需要 5 个字符' },
      confirm: { required: '请再次输入新密码', minlength: '密码至少需要 5 个字符', equalTo: '两次输入的密码不一致' }
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
