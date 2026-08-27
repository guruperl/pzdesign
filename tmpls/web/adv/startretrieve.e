{{ template "header" .}}
{{ template "advheader" }}

<div class="account-card account-card-compact theme-advertiser">
  <aside class="account-context">
    <div class="account-context-copy">
      <span class="account-role-mark"><i class="fa fa-key" aria-hidden="true"></i></span>
      <p class="account-eyebrow">Advertiser Account</p>
      <h2>Password Reset</h2>
      <p>Enter your registration email and we'll send a password reset link to your registered account.</p>
    </div>
    <div class="account-context-footer"><a href="/goto/adv/e/campaign?action=topics">Back to Advertiser Log In</a></div>
  </aside>
  <section class="account-form-panel">
    <div class="account-form-heading">
      <span class="account-kicker">Account Help</span>
      <h1>Advertiser Account Password Reset</h1>
      <p>Please enter the email used to register your advertiser account.</p>
    </div>
    <form id="advRetrieve" action="adv" method="post">
      <input type="hidden" name="action" value="retrieve">
      <div class="account-field">
        <label for="email">Registration Email</label>
        <div class="account-control"><i class="fa fa-envelope-o" aria-hidden="true"></i><input type="email" name="email" id="email" class="form-control" placeholder="name@example.com" autocomplete="email" required></div>
      </div>
      {{ if .Other.TurnstileSiteKey }}
      <div class="account-human-check">
        <div class="cf-turnstile" data-sitekey="{{ .Other.TurnstileSiteKey }}" data-action="{{ .Other.TurnstileAction }}" data-appearance="interaction-only" data-language="en"></div>
        <p>Human verification provided by Cloudflare to prevent bulk reset emails.</p>
      </div>
      {{ end }}
      <button type="submit" class="account-submit">Send Password Reset Email</button>
    </form>
  </section>
</div>

{{ template "footer" }}

{{ if .Other.TurnstileSiteKey }}<script src="https://challenges.cloudflare.com/turnstile/v0/api.js" async defer></script>{{ end }}
<script>
$(function () {
  $('#advRetrieve').validate({
    rules: {
      email: {
        required: true,
        email: true
      }
    },
    messages: { email: 'Please enter a valid registration email' },
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
