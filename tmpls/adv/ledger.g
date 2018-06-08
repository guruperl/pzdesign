{{ define "ledgerheader" }}
            <div class="row">
                <div class="col-lg-12">
                    <h1 class="page-header">投放业绩概况</h1>
                </div>
                <!-- /.col-lg-12 -->
            </div>
            <!-- /.row -->

{{ end }}


{{ define "canvas1" }}

	<canvas class="my-4" id="advChart"></canvas>

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
{{end}}
