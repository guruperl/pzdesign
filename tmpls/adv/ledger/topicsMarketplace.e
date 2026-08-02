{{ template "header" .}}
{{ template "ledgerheader" .}}
<h2>投放分析</h2>
<p>数据按 UTC 汇总，金额为 USD。报表只用于分析，不会自动修改出价、预算或投放设置。</p>
<form method="get" action="ledger">
  <input type="hidden" name="action" value="topicsMarketplace">
  <label>截止日期 <input type="date" name="day" value="{{index .ARGS.day 0}}"></label>
  <label>回溯天数 <input type="number" min="0" max="90" name="idays" value="{{index .ARGS.idays 0}}"></label>
  <label>最多行数 <input type="number" min="1" max="200" name="top" value="{{index .ARGS.top 0}}"></label>
  <button type="submit">查看</button>
  <a href="../json/ledger?action=topicsMarketplace&amp;day={{index .ARGS.day 0}}&amp;idays={{index .ARGS.idays 0}}&amp;top={{index .ARGS.top 0}}">导出 JSON</a>
</form>
<h3>数据新鲜度</h3>
{{with .Other.ledger_topicsMarketplaceFreshness}}{{range .}}<p>投放事实：{{.report_state}}，更新至 {{.report_through}}；日报：{{.daily_state}}，更新至 {{.daily_through}}；转化接收：{{.action_state}}，更新至 {{.action_received_through}}。</p>{{end}}{{end}}
<p>“unknown / unavailable / partial” 表示数据源不可确认或尚未完整，不能按真实的零值解释。</p>
<h3>核心指标汇总</h3><table><thead><tr><th>曝光</th><th>点击</th><th>CTR</th><th>行为</th><th>CVR</th><th>花费（USD）</th><th>购买金额（USD）</th><th>ROI</th><th>ROAS</th></tr></thead><tbody>{{with .Other.ledger_topicsMarketplaceSummary}}{{range .}}<tr><td>{{.impressions}}</td><td>{{.clicks}}</td><td>{{.ctr | printf "%.4f"}}</td><td>{{.actions}}</td><td>{{.cvr | printf "%.4f"}}</td><td>{{.spend_usd}}</td><td>{{.purchase_value_usd}}</td><td>{{.roi | printf "%.4f"}}</td><td>{{.roas | printf "%.4f"}}</td></tr>{{end}}{{end}}</tbody></table>
<h3>投放维度明细</h3>
<table><thead><tr><th>需求来源</th><th>广告活动</th><th>广告组</th><th>素材</th><th>广告位</th><th>国家 / 地区</th><th>设备</th><th>曝光</th><th>点击</th><th>CTR</th><th>花费（USD）</th><th>有效 CPM</th></tr></thead><tbody>{{range .Lists}}<tr><td>{{.demand_source}}</td><td>{{.campaign_name}}</td><td>{{.item_name}}</td><td>{{.creative_name}}</td><td>{{.slot_name}}</td><td>{{with .country_name}}{{.}}{{else}}未知{{end}}{{with .state_name}} / {{.}}{{end}}</td><td>{{.device_os_name}} / {{.device_type_name}}</td><td>{{.imps}}</td><td>{{.clis}}</td><td>{{.ctr | printf "%.4f"}}</td><td>{{.spend_usd}}</td><td>{{.effective_cpm | printf "%.6f"}}</td></tr>{{end}}</tbody></table>
<h3>转化维度明细</h3>
<p>转化事实不保存设备和地理分类，因此不会把同一转化复制到多个设备或地区行。</p>
<table><thead><tr><th>广告活动 ID</th><th>广告组 ID</th><th>素材 ID</th><th>行为类型</th><th>归因方式</th><th>行为数</th><th>迟到</th><th>购买金额（USD）</th></tr></thead><tbody>{{with .Other.ledger_topicsMarketplaceActions}}{{range .}}<tr><td>{{.campaign_id}}</td><td>{{.item_id}}</td><td>{{.creative_id}}</td><td>{{.event_type}}</td><td>{{.attribution_type}}</td><td>{{.actions}}</td><td>{{.late_actions}}</td><td>{{.purchase_value_usd}}</td></tr>{{end}}{{end}}</tbody></table>
{{ template "footer" }}
