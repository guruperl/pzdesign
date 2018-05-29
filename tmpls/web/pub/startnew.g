{{ template "header" }}
{{ template "pubheader" }}

<form class="form" id="pubForm" action=pub method=post>
<input type=hidden name=action value="insert" />

    <div class="row justify-content-center">
      <div class="col-md-6">
        <div class="card mx-4">
          <div class="card-body p-4">
            <h1>出版商户注册</h1>
            <p class="text-muted">开始注册</p>
            <div class="input-group mb-3">
              <div class="input-group-prepend">
                <span class="input-group-text"><i class="icon-home"></i></span>
              </div>
              <input type="text" name=company id="company" class="form-control" placeholder="公司名">
            </div>

            <div class="input-group mb-3">
              <div class="input-group-prepend">
                <span class="input-group-text"><i class="icon-user"></i></span>
              </div>
              <input type="text" name=firstname id="firstname" class="form-control" placeholder="名">
            </div>

            <div class="input-group mb-3">
              <div class="input-group-prepend">
                <span class="input-group-text"><i class="icon-user"></i></span>
              </div>
              <input type="text" name=lastname id="lastname" class="form-control" placeholder="姓">
            </div>

            <div class="input-group mb-3">
              <div class="input-group-prepend">
                <span class="input-group-text"><i class="icon-envelope"></i></span>
              </div>
              <input type="text" name=email id="email" class="form-control" placeholder="邮箱地址">
            </div>

            <div class="input-group mb-3">
              <div class="input-group-prepend">
                <span class="input-group-text"><i class="icon-lock"></i></span>
              </div>
              <input type="password" name=passwd id="passwd" class="form-control" placeholder="密码">
            </div>

            <div class="input-group mb-4">
              <div class="input-group-prepend">
                <span class="input-group-text"><i class="icon-lock"></i></span>
              </div>
              <input type="password" name=confirm id="confirm" class="form-control" placeholder="再输入密码">
            </div>

            <div class="input-group mb-4">
              <div class="checkbox">
                <label>
                  <input type="checkbox" id="agree" name="agree" value="agree"> 请同意用户协议
                </label>
              </div>
            </div>

            <div class="input-group mb-4">
            <button type="submit" class="btn btn-block btn-primary">提交注册申请</button>
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
  $('#pubForm').validate({
    rules: {
      firstname: 'required',
      lastname: 'required',
      passwd: {
        required: true,
        minlength: 5
      },
      confirm: {
        required: true,
        minlength: 5,
        equalTo: '#passwd'
      },
      email: {
        required: true,
        email: true
      },
      agree: 'required'
    },
    messages: {
      firstname: 'Please enter your firstname',
      lastname: 'Please enter your lastname',
      passwd: {
        required: 'Please provide a password',
        minlength: 'Your password must be at least 5 characters long'
      },
      confirm: {
        required: 'Please provide a password',
        minlength: 'Your password must be at least 5 characters long',
        equalTo: 'Please enter the same password as above'
      },
      email: 'Please enter a valid email address',
      agree: 'Please accept our policy'
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
