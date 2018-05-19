{{ template "header" .}}
{{ template "campaignheader" .}}

<h3>Current Campaigns</h3>
<div class="table-responsive">
	<table class="table table-striped table-sm">
    	<thead>
        <tr>
        	<th>Name</th>
			<th>Active</th>
            <th>Since</th>
            <th></th>
            <th></th>
        </tr>
        </thead>
        <tbody>{{ with .Lists }}{{ range . }}
			<tr>
				<td><a href="campaign?action=edit&campaign_id={{.campaign_id}}">{{.campaign_name}}</a></td>
				<td>{{.active}}</td>
				<td>{{.created}}</td>
				<td>
{{if eq .active "New"}}<a class="btn btn-sm btn-primary" href="campaign?action=update&active=Yes&campaign_id={{.campaign_id}}">Activate</a>{{end}}
{{if eq .active "Yes"}}<a class="btn btn-sm btn-info" href="campaign?action=update&active=Pause&campaign_id={{.campaign_id}}">Pause</a> <a class="btn btn-sm btn-danger" href="campaign?action=update&active=No&campaign_id={{.campaign_id}}">Deactivate</a>{{end}}
{{if eq .active "Pause"}}<a class="btn btn-sm btn-warning" href="campaign?action=update&active=Yes&campaign_id={{.campaign_id}}">Continue</a>
<a class="btn btn-sm btn-warning" href="campaign?action=update&active=No&campaign_id={{.campaign_id}}">Deactivate</a>{{end}}
{{if eq .active "No"}}<a class="btn btn-sm btn-warning" href="campaign?action=update&active=Yes&campaign_id={{.campaign_id}}">Re-Activate</a>{{end}}
</td>
				<td><a href="campaign?action=delete&campaign_id={{.campaign_id}}">Del</a></td>
			</tr>{{end}}{{end}}
		</tbody>
	</table>
</div>

{{ template "footer" .}}
