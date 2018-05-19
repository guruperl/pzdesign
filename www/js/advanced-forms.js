$(function (){
  $("#date").mask("99/99/9999");
  $("#phone").mask("(999) 999-9999");
  $("#ssn").mask("999-99-9999");
  $("#dob").mask("99/99/9999");
  $("#doe").mask("99/9999");
  $("#dog").mask("99/9999");
  $("#zip").mask("99999");
  $("#perminentZip").mask("99999");
  $("#ccn").mask("9999 9999 9999 9999");

  $('#select2-1, #select2-2, #select2-4').select2({
    theme: "bootstrap"
  });

  $('#select2-3').select2({
    theme: "bootstrap",
    placeholder: "Your Favorite Football Team",
    allowClear: true
  });

  $('input[name="daterange"]').daterangepicker({
    opens: 'left',
    ranges: {
      'Today': [moment(), moment()],
      'Yesterday': [moment().subtract(1, 'days'), moment().subtract(1, 'days')],
      'Last 7 Days': [moment().subtract(6, 'days'), moment()],
      'Last 30 Days': [moment().subtract(29, 'days'), moment()],
      'This Month': [moment().startOf('month'), moment().endOf('month')],
      'Last Month': [moment().subtract(1, 'month').startOf('month'), moment().subtract(1, 'month').endOf('month')]
    }
  });

})
