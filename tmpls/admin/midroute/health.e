{{ template "header" .}}
{{ template "midrouteheader" .}}

<div class="mb-3">
  <a class="btn btn-outline-secondary" href="midroute?action=topics">Route Groups</a>
</div>

{{ $cache := index .Other "midroute_cache_status" }}
{{ if $cache }}
<div class="table-responsive mb-3">
  <table class="table table-sm table-bordered">
    <tbody>
      <tr>
        <th>Redis Key</th>
        <td>{{$cache.cache_key}}</td>
        <th>Status</th>
        <td>{{$cache.cache_status}}</td>
      </tr>
      <tr>
        <th>Generated</th>
        <td>{{$cache.cache_generated_at}}</td>
        <th>Cache Entries</th>
        <td>{{$cache.cache_entry_count}}</td>
      </tr>
      <tr>
        <th>Cache High-Water Mark</th>
        <td>{{$cache.cache_route_high_water}}</td>
        <th>Database High-Water Mark</th>
        <td>{{$cache.db_route_high_water}}</td>
      </tr>
      {{ if $cache.cache_error }}
      <tr>
        <th>Error</th>
        <td colspan="3">{{$cache.cache_error}}</td>
      </tr>
      {{ end }}
    </tbody>
  </table>
</div>
{{ end }}

<div class="table-responsive">
  <table class="table table-striped table-sm">
    <thead>
      <tr>
        <th>Severity</th>
        <th>Issue</th>
        <th>Route Group</th>
        <th>Bid Endpoint</th>
        <th>Credential Reference</th>
        <th>Status</th>
        <th>Details</th>
      </tr>
    </thead>
    <tbody>{{ with .Lists }}{{ range . }}
      <tr>
        <td>{{.severity}}</td>
        <td>{{.issue_type}}</td>
        <td>{{.group_id}} {{.group_name}}</td>
        <td>{{.bidder_id}} {{.bidder_name}}</td>
        <td>{{.credential_ref}}</td>
        <td>{{.credential_status}} {{.bidder_active}}</td>
        <td>{{.detail}}</td>
      </tr>
    {{end}}{{else}}
      <tr><td colspan="7">No external-demand routing health issues found.</td></tr>
    {{end}}</tbody>
  </table>
</div>

{{ template "footer" .}}
