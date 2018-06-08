{{template "header" .}}
{{template "campaignheader" .}}


            <div class="row">
                <div class="col-lg-12">
                    <div class="panel panel-primary">
                        <div class="panel-heading">
                           修改更新	
                        </div>
                        <!-- /.panel-heading -->
                        <div class="panel-body">
                            {{index .ARGS.item_name 0}} 更新。
                        </div>
                        <!-- /.panel-body -->
                    </div>
                    <!-- /.panel -->
                </div>
                <!-- /.col-lg-6 -->
            </div>
            <!-- /.row -->

{{template "footer" .}}
