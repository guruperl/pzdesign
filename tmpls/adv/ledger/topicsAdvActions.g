{{ template "header" .}}
{{ template "ledgerheader" .}}

<div class="row">
  <div class="col-lg-12">
    <div class="panel panel-primary">
      <div class="panel-heading">转化与归因核对</div>
      <div class="panel-body">
        <p>转化、购买、下载和自定义行为仅用于效果分析，不计入当前 CPM 账单。</p>
        <div class="table-responsive">
          <table class="table table-hover">
            <thead><tr><th>日期</th><th>行为数</th><th>点击归因</th><th>浏览归因</th><th>未归因</th><th>迟到</th><th>购买金额（USD）</th><th>曝光</th><th>点击</th><th>花费（USD）</th></tr></thead>
            <tbody>{{range .Lists}}<tr><td>{{.daily}}</td><td>{{.actions}}</td><td>{{.click_actions}}</td><td>{{.view_actions}}</td><td>{{.unattributed_actions}}</td><td>{{.late_actions}}</td><td>{{.purchase_value_usd}}</td><td>{{.imps}}</td><td>{{.clis}}</td><td>{{.spend}}</td></tr>{{end}}</tbody>
          </table>
        </div>
      </div>
    </div>
  </div>
</div>

<div class="row">
  <div class="col-lg-12">
    <div class="panel panel-primary">
      <div class="panel-heading">行为明细汇总</div>
      <div class="panel-body table-responsive">
        <table class="table table-hover">
          <thead><tr><th>行为类型</th><th>自定义名称</th><th>归因方式</th><th>行为数</th><th>迟到</th><th>购买金额（USD）</th></tr></thead>
          <tbody>{{with .Other.ledger_topicsAdvActionBreakdown}}{{range .}}<tr><td>{{.event_type}}</td><td>{{.action_name}}</td><td>{{.attribution_type}}</td><td>{{.actions}}</td><td>{{.late_actions}}</td><td>{{.purchase_value_usd}}</td></tr>{{end}}{{end}}</tbody>
        </table>
      </div>
    </div>
  </div>
</div>
{{ template "footer" }}
