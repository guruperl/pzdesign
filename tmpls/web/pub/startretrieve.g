{{ template "header" .}}
{{ template "pubheader" }}

<div class="account-card account-card-compact theme-publisher">
  <aside class="account-context">
    <div class="account-context-copy">
      <span class="account-role-mark"><i class="fa fa-key" aria-hidden="true"></i></span>
      <p class="account-eyebrow">流量方（发布商）账户</p>
      <h2>密码重置</h2>
      <p>输入注册邮箱后，我们会向已注册账户发送密码重置链接。</p>
    </div>
    <div class="account-context-footer"><a href="/goto/pub/g/site?action=topics">返回流量方登录</a></div>
  </aside>
  <section class="account-form-panel">
    <div class="account-form-heading">
      <span class="account-kicker">账户帮助</span>
      <h1>流量方账户密码重置</h1>
      <p>请输入注册流量方账户时使用的邮箱。</p>
    </div>
    <form id="pubRetrieve" action="pub" method="post">
      <input type="hidden" name="action" value="retrieve">
      <div class="account-field">
        <label for="email">注册邮箱</label>
        <div class="account-control"><i class="fa fa-envelope-o" aria-hidden="true"></i><input type="email" name="email" id="email" class="form-control" placeholder="name@example.com" autocomplete="email" required></div>
      </div>
      <button type="submit" class="account-submit">发送密码重置邮件</button>
    </form>
  </section>
</div>

{{ template "footer" }}

<script>
$(function () {
  $('#pubRetrieve').validate({
    rules: {
      email: {
        required: true,
        email: true
      }
    },
    messages: { email: '请输入有效的注册邮箱' },
    errorElement: 'em',
    errorPlacement: function ( error, element ) {
      error.addClass( 'invalid-feedback' );
      error.appendTo(element.closest('.account-field'));
    },
    highlight: function ( element, errorClass, validClass ) {
      $( element ).addClass( 'is-invalid' ).removeClass( 'is-valid' );
    },
    unhighlight: function (element, errorClass, validClass) {
      $( element ).addClass( 'is-valid' ).removeClass( 'is-invalid' );
    }
  });
});
</script>
</body>
</html>
