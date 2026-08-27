{{ template "header" .}}
{{ template "advheader" .}}

<div class="account-card account-card-compact theme-advertiser">
  <aside class="account-context">
    <div class="account-context-copy">
      <span class="account-role-mark"><i class="fa fa-lock" aria-hidden="true"></i></span>
      <p class="account-eyebrow">Advertiser Account</p>
      <h2>Set New Password</h2>
      <p>Set a new password for your advertiser account and verify both entries match.</p>
    </div>
    <div class="account-context-footer"><a href="/goto/adv/e/campaign?action=topics">Back to Advertiser Log In</a></div>
  </aside>
  <section class="account-form-panel">
    <div class="account-form-heading">
      <span class="account-kicker">Password Reset</span>
      <h1>Set New Password</h1>
      <p>New password must be at least 12 characters.</p>
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
        <label for="passwd">New Password</label>
        <div class="account-control"><i class="fa fa-lock" aria-hidden="true"></i><input type="password" name="passwd" id="passwd" class="form-control" placeholder="Enter new password" autocomplete="new-password" minlength="12" required></div>
      </div>
      <div class="account-field">
        <label for="confirm">Confirm New Password</label>
        <div class="account-control"><i class="fa fa-lock" aria-hidden="true"></i><input type="password" name="confirm" id="confirm" class="form-control" placeholder="Re-enter new password" autocomplete="new-password" minlength="12" required></div>
      </div>
      <div class="account-field"><label for="recovery_code">Recovery Code (required if dual auth enabled)</label><div class="account-control"><i class="fa fa-shield" aria-hidden="true"></i><input type="text" name="recovery_code" id="recovery_code" class="form-control" placeholder="XXXX-XXXX-XXXX-XXXX" autocomplete="one-time-code"></div></div>
      <button type="submit" class="account-submit">Save New Password</button>
    </form>
  </section>
</div>

{{ template "footer" .}}
<script>
$(function () {
  $('#advReset').validate({
    rules: {
      passwd: { required: true, minlength: 12 },
      confirm: { required: true, minlength: 12, equalTo: '#passwd' }
    },
    messages: {
      passwd: { required: 'Please enter new password', minlength: 'Password must be at least 12 characters' },
      confirm: { required: 'Please confirm new password', minlength: 'Password must be at least 12 characters', equalTo: 'Passwords do not match' }
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
