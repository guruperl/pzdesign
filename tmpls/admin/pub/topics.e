{{ template "header" .}}
{{ template "pubheader" .}}

<h3>Current Publishers</h3>
<div class="table-responsive">
	<table class="table table-striped table-sm">
    	<thead>
        <tr>
            <th>Email</th>
        	<th>company</th>
			<th>Active</th>
            <th>Since</th>
            <th></th>
            <th></th>
            <th></th>
        </tr>
        </thead>
        <tbody>{{ with .Lists }}{{ range . }}
			<tr>
				<td><a href="pub?action=edit&pub_id={{.pub_id}}">{{.email}}</a></td>
				<td>{{.company}}</td>
				<td>{{.active}}</td>
				<td>{{.created}}</td>
				<td>
{{if eq .active "New"}}<a class="btn btn-sm btn-primary" href="pub?action=update&active=Yes&pub_id={{.pub_id}}">Activate</a>{{end}}
{{if eq .active "Yes"}}<a class="btn btn-sm btn-danger" href="pub?action=update&active=No&pub_id={{.pub_id}}">Deactivate</a>{{end}}
{{if eq .active "No"}}<a class="btn btn-sm btn-warning" href="pub?action=update&active=Yes&pub_id={{.pub_id}}">Re-Activate</a>{{end}}
</td>
				<td><a class="btn btn-sm btn-success" href="manage?action=login_as&role=pub&email={{.email | urlquery}}" target="_blank">As</a></td>
				<td><a href="pub?action=delete&pub_id={{.pub_id}}">Del</a></td>
			</tr>{{end}}{{end}}
		</tbody>
	</table>
</div>

{{ template "footer" .}}
