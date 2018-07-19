{{ template "header" .}}
{{ template "advheader" .}}

<h3>Current Advertisers</h3>
<div class="table-responsive">
	<table class="table table-striped table-sm">
    	<thead>
        <tr>
        	<th>Name</th>
        	<th>company</th>
			<th>Active</th>
        </tr>
        </thead>
        <tbody>{{ with .Lists }}{{ range . }}
			<tr>
				<td><a href="campaign?action=topics&adv_id={{.adv_id}}&adv_md5={{.adv_md5}}">{{.firstname}}</a></td>
				<td>{{.company}}</td>
				<td>{{.active}}</td>
			</tr>{{end}}{{end}}
		</tbody>
	</table>
</div>

{{ template "footer" .}}
