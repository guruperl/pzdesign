{{ template "header" .}}
{{ template "ledgerheader" .}}

<div class="card">
  <div class="card-header">最近 24 小时外部需求方结算</div>
  <div class="card-body">
    <div class="table-responsive">
      <table class="table table-sm table-hover">
<thead><tr>
<th>小时</th>
<th>竞价胜出</th>
<th>竞价未胜出</th>
<th>展示</th>
<th>点击</th>
<th>应收</th>
<th>应付</th>
<th>毛利</th>
<th>毛利率</th>
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
<td>{{with .margin_rate}}{{. | printf "%.4f"}}{{else}}0.0000{{end}}</td>
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
<th>竞价胜出</th>
<th>竞价未胜出</th>
<th>展示</th>
<th>点击</th>
<th>应收</th>
<th>应付</th>
<th>毛利</th>
<th>毛利率</th>
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
<td>{{with .margin_rate}}{{. | printf "%.4f"}}{{else}}0.0000{{end}}</td>
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
<th>路由组</th>
<th>路由竞价端点</th>
<th>流量目标</th>
<th>展示</th>
<th>点击</th>
<th>应收</th>
<th>应付</th>
<th>毛利</th>
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
<th>流量方</th>
<th>展示</th>
<th>点击</th>
<th>应收</th>
<th>应付</th>
<th>毛利</th>
<th>毛利率</th>
</tr></thead>
<tbody>{{with .Other.ledger_topicsMidTopPublishers}}{{range .}}
<tr>
<td>{{.pub_email}}</td>
<td>{{.imps}}</td>
<td>{{.clis}}</td>
<td>{{.charge_spend | printf "%.2f"}}</td>
<td>{{.pay_spend | printf "%.2f"}}</td>
<td>{{.margin_spend | printf "%.2f"}}</td>
<td>{{with .margin_rate}}{{. | printf "%.4f"}}{{else}}0.0000{{end}}</td>
</tr>{{end}}{{end}}
</tbody>
      </table>
    </div>
  </div>
</div>

{{ template "footer" }}
