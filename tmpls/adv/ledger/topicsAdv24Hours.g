{{ template "header" .}}
{{ template "ledgerheader" .}}

			<div class="row">
                <div class="col-lg-12">
                    <div class="panel panel-primary">
                        <div class="panel-heading">
                            最新24小时报表
                        </div>
                        <!-- /.panel-heading -->
                        <div class="panel-body">

	<canvas class="my-4" id="advChart" width="900" height="380"></canvas>

    <!-- Graphs -->
    <script src="https://cdnjs.cloudflare.com/ajax/libs/Chart.js/2.7.1/Chart.min.js"></script>
    <script>
      var ctx = document.getElementById("advChart");
      var advChart = new Chart(ctx, {
        type: 'line',
        data: {
          labels: [{{range $index, $item := .Lists}}{{if $index}},{{end}}"{{$item.hours}}"{{end}}],
          datasets: [{
			yAxisID: 'y1',
			label: "曝光量",
            data: [{{range $index, $item := .Lists}}{{if $index}},{{end}}{{$item.imps}}{{end}}],
            backgroundColor: '#007bff',
            borderColor: '#007bff',
			fill: false
          },{
			yAxisID: 'y2',
            label: "点击数",
            data: [{{range $index, $item := .Lists}}{{if $index}},{{end}}{{$item.clis}}{{end}}],
            backgroundColor: '#ff7b00',
            borderColor: '#ff7b00',
            fill: false
          },{
            yAxisID: 'y2',
            label: "花费",
            data: [{{range $index, $item := .Lists}}{{if $index}},{{end}}{{$item.spend}}{{end}}],
            backgroundColor: '#ff007b',
            borderColor: '#ff007b',
            fill: false
          }]
        },
        options: {
			responsive: true,
            scales: { yAxes: [{
						ticks: { beginAtZero: false },
						position: 'left',
						id: 'y1' },{
						gridLines: { drawOnChartArea: false },
						ticks: { beginAtZero: false },
						position: 'right',
						id: 'y2' }]
					},
            legend: { display: true }
        }
      });
    </script>
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
                            最火创意
                        </div>
                        <!-- /.panel-heading -->
                        <div class="panel-body">
                            <div class="table-responsive">
                                <table class="table table-hover">
<thead><tr>
<th>创意名</th>
<th>花费</th>
<th>曝光次数</th>
<th>点击次数</th>
<th>平均CPM</th>
<th>平均CPC</th>
<th>平均CTR</th>
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
                            最火广告位
                        </div>
                        <!-- /.panel-heading -->
                        <div class="panel-body">
                            <div class="table-responsive">
                                <table class="table table-hover">
<thead><tr>
<th>广告位名称</th>
<th>花费</th>
<th>曝光次数</th>
<th>点击次数</th>
<th>平均CPM</th>
<th>平均CPC</th>
<th>平均CTR</th>
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
{{ template "footer" }}
