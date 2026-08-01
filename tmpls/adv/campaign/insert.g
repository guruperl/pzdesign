{{template "header" .}}
{{template "campaignheader" .}}

            <div class="row">
                <div class="col-lg-12">
                    <div class="panel panel-primary">
                        <div class="panel-heading">
                            广告活动已创建
                        </div>
                        <!-- /.panel-heading -->
                        <div class="panel-body">
                            广告活动“{{index .ARGS.campaign_name 0}}”已创建。
                        </div>
                        <!-- /.panel-body -->
                    </div>
                    <!-- /.panel -->
                </div>
                <!-- /.col-lg-6 -->
            </div>
            <!-- /.row -->

{{template "footer" .}}
