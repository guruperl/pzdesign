{{ template "header" .}}
{{ template "ledgerheader" .}}

<div class="card">
  <div class="card-header">最近24小时 Middleman 结算</div>
  <div class="card-body">
    <div class="table-responsive">
      <table class="table table-sm table-hover">
<thead><tr>
<th>小时</th>
<th>Win</th>
<th>Loss</th>
<th>曝光</th>
<th>点击</th>
<th>Charge</th>
<th>Pay</th>
<th>Margin</th>
<th>Margin Rate</th>
<th>回调错误</th>
</tr></thead>
<tbody>{{range .Lists}}
<tr>
<td>{{.hours}}</td>
<td>{{.wins}}</td>
<td>{{.losses}}</td>
<td>{{.imps}}</td>
<td>{{.clis}}</td>
<td>{{.charge_spend | printf "%.2f"}}</td>
<td>{{.pay_spend | printf "%.2f"}}</td>
<td>{{.margin_spend | printf "%.2f"}}</td>
<td>{{.margin_rate | printf "%.4f"}}</td>
<td>{{.forward_errors}}</td>
</tr>{{end}}
</tbody>
      </table>
    </div>
  </div>
</div>

<div class="card mt-3">
  <div class="card-header">竞价端点排行</div>
  <div class="card-body">
    <div class="table-responsive">
      <table class="table table-sm table-hover">
<thead><tr>
<th>端点</th>
<th>Win</th>
<th>Loss</th>
<th>曝光</th>
<th>点击</th>
<th>Charge</th>
<th>Pay</th>
<th>Margin</th>
<th>Margin Rate</th>
<th>回调错误</th>
</tr></thead>
<tbody>{{with .Other.ledger_topicsMidTopBidders}}{{range .}}
<tr>
<td>{{.bidder_name}}</td>
<td>{{.wins}}</td>
<td>{{.losses}}</td>
<td>{{.imps}}</td>
<td>{{.clis}}</td>
<td>{{.charge_spend | printf "%.2f"}}</td>
<td>{{.pay_spend | printf "%.2f"}}</td>
<td>{{.margin_spend | printf "%.2f"}}</td>
<td>{{.margin_rate | printf "%.4f"}}</td>
<td>{{.forward_errors}}</td>
</tr>{{end}}{{end}}
</tbody>
      </table>
    </div>
  </div>
</div>

<div class="card mt-3">
  <div class="card-header">路由排行</div>
  <div class="card-body">
    <div class="table-responsive">
      <table class="table table-sm table-hover">
<thead><tr>
<th>Group</th>
<th>Route Bidder</th>
<th>Target</th>
<th>曝光</th>
<th>点击</th>
<th>Charge</th>
<th>Pay</th>
<th>Margin</th>
<th>回调错误</th>
</tr></thead>
<tbody>{{with .Other.ledger_topicsMidTopRoutes}}{{range .}}
<tr>
<td>{{.group_name}}</td>
<td>{{.route_bidder_id}}</td>
<td>{{.target_id}}</td>
<td>{{.imps}}</td>
<td>{{.clis}}</td>
<td>{{.charge_spend | printf "%.2f"}}</td>
<td>{{.pay_spend | printf "%.2f"}}</td>
<td>{{.margin_spend | printf "%.2f"}}</td>
<td>{{.forward_errors}}</td>
</tr>{{end}}{{end}}
</tbody>
      </table>
    </div>
  </div>
</div>

<div class="card mt-3">
  <div class="card-header">流量源排行</div>
  <div class="card-body">
    <div class="table-responsive">
      <table class="table table-sm table-hover">
<thead><tr>
<th>Publisher</th>
<th>曝光</th>
<th>点击</th>
<th>Charge</th>
<th>Pay</th>
<th>Margin</th>
<th>Margin Rate</th>
</tr></thead>
<tbody>{{with .Other.ledger_topicsMidTopPublishers}}{{range .}}
<tr>
<td>{{.pub_email}}</td>
<td>{{.imps}}</td>
<td>{{.clis}}</td>
<td>{{.charge_spend | printf "%.2f"}}</td>
<td>{{.pay_spend | printf "%.2f"}}</td>
<td>{{.margin_spend | printf "%.2f"}}</td>
<td>{{.margin_rate | printf "%.4f"}}</td>
</tr>{{end}}{{end}}
</tbody>
      </table>
    </div>
  </div>
</div>

{{ template "footer" }}
