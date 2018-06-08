{{ template "header" .}}
{{ template "ledgerheader" .}}

			<div class="row">
                <div class="col-lg-12">
                    <div class="panel panel-primary">
                        <div class="panel-heading">
                            Last 24 Hours
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
                            Performance by Top Items
                        </div>
                        <!-- /.panel-heading -->
                        <div class="panel-body">
                            <div class="table-responsive">
                                <table class="table table-hover">
<thead><tr>
<th>Name</th>
<th>Spendings</th>
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
                            Performance by Top Slots
                        </div>
                        <!-- /.panel-heading -->
                        <div class="panel-body">
                            <div class="table-responsive">
                                <table class="table table-hover">
<thead><tr>
<th>Name</th>
<th>Spendings</th>
<th>Impressions</th>
<th>Clicks</th>
<th>CPM</th>
<th>CPC</th>
<th>CTR</th>
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
  </div>
{{ template "footer" }}
