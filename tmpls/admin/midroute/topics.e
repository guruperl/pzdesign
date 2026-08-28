{{ template "header" .}}
{{ template "midrouteheader" .}}

<div class="mb-3">
  <a class="btn btn-primary" href="midroute?action=startnew">Create Route Group</a>
  <a class="btn btn-outline-secondary" href="midroute?action=health">Health Check</a>
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
      <tr>
        <th>Source</th>
        <td>{{$cache.cache_source}}</td>
        <th>Checksum</th>
        <td>{{$cache.cache_checksum}}</td>
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
        <th>ID</th>
        <th>Name</th>
        <th>Trigger</th>
        <th>Total Timeout</th>
        <th>Markup Ratio</th>
        <th>Minimum Markup</th>
        <th>Enabled</th>
        <th>Bid Endpoints</th>
        <th>Targets</th>
        <th></th>
      </tr>
    </thead>
    <tbody>{{ with .Lists }}{{ range . }}
      <tr>
        <td>{{.group_id}}</td>
        <td>{{.group_name}}</td>
        <td>{{.trigger_mode}}</td>
        <td>{{.total_timeout_ms}} ms</td>
        <td>{{.margin_pct}}</td>
        <td>{{.min_margin_cpm}}</td>
        <td>{{.active}}</td>
        <td><a href="midroute?action=bidders&group_id={{.group_id}}">{{.bidder_count}}</a></td>
        <td><a href="midroute?action=targets&group_id={{.group_id}}">{{.target_count}}</a></td>
        <td>
          <a class="btn btn-sm btn-primary" href="midroute?action=edit&group_id={{.group_id}}">Edit</a>
        </td>
      </tr>
    {{end}}{{else}}
      <tr><td colspan="10">No external-demand route groups.</td></tr>
    {{end}}</tbody>
  </table>
</div>

{{ template "footer" .}}
