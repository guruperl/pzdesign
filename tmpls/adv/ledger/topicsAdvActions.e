{{ template "header" .}}
{{ template "ledgerheader" .}}

<div class="row"><div class="col-lg-12"><div class="panel panel-primary">
  <div class="panel-heading">Action and attribution reconciliation</div>
  <div class="panel-body">
    <p>Conversions, purchases, downloads, and custom actions are analytical only and do not change the current CPM bill.</p>
    <div class="table-responsive"><table class="table table-hover">
      <thead><tr><th>Date</th><th>Actions</th><th>Click</th><th>View</th><th>Unattributed</th><th>Late</th><th>Purchase value (USD)</th><th>Impressions</th><th>Clicks</th><th>Spend (USD)</th></tr></thead>
      <tbody>{{range .Lists}}<tr><td>{{.daily}}</td><td>{{.actions}}</td><td>{{.click_actions}}</td><td>{{.view_actions}}</td><td>{{.unattributed_actions}}</td><td>{{.late_actions}}</td><td>{{.purchase_value_usd}}</td><td>{{.imps}}</td><td>{{.clis}}</td><td>{{.spend}}</td></tr>{{end}}</tbody>
    </table></div>
  </div>
</div></div></div>

<div class="row"><div class="col-lg-12"><div class="panel panel-primary">
  <div class="panel-heading">Action breakdown</div>
  <div class="panel-body table-responsive"><table class="table table-hover">
    <thead><tr><th>Type</th><th>Custom name</th><th>Attribution</th><th>Actions</th><th>Late</th><th>Purchase value (USD)</th></tr></thead>
    <tbody>{{with .Other.ledger_topicsAdvActionBreakdown}}{{range .}}<tr><td>{{.event_type}}</td><td>{{.action_name}}</td><td>{{.attribution_type}}</td><td>{{.actions}}</td><td>{{.late_actions}}</td><td>{{.purchase_value_usd}}</td></tr>{{end}}{{end}}</tbody>
  </table></div>
</div></div></div>
{{ template "footer" }}
