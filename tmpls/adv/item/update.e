{{template "header" .}}
{{template "campaignheader" .}}


            <div class="row">
                <div class="col-lg-12">
                    <div class="panel panel-primary">
                        <div class="panel-heading">
                           	Update Item 
                        </div>
                        <!-- /.panel-heading -->
                        <div class="panel-body">
                            {{index .ARGS.item_name 0}} updated.
                        </div>
                        <!-- /.panel-body -->
                    </div>
                    <!-- /.panel -->
                </div>
                <!-- /.col-lg-6 -->
            </div>
            <!-- /.row -->

{{template "footer" .}}
