{{ template "header" .}}
{{ template "advheader" }}

<div class="account-card theme-advertiser">
  <aside class="account-context">
    <div class="account-context-copy">
      <span class="account-role-mark"><i class="fa fa-bullseye" aria-hidden="true"></i></span>
      <p class="account-eyebrow">Advertiser Account</p>
      <h2>Advertiser Account and Campaign Workflow</h2>
      <p>After creating an account, organize budget, targeting, and creatives across campaigns, ad groups, and individual creatives.</p>
      <ul class="account-benefits">
        <li>Campaign → Ad Group → Creative</li>
        <li>Budget, frequency, and multi-dimensional targeting control</li>
        <li>Signed impression, click, and spend reports</li>
      </ul>
    </div>
    <div class="account-context-footer">
      <a href="/manuals/advertiser.en.html">Read advertiser guide before signing up</a>
    </div>
  </aside>

  <section class="account-form-panel">
    <div class="account-form-heading">
      <span class="account-kicker">Account Registration</span>
      <h1>Create Advertiser Account</h1>
      <p>After submission, complete verification via email. Account activation, balance, and business terms are confirmed by platform operations.</p>
    </div>

    <form id="advForm" action="adv" method="post">
      <input type="hidden" name="action" value="insert">
      <div class="account-form-grid">
        <div class="account-field">
          <label for="domain">Domain</label>
          <div class="account-control"><i class="fa fa-globe" aria-hidden="true"></i><input type="text" name="domain" id="domain" class="form-control" placeholder="advertiser.example.com" autocomplete="url"></div>
        </div>
        <div class="account-field">
          <label for="company">Company Name</label>
          <div class="account-control"><i class="fa fa-building-o" aria-hidden="true"></i><input type="text" name="company" id="company" class="form-control" placeholder="Company or brand name" autocomplete="organization"></div>
        </div>
        <div class="account-field account-field-wide">
          <label for="lastname">Contact Name <span>*</span></label>
          <div class="account-control"><i class="fa fa-user-o" aria-hidden="true"></i><input type="text" name="lastname" id="lastname" class="form-control" placeholder="Representative or contact name" autocomplete="name" required></div>
        </div>
        <div class="account-field account-field-wide">
          <label for="email">Email <span>*</span></label>
          <div class="account-control"><i class="fa fa-envelope-o" aria-hidden="true"></i><input type="email" name="email" id="email" class="form-control" placeholder="name@example.com" autocomplete="email" required></div>
        </div>
        <div class="account-field">
          <label for="passwd">Password <span>*</span></label>
          <div class="account-control"><i class="fa fa-lock" aria-hidden="true"></i><input type="password" name="passwd" id="passwd" class="form-control" placeholder="Enter password (at least 12 characters)" autocomplete="new-password" minlength="12" required></div>
        </div>
        <div class="account-field">
          <label for="confirm">Confirm Password <span>*</span></label>
          <div class="account-control"><i class="fa fa-lock" aria-hidden="true"></i><input type="password" name="confirm" id="confirm" class="form-control" placeholder="Re-enter password" autocomplete="new-password" minlength="12" required></div>
        </div>
        <div class="account-field account-field-wide">
          <label class="account-check" for="agree"><input type="checkbox" id="agree" name="agree" value="agree" required><span>I have read and accept the platform's user agreement and account terms.</span></label>
        </div>
        {{ if .Other.TurnstileSiteKey }}
        <div class="account-field account-field-wide account-human-check">
          <div class="cf-turnstile" data-sitekey="{{ .Other.TurnstileSiteKey }}" data-action="{{ .Other.TurnstileAction }}" data-appearance="interaction-only" data-language="en"></div>
          <p>Human verification provided by Cloudflare to prevent bulk registration and spam.</p>
        </div>
        {{ end }}
      </div>
      <button type="submit" class="account-submit">Submit Registration</button>
      <div class="account-form-links">
        <span>Already have an advertiser account?</span>
        <a href="/goto/adv/e/campaign?action=topics">Log In to Advertiser Dashboard</a>
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
      lastname: 'Please enter contact name',
      passwd: { required: 'Please enter password', minlength: 'Password must be at least 12 characters' },
      confirm: { required: 'Please confirm password', minlength: 'Password must be at least 12 characters', equalTo: 'Passwords do not match' },
      email: 'Please enter a valid email address',
      agree: 'Please accept the platform terms and account rules'
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
