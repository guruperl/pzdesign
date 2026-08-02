{{ template "header" .}}
{{ template "ledgerheader" .}}
<div class="card"><div class="card-header">流量收益分析</div><div class="card-body">
  <p>数据按 UTC 汇总，金额为 USD。报表只读，不会更改流量源、广告位或结算信息。</p>
  <form class="form-inline" method="get" action="ledger">
    <input type="hidden" name="action" value="topicsMarketplace">
    <label for="report-day">截止日期</label><input id="report-day" class="form-control" type="date" name="day" value="{{index .ARGS.day 0}}">
    <label for="report-lookback">回溯天数</label><input id="report-lookback" class="form-control" type="number" min="0" max="90" name="idays" value="{{index .ARGS.idays 0}}">
    <label for="report-limit">最多行数</label><input id="report-limit" class="form-control" type="number" min="1" max="200" name="top" value="{{index .ARGS.top 0}}">
    <button class="btn btn-primary" type="submit">查看</button>
    <a class="btn btn-secondary" href="../json/ledger?action=topicsMarketplace&amp;day={{index .ARGS.day 0}}&amp;idays={{index .ARGS.idays 0}}&amp;top={{index .ARGS.top 0}}">导出 JSON</a>
  </form>
</div></div>
<div class="card mt-3"><div class="card-header">数据新鲜度</div><div class="card-body">
{{with .Other.ledger_topicsMarketplaceFreshness}}{{range .}}<p>投放事实：{{.report_state}}，更新至 {{.report_through}}；日报：{{.daily_state}}，更新至 {{.daily_through}}。转化数据不适用于流量方报表。</p>{{end}}{{end}}
<p>“unavailable / partial” 表示数据源不可确认或尚未完整，不能按真实的零收入解释。</p>
</div></div>
<div class="card mt-3"><div class="card-header">流量维度明细</div><div class="card-body table-responsive">
<table class="table table-sm table-hover"><thead><tr><th>需求来源</th><th>流量源</th><th>广告位</th><th>流量分类</th><th>质量 / 卖方</th><th>国家 / 地区</th><th>设备</th><th>曝光</th><th>点击</th><th>CTR</th><th>收入（USD）</th><th>有效 CPM</th></tr></thead>
<tbody>{{range .Lists}}<tr><td>{{.demand_source}}</td><td>{{.site_name}}</td><td>{{.slot_name}}</td><td>{{.inventory_environment}} / {{.integration_mode}} / {{.media_intent}} / {{.placement}} / {{.refresh_mode}}{{if .refresh_seconds}}（{{.refresh_seconds}} 秒）{{end}}</td><td>{{.traffic_quality}} / {{.source_quality}} / {{.seller_type}}{{with .seller_id}} / {{.}}{{end}}</td><td>{{with .country_name}}{{.}}{{else}}未知{{end}}{{with .state_name}} / {{.}}{{end}}</td><td>{{.device_os_name}} / {{.device_type_name}}</td><td>{{.imps}}</td><td>{{.clis}}</td><td>{{.ctr | printf "%.4f"}}</td><td>{{.revenue_usd}}</td><td>{{.effective_cpm | printf "%.6f"}}</td></tr>{{end}}</tbody></table>
</div></div>
{{ template "footer" }}
