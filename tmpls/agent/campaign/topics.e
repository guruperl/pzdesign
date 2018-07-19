{{ template "header" .}}
{{ template "campaignheader" .}}

{{$attach := print "adv_id=" (index .ARGS.adv_id 0) "&adv_md5=" (index .ARGS.adv_md5 0)}}
{{$next := (index .ARGS.agent_level 0)}}

<h3>Current Campaigns</h3>
<div class="table-responsive">
	<table class="table table-striped table-sm">
    	<thead>
        <tr>
        	<th>Name</th>
			<th>Active</th>
            <th>Since</th>
            <th></th>
        </tr>
        </thead>
        <tbody>{{ with .Lists }}{{ range . }}
			<tr>
				<td><a href="item?action=topics&campaign_id={{.campaign_id}}&campaign_md5={{.campaign_md5}}&campaign_name={{.campaign_name|urlquery}}">{{.campaign_name}}</a></td>
				<td>{{.active}}</td>
				<td>{{.created}}</td>
				<td>
{{if ne .active "Yes"}}<a class="btn btn-sm btn-primary" href="campaign?action=authen&campaign_id={{.campaign_id}}&active={{if eq $next `2`}}Pass2{{else}}Yes{{end}}&{{$attach}}">Activate</a>
<a class="btn btn-sm btn-warning" href="campaign?action=authen&campaign_id={{.campaign_id}}&active=No&{{$attach}}">Deactive</a>{{end}}
</td>
			</tr>{{end}}{{end}}
		</tbody>
	</table>
</div>

{{ template "footer" .}}
