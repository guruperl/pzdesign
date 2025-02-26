{{ template "header" .}}
{{ template "siteheader" .}}

<h3>Current Sites</h3>
<div class="table-responsive">
	<table class="table table-striped table-sm">
    	<thead>
        <tr>
            <th>Name</th>
            <th>Company</th>
        	<th>URL</th>
			<th>Active</th>
            <th>Since</th>
            <th></th>
        </tr>
        </thead>
        <tbody>{{ with .Lists }}{{ range . }}
			<tr>
				<td><a href="site?action=edit&site_id={{.site_id}}">{{.site_name}}</a></td>
				<td>{{.company}}</td>
				<td>{{.site_url}}</td>
				<td>{{.active}}</td>
				<td>{{.created}}</td>
				<td>
{{if eq .active "New"}}<a class="btn btn-sm btn-primary" href="site?action=update&active=Yes&site_id={{.site_id}}">Activate</a>{{end}}
{{if eq .active "Yes"}}<a class="btn btn-sm btn-danger" href="site?action=update&active=No&site_id={{.site_id}}">Deactivate</a>{{end}}
{{if eq .active "No"}}<a class="btn btn-sm btn-warning" href="site?action=update&active=Yes&site_id={{.site_id}}">Re-Activate</a>{{end}}
</td>
				<!-- td><a href="site?action=delete&site_id={{.site_id}}">Del</a></td -->
			</tr>{{end}}{{end}}
		</tbody>
	</table>
</div>

{{ template "footer" .}}
