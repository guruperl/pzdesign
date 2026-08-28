{{ template "header" .}}
{{ template "bidderheader" .}}

<div class="table-responsive">
  <table class="table table-striped table-sm">
    <thead>
      <tr>
        <th>ID</th>
        <th>Advertiser</th>
        <th>Name</th>
        <th>Endpoint</th>
        <th>Credential</th>
        <th>Enabled</th>
        <th>Campaign</th>
        <th>Ad Group</th>
        <th>Creative</th>
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
        <td><a class="btn btn-sm btn-primary" href="bidder?action=edit&bidder_id={{.bidder_id}}">Review</a></td>
      </tr>
    {{end}}{{else}}
      <tr><td colspan="10">No bid endpoints.</td></tr>
    {{end}}</tbody>
  </table>
</div>

{{ template "footer" .}}
