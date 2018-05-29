{{ template "header" }}
{{ template "pubheader" }}

<form class="form" id="pubReset" action=pub method=post>
<input type=hidden name=action value="resetpass">
<input type=hidden name=pub_id value="{{index .ARGS.pub_id 0}}">
<input type=hidden name=email value="{{index .ARGS.email 0}}">
<input type=hidden name=stamp value="{{index .ARGS.stamp 0}}">
<input type=hidden name=firstname value="{{index .ARGS.firstname 0}}">
<input type=hidden name=lastname value="{{index .ARGS.lastname 0}}">
<input type=hidden name=md5 value="{{index .ARGS.md5 0}}">

    <div class="row justify-content-center">
      <div class="col-md-6">
        <div class="card mx-4">
          <div class="card-body p-4">
            <h1>Publisher Password</h1>
            <p class="text-muted">Reset Publisher's Password</p>

            <div class="input-group mb-3">
              <div class="input-group-prepend">
                <span class="input-group-text"><i class="icon-lock"></i></span>
              </div>
              <input type="password" name=passwd id="passwd" class="form-control" placeholder="Password">
            </div>

            <div class="input-group mb-4">
              <div class="input-group-prepend">
                <span class="input-group-text"><i class="icon-lock"></i></span>
              </div>
              <input type="password" name=confirm id="confirm" class="form-control" placeholder="Repeat password">
            </div>

            <div class="input-group mb-4">
            <button type="submit" class="btn btn-block btn-primary">Continue</button>
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
  $('#pubReset').validate({
    rules: {
      passwd: {
        required: true,
        minlength: 5
      },
      confirm: {
        required: true,
        minlength: 5,
        equalTo: '#passwd'
      }
    },
    messages: {
      passwd: {
        required: 'Please provide a password',
        minlength: 'Your password must be at least 5 characters long'
      },
      confirm: {
        required: 'Please provide a password',
        minlength: 'Your password must be at least 5 characters long',
        equalTo: 'Please enter the same password as above'
      }
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
