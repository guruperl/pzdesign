{{ template "header" .}}
{{ template "siteheader" .}}

{{$item := index .Lists 0}}
<h3>Supply source review</h3>
<table class="table table-sm table-bordered"><tbody>
<tr><th>Source</th><td>{{$item.site_name}}</td><th>Type</th><td>{{$item.site_type}}</td></tr>
<tr><th>Identity</th><td>{{$item.foreign_id}}</td><th>Status</th><td>{{$item.active}}</td></tr>
<tr><th>Environment</th><td>{{$item.inventory_environment}}</td><th>Integration</th><td>{{$item.integration_mode}}</td></tr>
<tr><th>Canonical identity</th><td>{{$item.canonical_identity}}</td><th>Public review URL</th><td>{{$item.store_url}}</td></tr>
</tbody></table>

{{ template "footer" .}}
