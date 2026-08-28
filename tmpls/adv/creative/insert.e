{{ template "header" .}}
{{ template "creativeheader" .}}

            <div class="row">
                <div class="col-lg-12">
                    <div class="panel panel-primary">
                        <div class="panel-heading">
                           Creative Added
                        </div>
                        <!-- /.panel-heading -->
                        <div class="panel-body">
                            Creative “<b>{{index .ARGS.creative_name 0}}</b>” has been added.
                        </div>
                        <!-- /.panel-body -->
                    </div>
                    <!-- /.panel -->
                </div>
                <!-- /.col-lg-6 -->
            </div>
            <!-- /.row -->


{{template "footer"}}
