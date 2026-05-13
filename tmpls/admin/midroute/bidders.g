{{ template "header" .}}
{{ template "midrouteheader" .}}
{{ template "midroute_group_nav" .}}
{{$group := index .Other "midroute_group"}}

<div class="mb-3">
  <a class="btn btn-primary" href="midroute?action=startnewBidder&group_id={{$group.group_id}}">添加竞价端点</a>
</div>

<div class="table-responsive">
  <table class="table table-striped table-sm">
    <thead>
      <tr>
        <th>ID</th>
        <th>优先级</th>
        <th>竞价端点</th>
        <th>商户</th>
        <th>超时</th>
        <th>加价比例</th>
        <th>最低加价</th>
        <th>凭证</th>
        <th>端点启用</th>
        <th>路由启用</th>
        <th></th>
      </tr>
    </thead>
    <tbody>{{ with .Lists }}{{ range . }}
      <tr>
        <td>{{.route_bidder_id}}</td>
        <td>{{.priority}}</td>
        <td>{{.bidder_id}} {{.bidder_name}}</td>
        <td>{{.adv_id}} {{.adv_email}}</td>
        <td>{{.timeout_ms}}</td>
        <td>{{.margin_pct}}</td>
        <td>{{.min_margin_cpm}}</td>
        <td>{{.bidder_credential_status}}</td>
        <td>{{.bidder_active}}</td>
        <td>{{.active}}</td>
        <td><a class="btn btn-sm btn-primary" href="midroute?action=editBidder&route_bidder_id={{.route_bidder_id}}">编辑</a></td>
      </tr>
    {{end}}{{else}}
      <tr><td colspan="11">暂无下游竞价端点。</td></tr>
    {{end}}</tbody>
  </table>
</div>

{{ template "footer" .}}
