{{ template "header" .}}
{{ template "ledgerheader" .}}
<div class="card"><div class="card-header">Traffic Revenue Analysis</div><div class="card-body">
  <p>Data is aggregated in UTC and amounts are in USD. This report is read-only and does not change traffic sources, ad slots, or settlement information.</p>
  <form class="form-inline" method="get" action="ledger">
    <input type="hidden" name="action" value="topicsMarketplace">
    <label for="report-day">Through Date</label><input id="report-day" class="form-control" type="date" name="day" value="{{index .ARGS.day 0}}">
    <label for="report-lookback">Lookback Days</label><input id="report-lookback" class="form-control" type="number" min="0" max="90" name="idays" value="{{index .ARGS.idays 0}}">
    <label for="report-limit">Maximum Rows</label><input id="report-limit" class="form-control" type="number" min="1" max="200" name="top" value="{{index .ARGS.top 0}}">
    <button class="btn btn-primary" type="submit">View</button>
    <a class="btn btn-secondary" href="../json/ledger?action=topicsMarketplace&amp;day={{index .ARGS.day 0}}&amp;idays={{index .ARGS.idays 0}}&amp;top={{index .ARGS.top 0}}">Export JSON</a>
  </form>
</div></div>
<div class="card mt-3"><div class="card-header">Data Freshness</div><div class="card-body">
{{with .Other.ledger_topicsMarketplaceFreshness}}{{range .}}<p>Delivery facts: {{.report_state}}, through {{.report_through}}; daily report: {{.daily_state}}, through {{.daily_through}}. Conversion data does not apply to publisher reports.</p>{{end}}{{end}}
<p>“unavailable / partial” means the data source cannot be confirmed or is incomplete; do not interpret it as actual zero revenue.</p>
</div></div>
<div class="card mt-3"><div class="card-header">Traffic-Dimension Details</div><div class="card-body table-responsive">
<table class="table table-sm table-hover"><thead><tr><th>Demand Source</th><th>Traffic Source</th><th>Ad Slot</th><th>Traffic Classification</th><th>Quality / Seller</th><th>Country / Region</th><th>Device</th><th>Impressions</th><th>Clicks</th><th>CTR</th><th>Revenue (USD)</th><th>Effective CPM</th></tr></thead>
<tbody>{{range .Lists}}<tr><td>{{.demand_source}}</td><td>{{.site_name}}</td><td>{{.slot_name}}</td><td>{{.inventory_environment}} / {{.integration_mode}} / {{.media_intent}} / {{.placement}} / {{.refresh_mode}}{{if .refresh_seconds}} ({{.refresh_seconds}} seconds){{end}}</td><td>{{.traffic_quality}} / {{.source_quality}} / {{.seller_type}}{{with .seller_id}} / {{.}}{{end}}</td><td>{{with .country_name}}{{.}}{{else}}Unknown{{end}}{{with .state_name}} / {{.}}{{end}}</td><td>{{.device_os_name}} / {{.device_type_name}}</td><td>{{.imps}}</td><td>{{.clis}}</td><td>{{.ctr | printf "%.4f"}}</td><td>{{.revenue_usd}}</td><td>{{.effective_cpm | printf "%.6f"}}</td></tr>{{end}}</tbody></table>
</div></div>
{{ template "footer" }}
