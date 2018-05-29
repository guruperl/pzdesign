{{ template "header" .}}
{{ template "ledgerheader" .}}

          <div class="card">
            <div class="card-header">
              最近24小时业绩报告
            </div>
            <div class="card-body">

<div style= 'font-size: 17px;'>
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
			label: "曝光数",
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
            label: "收入",
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
                </div>
            </div>

          <div class="card">
            <div class="card-header">
              按照广告位排列业绩
            </div>
            <div class="card-body">

                            <div class="table-responsive">
                                <table class="table table-hover">
<thead><tr>
<th>名称</th>
<th>收入</th>
<th>曝光数</th>
<th>点击数</th>
<th>CPM</th>
<th>CPC</th>
<th>CTR</th>
</tr></thead>
<tbody>{{with .Other.ledger_topicsPubTopSlots}}{{range .}}
<tr>
<td>{{.slot_name}}</td>
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
                    </div>
	
          <div class="card">
            <div class="card-header">
              按照广告活动排列业绩
            </div>
            <div class="card-body">

                            <div class="table-responsive">
                                <table class="table table-hover">
<thead><tr>
<th>活动名称</th>
<th>收入</th>
<th>曝光数</th>
<th>点击数</th>
<th>CPM</th>
<th>CPC</th>
<th>CTR</th>
</tr></thead>
<tbody>{{with .Other.ledger_topicsPubTopCampaigns}}{{range .}}
<tr>
<td>{{.campaign_name}}</td>
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
                        </div>
                    </div>
{{ template "footer" }}

</body>
</html>

