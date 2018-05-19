$(document).ready(function() {
  $('#perminent_same').click(function() {
    if(this.checked) {
		$("#perminentStreet, #perminentCity, #perminentStateID, #perminentZip").attr('disabled',true) 
    } else {
		$("#perminentStreet, #perminentCity, #perminentStateID, #perminentZip").removeAttr('disabled')
    }
  })

  $('#dlFile').change(function() {
	$('#forDlFile').text($(this).val())
  })

  $('#studentIDFile').change(function() {
	$('#forStudentIDFile').text($(this).val())
  })

  $('#highSchoolIDFile').change(function() {
	$('#forHighSchoolIDFile').text($(this).val())
  })

  //Change in stateID dropdown generates colID dropdown
  $(document).on('change', '#colStateID', function() {
    var value = $(this).val();
    if (value != "") {
      $.ajax({
        url:"college",
        type:'POST',
        data:{action:"polldown",name:"colStateID",value:value},
        success:function(response) {
          if (response != '') {
            $("#colID").removeAttr('disabled').html(response);
            $("#colMajorID").attr('disabled','disabled').html("<option value=''>-- Major --</option>");
            $("#colDegreeID").attr('disabled','disabled').html("<option value=''>-- Degree --</option>");
          } else {
            $("#colID").attr('disabled','disabled').html("<option value=''>-- College --</option>");
            $("#colMajorID").attr('disabled','disabled').html("<option value=''>-- Major --</option>");
            $("#colDegreeID").attr('disabled','disabled').html("<option value=''>-- Degree --</option>");
          }
        }
      });
    } else {
      $("#colID").attr('disabled','disabled').html("<option value=''>-- College --</option>");
      $("#colMajorID").attr('disabled','disabled').html("<option value=''>-- Major --</option>");
      $("#colDegreeID").attr('disabled','disabled').html("<option value=''>-- Degree --</option>");
    }
  });

  //Change in colID dropdown generates colMajorID dropdown
  $(document).on('change', '#colID', function() {
    var value = $(this).val();
    if (value != "") {
      $.ajax({
        url:"college",
        type:'POST',
        data:{action:"polldown",name:"colID",value:value},
        success:function(response) {
          if (response != '') {
            $("#colMajorID").removeAttr('disabled').html(response);
            $("#colDegreeID").attr('disabled','disabled').html("<option value=''>-- Degree --</option>");
          } else {
            $("#colMajorID").attr('disabled','disabled').html("<option value=''>-- Major --</option>");
            $("#colDegreeID").attr('disabled','disabled').html("<option value=''>-- Degree --</option>");
          }
        }
      });
    } else {
      $("#colMajorID").attr('disabled','disabled').html("<option value=''>-- Major --</option>");
      $("#colDegreeID").attr('disabled','disabled').html("<option value=''>-- Degree --</option>");
    }
  });

  //Change in colMajorID dropdown generates colDegreeID dropdown
  $(document).on('change', '#colMajorID', function() {
    var value = $(this).val();
    if (value != "") {
      $.ajax({
        url:"college",
        type:'POST',
        data:{action:"polldown",name:"colMajorID",value:value},
        success:function(response) {
          if (response != '') {
             $("#colDegreeID").removeAttr('disabled').html(response);
          } else {
             $("#colDegreeID").attr('disabled','disabled').html("<option value=''>-- Degree --</option>");
          }
        }
      });
    } else {
      $("#colDegreeID").attr('disabled','disabled').html("<option value=''>-- Degree --</option>");
    }
  });
});
