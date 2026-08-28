{{ define "footer" }}

        </div>
        <!-- /#page-wrapper -->
      <!-- Footer -->
      <footer class="sticky-footer bg-white">
        <div class="container my-auto">
          <div class="copyright text-center my-auto">
            <span>Copyright &copy; W8M 2025</span>
          </div>
        </div>
      </footer>
      <!-- End of Footer -->
    </div>
    <!-- /#wrapper -->

    <!-- jQuery -->
    <script src="/sb2/vendor/jquery/jquery.min.js"></script>

    <!-- Bootstrap Core JavaScript -->
    <script src="/sb2/vendor/bootstrap/js/bootstrap.min.js"></script>

    <!-- Metis Menu Plugin JavaScript -->
    <script src="/sb2/vendor/metisMenu/metisMenu.min.js"></script>

<script>
$(document).ready(function(){
    $("#ao_inherit").click(function(){
        $("#myP").addClass('hidden');
    });
    $("#ao_black").click(function(){
        $("#myP").removeClass('hidden');
    });
    $("#ao_white").click(function(){
        $("#myP").removeClass('hidden');
    });
});

  $(document).ready(function(){
    $('#startnewPopup,#editPopup,#balancePopup,#creativePopup').on('click',function(){
      var dataTITLE = $(this).attr('data-title');
      var dataURL = $(this).attr('data-href');
      $('#d-title').text(dataTITLE);
      $('#d-body').load(dataURL,function(){
        $('#myModal').modal({show:true});
      });
    });
  });

</script>


    <!-- Custom Theme JavaScript -->
    <script src="/sb2/dist/js/sb-admin-2.js"></script>

</body>

</html>
{{end}}
