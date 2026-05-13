{{ template "header" .}}
{{ template "ledgerheader" .}}

            <div class="row">
                <div class="col-lg-12">
                    <div class="panel panel-primary">
                        <div class="panel-heading">竞价端点最近24小时报告</div>
                        <div class="panel-body">
                            <canvas class="my-4" id="midChart"></canvas>
                            <script src="https://cdnjs.cloudflare.com/ajax/libs/Chart.js/2.7.1/Chart.min.js"></script>
                            <script>
                              var ctx = document.getElementById("midChart");
                              var midChart = new Chart(ctx, {
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
                        <div class="panel-heading">竞价端点排行</div>
                        <div class="panel-body">
                            <div class="table-responsive">
                                <table class="table table-hover">
<thead><tr>
<th>端点</th>
<th>花费</th>
<th>曝光数</th>
<th>点击数</th>
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
<td>{{.cpm | printf "%.2f"}}</td>
<td>{{.cpc | printf "%.4f"}}</td>
<td>{{.ctr}}</td>
</tr>{{end}}{{end}}
</tbody>
                                </table>
                            </div>
                        </div>
                    </div>
                </div>

                <div class="col-lg-6">
                    <div class="panel panel-primary">
                        <div class="panel-heading">广告位排行</div>
                        <div class="panel-body">
                            <div class="table-responsive">
                                <table class="table table-hover">
<thead><tr>
<th>广告位</th>
<th>花费</th>
<th>曝光数</th>
<th>点击数</th>
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
<td>{{.cpm | printf "%.2f"}}</td>
<td>{{.cpc | printf "%.4f"}}</td>
<td>{{.ctr}}</td>
</tr>{{end}}{{end}}
</tbody>
                                </table>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
{{ template "footer" }}
