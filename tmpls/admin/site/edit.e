{{ template "header" .}}
{{ template "siteheader" .}}

{{$item := index .Lists 0}}
<h3>Traffic Source Classification Review</h3>
<div class="table-responsive"><table class="table table-sm table-bordered">
<tbody>
<tr><th>Traffic Source</th><td>{{$item.site_name}}</td><th>Type</th><td>{{$item.site_type}}</td></tr>
<tr><th>Bundle / Domain</th><td>{{$item.foreign_id}}</td><th>Status</th><td>{{$item.active}}</td></tr>
<tr><th>Traffic Environment</th><td>{{$item.inventory_environment}}</td><th>Integration Mode</th><td>{{$item.integration_mode}}</td></tr>
<tr><th>Canonical Identifier</th><td>{{$item.canonical_identity}}</td><th>Public Review URL</th><td>{{$item.store_url}}</td></tr>
<tr><th>Information URL</th><td colspan="3">{{$item.site_url}}</td></tr>
</tbody></table></div>
<p class="text-muted">Operational review must confirm that the canonical identifier, public URL, Web/App type, and integration mode are consistent. Classification descriptions grant no traffic permissions.</p>

{{ template "footer" .}}
