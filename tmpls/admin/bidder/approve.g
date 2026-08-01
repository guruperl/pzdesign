{{ template "header" .}}
{{ template "bidderheader" .}}

<div class="alert alert-success">竞价端点已审批启用。</div>
<div class="table-responsive">
  <table class="table table-striped table-sm">
    <thead>
      <tr>
        <th>ID</th>
        <th>广告主</th>
        <th>合成活动</th>
        <th>合成广告组</th>
        <th>合成广告素材</th>
        <th>凭证</th>
        <th>启用</th>
      </tr>
    </thead>
    <tbody>{{range .Lists}}
      <tr>
        <td>{{.bidder_id}}</td>
        <td>{{.adv_id}}</td>
        <td>{{.synthetic_campaign_id}}</td>
        <td>{{.synthetic_item_id}}</td>
        <td>{{.synthetic_creative_id}}</td>
        <td>{{.credential_status}}</td>
        <td>{{.active}}</td>
      </tr>
    {{end}}</tbody>
  </table>
</div>
<p><a class="btn btn-primary" href="bidder?action=topics">返回列表</a></p>

{{ template "footer" .}}
