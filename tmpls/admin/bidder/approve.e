{{ template "header" .}}
{{ template "bidderheader" .}}

<div class="alert alert-success">Bid endpoint approved and enabled.</div>
<div class="table-responsive">
  <table class="table table-striped table-sm">
    <thead>
      <tr>
        <th>ID</th>
        <th>Advertiser</th>
        <th>Synthetic Campaign</th>
        <th>Synthetic Ad Group</th>
        <th>Synthetic Creative</th>
        <th>Credential</th>
        <th>Enabled</th>
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
<p><a class="btn btn-primary" href="bidder?action=topics">Back to List</a></p>

{{ template "footer" .}}
