{{ template "header" .}}
{{ template "creativeheader" .}}

            <div class="row">
                <div class="col-lg-12">
                    <div class="panel panel-primary">
                        <div class="panel-heading">
                            New Creatived Added
                        </div>
                        <!-- /.panel-heading -->
                        <div class="panel-body">
                            {{index .ARGS.creative_name 0}} added.
                        </div>
                        <!-- /.panel-body -->
                    </div>
                    <!-- /.panel -->
                </div>
                <!-- /.col-lg-6 -->
            </div>
            <!-- /.row -->


{{template "footer"}}
