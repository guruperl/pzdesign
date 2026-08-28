{{ template "header" .}}
{{ template "advheader" .}}
{{ $item := index .Lists 0}}

            <div class="row">
                <div class="col-lg-12">
                    <div class="panel panel-primary">
                        <div class="panel-heading">
                            Overview
                        </div>
                        <!-- /.panel-heading -->
                        <div class="panel-body">
Company: {{index .ARGS.a_company 0}}
Email: {{index .ARGS.a_email 0}}

Contact: {{$item.firstname}}  {{$item.lastname}}
                        </div>
                        <!-- /.panel-body -->
                    </div>
                    <!-- /.panel -->
                </div>
                <!-- /.col-lg-12 -->
            </div>
            <!-- /.row -->

            <div class="row">
                <div class="col-lg-12">
                    <div class="panel panel-primary">
                        <div class="panel-heading">
                            Report: Last 24 Hours
                        </div>
                        <!-- /.panel-heading -->
                        <div class="panel-body">
{{template "canvas1" .}}
                        </div>
                        <!-- /.panel-body -->
                    </div>
                    <!-- /.panel -->
                </div>
                <!-- /.col-lg-12 -->
            </div>
            <!-- /.row -->

            <div class="row">
                <div class="col-lg-6">
                    <div class="panel panel-primary">
                        <div class="panel-heading">
                            Ad Group Ranking
                        </div>
                        <!-- /.panel-heading -->
                        <div class="panel-body">
                            <div class="table-responsive">
                                <table class="table table-hover">
<thead><tr>
<th>Name</th>
<th>Spend</th>
<th>Impressions</th>
<th>Clicks</th>
<th>CPM</th>
<th>CPC</th>
<th>CTR</th>
</tr></thead>
<tbody>{{with .Other.ledger_topicsAdvTopItems}}{{range .}}
<tr>
<td>{{.item_name}}</td>
<td>{{.spend | printf "%.2f" }}</td>
<td>{{.imps}}</td>
<td>{{.clis}}</td>
<td>{{.cpm | printf "%.2f" }}</td>
<td>{{.cpc | printf "%.4f" }}</td>
<td>{{ .ctr }}</td>
</tr>{{end}}{{end}}
</tbody>
                                </table>
                            </div>
                            <!-- /.table-responsive -->
                        </div>
                        <!-- /.panel-body -->
                    </div>
                    <!-- /.panel -->
                </div>
                <!-- /.col-lg-6 -->

                <div class="col-lg-6">
                    <div class="panel panel-primary">
                        <div class="panel-heading">
                            Ad Slot Ranking
                        </div>
                        <!-- /.panel-heading -->
                        <div class="panel-body">
                            <div class="table-responsive">
                                <table class="table table-hover">
<thead><tr>
<th>Ad Slot</th>
<th>Spend</th>
<th>Impressions</th>
<th>Clicks</th>
<th>CPM</th>
<th>CPC</th>
<th>CTR</th>
<th> </th>
</tr></thead>
<tbody>{{with .Other.ledger_topicsAdvTopSlots}}{{range .}}
<tr>
<td>{{.slot_name}}</td>
<td>{{.spend | printf "%.2f"}}</td>
<td>{{.imps}}</td>
<td>{{.clis}}</td>
<td>{{.cpm | printf "%.2f"}}</td>
<td>{{.cpc | printf "%.4f"}}</td>
<td>{{.ctr}}</td>
<td><a class="btn btn-sm btn-circle btn-danger" href="ac?action=insert&entitytype_id=4&othertype_id=31&other_id={{.site_id}}">Block</a></td>
</tr>{{end}}{{end}}
</tbody>
</table>
                            </div>
                            <!-- /.table-responsive -->
                        </div>
                        <!-- /.panel-body -->
                    </div>
                    <!-- /.panel -->
                </div>
                <!-- /.col-lg-6 -->
            </div>
            <!-- /.row -->
{{ template "footer" }}
