{{ define "footer" }}


    </div>
    <!-- /#wrapper -->

    <!-- jQuery -->
    <script src="/sb2/vendor/jquery/jquery.min.js"></script>

    <!-- Bootstrap Core JavaScript -->
    <script src="/sb2/vendor/bootstrap/js/bootstrap.min.js"></script>

    <!-- Metis Menu Plugin JavaScript -->
    <script src="/sb2/vendor/metisMenu/metisMenu.min.js"></script>

    <!-- Morris Charts JavaScript
    <script src="/sb2/vendor/raphael/raphael.min.js"></script>
    <script src="/sb2/vendor/morrisjs/morris.min.js"></script>
    <script src="/sb2/data/morris-data.js"></script> -->

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
</script>


    <!-- Custom Theme JavaScript -->
    <script src="/sb2/dist/js/sb-admin-2.js"></script>

</body>

</html>
{{end}}
