{{ template "header" .}}
{{ template "bidderheader" .}}

<div class="table-responsive">
  <table class="table table-striped table-sm">
    <thead>
      <tr>
        <th>ID</th>
        <th>广告主</th>
        <th>名称</th>
        <th>端点</th>
        <th>凭证</th>
        <th>启用</th>
        <th>活动</th>
        <th>广告组</th>
        <th>广告素材</th>
        <th></th>
      </tr>
    </thead>
    <tbody>{{ with .Lists }}{{ range . }}
      <tr>
        <td>{{.bidder_id}}</td>
        <td>{{.adv_id}} {{.adv_email}}</td>
        <td>{{.bidder_name}}</td>
        <td>{{.endpoint_url}}</td>
        <td>{{.credential_status}}</td>
        <td>{{.active}}</td>
        <td>{{.synthetic_campaign_id}}</td>
        <td>{{.synthetic_item_id}}</td>
        <td>{{.synthetic_creative_id}}</td>
        <td><a class="btn btn-sm btn-primary" href="bidder?action=edit&bidder_id={{.bidder_id}}">审核</a></td>
      </tr>
    {{end}}{{else}}
      <tr><td colspan="10">暂无竞价端点。</td></tr>
    {{end}}</tbody>
  </table>
</div>

{{ template "footer" .}}
