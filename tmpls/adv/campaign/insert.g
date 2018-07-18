{{template "header" .}}
{{template "campaignheader" .}}

            <div class="row">
                <div class="col-lg-12">
                    <div class="panel panel-primary">
                        <div class="panel-heading">
                            Create New Campaign
                        </div>
                        <!-- /.panel-heading -->
                        <div class="panel-body">
                            {{index .ARGS.campaign_name 0}} 添加成功
                        </div>
                        <!-- /.panel-body -->
                    </div>
                    <!-- /.panel -->
                </div>
                <!-- /.col-lg-6 -->
            </div>
            <!-- /.row -->

{{template "footer" .}}
