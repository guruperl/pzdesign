{{ template "header" .}}
{{ template "ledgerheader" .}}

<div class="card">
  <div class="card-header">External Demand Settlement: Last 24 Hours</div>
  <div class="card-body">
    <div class="table-responsive">
      <table class="table table-sm table-hover">
<thead><tr>
<th>Hour</th>
<th>Wins</th>
<th>Losses</th>
<th>Impressions</th>
<th>Clicks</th>
<th>Receivable</th>
<th>Payable</th>
<th>Gross Margin</th>
<th>Margin Rate</th>
<th>Callback Errors</th>
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
  <div class="card-header">Bid Endpoint Ranking</div>
  <div class="card-body">
    <div class="table-responsive">
      <table class="table table-sm table-hover">
<thead><tr>
<th>Endpoint</th>
<th>Wins</th>
<th>Losses</th>
<th>Impressions</th>
<th>Clicks</th>
<th>Receivable</th>
<th>Payable</th>
<th>Gross Margin</th>
<th>Margin Rate</th>
<th>Callback Errors</th>
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
  <div class="card-header">Route Ranking</div>
  <div class="card-body">
    <div class="table-responsive">
      <table class="table table-sm table-hover">
<thead><tr>
<th>Route Group</th>
<th>Routed Bid Endpoint</th>
<th>Traffic Target</th>
<th>Impressions</th>
<th>Clicks</th>
<th>Receivable</th>
<th>Payable</th>
<th>Gross Margin</th>
<th>Callback Errors</th>
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
  <div class="card-header">Traffic Source Ranking</div>
  <div class="card-body">
    <div class="table-responsive">
      <table class="table table-sm table-hover">
<thead><tr>
<th>Publisher</th>
<th>Impressions</th>
<th>Clicks</th>
<th>Receivable</th>
<th>Payable</th>
<th>Gross Margin</th>
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
<td>{{with .margin_rate}}{{. | printf "%.4f"}}{{else}}0.0000{{end}}</td>
</tr>{{end}}{{end}}
</tbody>
      </table>
    </div>
  </div>
</div>

{{ template "footer" }}
