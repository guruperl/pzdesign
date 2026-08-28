{{ template "header" .}}
{{ template "midrouteheader" .}}
{{ template "midroute_group_nav" .}}
{{$group := index .Other "midroute_group"}}

<div class="mb-3">
  <a class="btn btn-primary" href="midroute?action=startnewTarget&group_id={{$group.group_id}}">Add Traffic Target</a>
</div>

<div class="table-responsive">
  <table class="table table-striped table-sm">
    <thead>
      <tr>
        <th>ID</th>
        <th>Priority</th>
        <th>Scope</th>
        <th>Entity</th>
        <th>Size</th>
        <th>Enabled</th>
        <th></th>
      </tr>
    </thead>
    <tbody>{{ with .Lists }}{{ range . }}
      <tr>
        <td>{{.target_id}}</td>
        <td>{{.priority}}</td>
        <td>{{if .entitytype_pub}}Publisher{{else if .entitytype_site}}Traffic Source{{else if .entitytype_slot}}Ad Slot{{else}}All Traffic{{end}}</td>
        <td>{{.entity_id}} {{.entity_name}}</td>
        <td>{{.size_id}} {{.size_name}}</td>
        <td>{{.active}}</td>
        <td><a class="btn btn-sm btn-primary" href="midroute?action=editTarget&target_id={{.target_id}}">Edit</a></td>
      </tr>
    {{end}}{{else}}
      <tr><td colspan="7">No traffic targets.</td></tr>
    {{end}}</tbody>
  </table>
</div>

{{ template "footer" .}}
