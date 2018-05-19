{{ template "header" .}}
{{ template "creativeheader" .}}

            <div class="row">
                <div class="col-lg-12">
                    <div class="panel panel-primary">
                        <div class="panel-heading">
                           物料添加成功
                        </div>
                        <!-- /.panel-heading -->
                        <div class="panel-body">
                            <b>{{index .ARGS.creative_name 0}} </b>已添加!
                        </div>
                        <!-- /.panel-body -->
                    </div>
                    <!-- /.panel -->
                </div>
                <!-- /.col-lg-6 -->
            </div>
            <!-- /.row -->


{{template "footer"}}
