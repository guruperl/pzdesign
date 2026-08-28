{{ template "header" .}}
{{ template "midrouteheader" .}}
{{ template "midroute_group_nav" .}}
{{$group := index .Other "midroute_group"}}

<div class="mb-3">
  <a class="btn btn-primary" href="midroute?action=startnewBidder&group_id={{$group.group_id}}">Add Bid Endpoint</a>
</div>

<div class="table-responsive">
  <table class="table table-striped table-sm">
    <thead>
      <tr>
        <th>ID</th>
        <th>Priority</th>
        <th>Bid Endpoint</th>
        <th>Advertiser</th>
        <th>Timeout</th>
        <th>Markup Ratio</th>
        <th>Minimum Markup</th>
        <th>Credential</th>
        <th>Endpoint Enabled</th>
        <th>Route Enabled</th>
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
        <td><a class="btn btn-sm btn-primary" href="midroute?action=editBidder&route_bidder_id={{.route_bidder_id}}">Edit</a></td>
      </tr>
    {{end}}{{else}}
      <tr><td colspan="11">No downstream bid endpoints.</td></tr>
    {{end}}</tbody>
  </table>
</div>

{{ template "footer" .}}
