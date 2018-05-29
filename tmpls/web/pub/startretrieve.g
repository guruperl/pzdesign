{{ template "header" }}
{{ template "pubheader" }}

<form class="form" id="pubRetrieve" action=pub method=post>
<input type=hidden name=action value="retrieve">

    <div class="row justify-content-center">
      <div class="col-md-6">
        <div class="card mx-4">
          <div class="card-body p-4">
            <h1>找回密码</h1>
            <p class="text-muted">媒体商户由此开始</p>

            <div class="input-group mb-3">
              <div class="input-group-prepend">
                <span class="input-group-text"><i class="icon-envelope"></i></span>
              </div>
              <input type="text" name=email id="email" class="form-control" placeholder="注册用电子邮箱">
            </div>

            <div class="input-group mb-4">
            <button type="submit" class="btn btn-block btn-primary">提交并继续</button>
            </div>

          </div>
        </div>
      </div>
    </div>
</form>

{{ template "footer" }}

  <!-- Custom scripts required by form validation-->
  <script>
$(function (){
  $('#pubRetrieve').validate({
    rules: {
      email: {
        required: true,
        email: true
      }
    },
    messages: {
      email: 'Please enter a valid email address'
    },
    errorElement: 'em',
    errorPlacement: function ( error, element ) {
      error.addClass( 'invalid-feedback' );
      if ( element.prop( 'type' ) === 'checkbox' ) {
        error.insertAfter( element.parent( 'label' ) );
      } else {
        error.insertAfter( element );
      }
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
