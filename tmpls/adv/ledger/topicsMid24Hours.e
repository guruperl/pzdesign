{{ template "header" .}}
{{ template "ledgerheader" .}}

            <div class="row">
                <div class="col-lg-12">
                    <div class="panel panel-primary">
                        <div class="panel-heading">Bid Endpoint Report: Last 24 Hours</div>
                        <div class="panel-body">
                            <canvas class="my-4" id="midChart"></canvas>
                            <script src="/1.0.8/vendors/js/Chart.min.js"></script>
                            <script>
                              var ctx = document.getElementById("midChart");
                              var midChart = new Chart(ctx, {
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
                                    label: "Spend",
                                    data: [{{range $index, $item := .Lists}}{{if $index}},{{end}}{{$item.spend}}{{end}}],
                                    backgroundColor: '#28a745',
                                    borderColor: '#28a745',
                                    fill: false
                                  }]
                                },
                                options: {
                                  responsive: true,
                                  scales: { yAxes: [{
                                    ticks: { beginAtZero: false },
                                    position: 'left',
                                    id: 'y1'
                                  },{
                                    gridLines: { drawOnChartArea: false },
                                    ticks: { beginAtZero: false },
                                    position: 'right',
                                    id: 'y2'
                                  }]},
                                  legend: { display: true }
                                }
                              });
                            </script>
                        </div>
                    </div>
                </div>
            </div>

            <div class="row">
                <div class="col-lg-6">
                    <div class="panel panel-primary">
                        <div class="panel-heading">Bid Endpoint Ranking</div>
                        <div class="panel-body">
                            <div class="table-responsive">
                                <table class="table table-hover">
<thead><tr>
<th>Endpoint</th>
<th>Spend</th>
<th>Impressions</th>
<th>Clicks</th>
<th>CPM</th>
<th>CPC</th>
<th>CTR</th>
</tr></thead>
<tbody>{{with .Other.ledger_topicsMidTopBidders}}{{range .}}
<tr>
<td>{{.bidder_name}}</td>
<td>{{.spend | printf "%.2f"}}</td>
<td>{{.imps}}</td>
<td>{{.clis}}</td>
<td>{{with .cpm}}{{. | printf "%.2f"}}{{else}}0.00{{end}}</td>
<td>{{with .cpc}}{{. | printf "%.4f"}}{{else}}0.0000{{end}}</td>
<td>{{with .ctr}}{{.}}{{else}}0{{end}}</td>
</tr>{{end}}{{end}}
</tbody>
                                </table>
                            </div>
                        </div>
                    </div>
                </div>

                <div class="col-lg-6">
                    <div class="panel panel-primary">
                        <div class="panel-heading">Ad Slot Ranking</div>
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
</tr></thead>
<tbody>{{with .Other.ledger_topicsMidTopSlots}}{{range .}}
<tr>
<td>{{.slot_name}}</td>
<td>{{.spend | printf "%.2f"}}</td>
<td>{{.imps}}</td>
<td>{{.clis}}</td>
<td>{{with .cpm}}{{. | printf "%.2f"}}{{else}}0.00{{end}}</td>
<td>{{with .cpc}}{{. | printf "%.4f"}}{{else}}0.0000{{end}}</td>
<td>{{with .ctr}}{{.}}{{else}}0{{end}}</td>
</tr>{{end}}{{end}}
</tbody>
                                </table>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
{{ template "footer" }}
