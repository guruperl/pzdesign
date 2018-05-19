$(function (){
/*
  $.validator.setDefaults( {
    submitHandler: function () {
      alert( 'submitted!' );
    }
  });
*/
  $('#signupForm').validate({
    rules: {
      firstname: 'required',
      lastname: 'required',
      username: {
        required: true,
        minlength: 2
      },
      password: {
        required: true,
        minlength: 5
      },
      confirm_password: {
        required: true,
        minlength: 5,
        equalTo: '#password'
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
      username: {
        required: 'Please enter a username',
        minlength: 'Your username must consist of at least 2 characters'
      },
      password: {
        required: 'Please provide a password',
        minlength: 'Your password must be at least 5 characters long'
      },
      confirm_password: {
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
  $('#continueForm').validate({
    rules: {
      colStateID: 'required',
      colID: 'required',
      colMajorID: 'required',
      doe: 'required',
      dog: 'required',
      currentYear: 'required',
      street: {
        required: true,
        minlength: 5
      },
      city: {
        required: true,
        minlength: 2
      },
      stateID: 'required',
      zip: {
        required: true,
        minlength: 5,
        maxlength: 5,
      },
      ssn: 'required',
      studentID: 'required',
      dob: 'required'
    },
    messages: {
      colStateID: 'Please enter your college state',
      colID: 'Please enter your college',
      colMajorID: 'Please enter your major',
      doe: 'Please enter your enrollment month/year',
      dog: 'Please enter your graduation month/year',
      currentYear: 'Please enter your current school year',
      stateID: 'Please enter your state you are living now',
      street: {
        required: 'Please enter your street number and name',
        minlength: 'Your street is wrong'
      },
      city: {
        required: 'Please enter your city',
        minlength: 'Your city is wrong'
      },
      stateID: 'Please enter your state',
      zip: {
        required: 'Please enter zip code',
        minlength: 'Zip has to be 5 digits only',
        maxlength: 'Zip has to be 5 digits only'
      },
      dob: 'Missing date of birth',
      ssn: 'Please enter your valid social security number',
      schoolID: 'Missing school ID'
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
