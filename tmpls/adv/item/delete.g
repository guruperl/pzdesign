{{template "header" .}}
{{template "campaignheader" .}}


            <div class="row">
                <div class="col-lg-12">
                    <div class="panel panel-primary">
                        <div class="panel-heading">
                            广告组已删除
                        </div>
                        <!-- /.panel-heading -->
                        <div class="panel-body">
                            广告组“{{index .ARGS.item_name 0}}”已删除。
                        </div>
                        <!-- /.panel-body -->
                    </div>
                    <!-- /.panel -->
                </div>
                <!-- /.col-lg-6 -->
            </div>
            <!-- /.row -->

{{template "footer" .}}
