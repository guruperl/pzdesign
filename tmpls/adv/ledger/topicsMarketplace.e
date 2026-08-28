{{ template "header" .}}
{{ template "ledgerheader" .}}

<div class="panel panel-primary">
  <div class="panel-heading">Delivery Analysis</div>
  <div class="panel-body">
    <p>Data is aggregated in UTC and amounts are in USD. This report is for analysis only and does not automatically change bids, budgets, or delivery settings.</p>
    <form class="form-inline" method="get" action="ledger">
      <input type="hidden" name="action" value="topicsMarketplace">
      <label for="report-day">Through Date</label>
      <input id="report-day" class="form-control" type="date" name="day" value="{{index .ARGS.day 0}}">
      <label for="report-lookback">Lookback Days</label>
      <input id="report-lookback" class="form-control" type="number" min="0" max="90" name="idays" value="{{index .ARGS.idays 0}}">
      <label for="report-limit">Maximum Rows</label>
      <input id="report-limit" class="form-control" type="number" min="1" max="200" name="top" value="{{index .ARGS.top 0}}">
      <button class="btn btn-primary" type="submit">View</button>
      <a class="btn btn-default" href="../json/ledger?action=topicsMarketplace&amp;day={{index .ARGS.day 0}}&amp;idays={{index .ARGS.idays 0}}&amp;top={{index .ARGS.top 0}}">Export JSON</a>
    </form>
  </div>
</div>

<div class="panel panel-default">
  <div class="panel-heading">Data Freshness</div>
  <div class="panel-body">
    {{with .Other.ledger_topicsMarketplaceFreshness}}{{range .}}
    <p>Delivery facts: {{.report_state}}, through {{.report_through}}; daily report: {{.daily_state}}, through {{.daily_through}}; conversion receipt: {{.action_state}}, through {{.action_received_through}}.</p>
    {{end}}{{end}}
    <p>“unknown / unavailable / partial” means the data source cannot be confirmed or is incomplete; do not interpret it as an actual zero value.</p>
  </div>
</div>

<div class="panel panel-primary">
  <div class="panel-heading">Core-Metric Summary</div>
  <div class="panel-body table-responsive">
    <table class="table table-hover table-condensed"><thead><tr><th>Impressions</th><th>Clicks</th><th>CTR</th><th>Actions</th><th>CVR</th><th>Spend (USD)</th><th>Purchase Value (USD)</th><th>ROI</th><th>ROAS</th></tr></thead><tbody>
    {{with .Other.ledger_topicsMarketplaceSummary}}{{range .}}<tr><td>{{.impressions}}</td><td>{{.clicks}}</td><td>{{.ctr | printf "%.4f"}}</td><td>{{.actions}}</td><td>{{.cvr | printf "%.4f"}}</td><td>{{.spend_usd}}</td><td>{{.purchase_value_usd}}</td><td>{{.roi | printf "%.4f"}}</td><td>{{.roas | printf "%.4f"}}</td></tr>{{end}}{{end}}
    </tbody></table>
    <p>Actions and purchase value are affected by conversion retention and the receipt high-water mark. CVR, ROI, and ROAS are analytical values and do not automatically change bidding.</p>
  </div>
</div>

<div class="panel panel-primary">
  <div class="panel-heading">Delivery-Dimension Details</div>
  <div class="panel-body table-responsive">
    <table class="table table-hover table-condensed">
      <thead><tr><th>Demand Source</th><th>Campaign</th><th>Ad Group</th><th>Creative</th><th>Ad Slot</th><th>Traffic Classification</th><th>Quality / Seller</th><th>Country / Region</th><th>Device</th><th>Impressions</th><th>Clicks</th><th>CTR</th><th>Spend (USD)</th><th>Effective CPM</th></tr></thead>
      <tbody>{{range .Lists}}<tr>
        <td>{{.demand_source}}</td><td>{{.campaign_name}}</td><td>{{.item_name}}</td><td>{{.creative_name}}</td><td>{{.slot_name}}</td>
        <td>{{.inventory_environment}} / {{.integration_mode}} / {{.media_intent}} / {{.placement}} / {{.refresh_mode}}{{if .refresh_seconds}} ({{.refresh_seconds}} seconds){{end}}</td><td>{{.traffic_quality}} / {{.source_quality}} / {{.seller_type}}{{with .seller_id}} / {{.}}{{end}}</td>
        <td>{{with .country_name}}{{.}}{{else}}Unknown{{end}}{{with .state_name}} / {{.}}{{end}}</td><td>{{.device_os_name}} / {{.device_type_name}}</td>
        <td>{{.imps}}</td><td>{{.clis}}</td><td>{{.ctr | printf "%.4f"}}</td><td>{{.spend_usd}}</td><td>{{.effective_cpm | printf "%.6f"}}</td>
      </tr>{{end}}</tbody>
    </table>
  </div>
</div>

<div class="panel panel-primary">
  <div class="panel-heading">Conversion-Dimension Details</div>
  <div class="panel-body table-responsive">
    <p>Conversion facts are aggregated by campaign, ad group, and creative. Because conversion facts do not retain device or geographic classifications, the same conversion is not duplicated across device or region rows.</p>
    <table class="table table-hover table-condensed">
      <thead><tr><th>Campaign ID</th><th>Ad Group ID</th><th>Creative ID</th><th>Action Type</th><th>Attribution Method</th><th>Actions</th><th>Late</th><th>Purchase Value (USD)</th></tr></thead>
      <tbody>{{with .Other.ledger_topicsMarketplaceActions}}{{range .}}<tr><td>{{.campaign_id}}</td><td>{{.item_id}}</td><td>{{.creative_id}}</td><td>{{.event_type}}</td><td>{{.attribution_type}}</td><td>{{.actions}}</td><td>{{.late_actions}}</td><td>{{.purchase_value_usd}}</td></tr>{{end}}{{end}}</tbody>
    </table>
  </div>
</div>
{{ template "footer" }}
