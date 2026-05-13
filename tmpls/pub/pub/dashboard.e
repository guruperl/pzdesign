{{ template "header" .}}
{{ template "pubheader" .}}
{{ $item := index .Lists 0}}

          <div class="card">
            <div class="card-header">
              个人资料
            </div>
            <div class="card-body">
Company: {{index .ARGS.p_company 0}}
Email: {{index .ARGS.p_email 0}}

Name: {{$item.firstname}}  {{$item.lastname}}
            </div>
          </div>

          <div class="card">
            <div class="card-header">
              Income of the Last 24 Hours
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
			label: "Impressions",
            data: [{{range $index, $item := .Lists}}{{if $index}},{{end}}{{$item.imps}}{{end}}],
            backgroundColor: '#007bff',
            borderColor: '#007bff',
			fill: false
          },{
			yAxisID: 'y2',
            label: "Clicks",
            data: [{{range $index, $item := .Lists}}{{if $index}},{{end}}{{$item.clis}}{{end}}],
            backgroundColor: '#ff7b00',
            borderColor: '#ff7b00',
            fill: false
          },{
            yAxisID: 'y2',
            label: "Income",
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
              Performance by Top Slots 
            </div>
            <div class="card-body">

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
              Performance by Top Campaigns
            </div>
            <div class="card-body">

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

