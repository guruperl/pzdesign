{{ template "header" .}}
{{ template "itemheader" .}}

{{$next := (index .ARGS.agent_level 0)}}

<h3>Current Items</h3>
<div class="table-responsive">
    <table class="table table-striped table-sm">
        <thead>
        <tr>
            <th>Name</th>
            <th>Creatives</th>
            <th>Active</th>
            <th>Start</th>
            <th></th>
        </tr>
        </thead>
        <tbody>{{ with .Lists }}{{ range . }}
            <tr>
                <td>{{.item_name}}</td>
                <td>{{range $k, $v := .creative_topics}}<pre class="creative-source">{{$v.content}}</pre>{{end}}
                <td>{{.active}}</td>
                <td>{{.startx}}</td>
                <td>
{{if ne .active "Yes"}}<a class="btn btn-sm btn-primary" href="item?action=authen&item_id={{.item_id}}&active={{if eq $next `1`}}Pass2{{else}}Yes{{end}}&campaign_id={{index $.ARGS.campaign_id 0}}&campaign_md5={{index $.ARGS.campaign_md5 0}}">Approve</a>
<a class="btn btn-sm btn-warning" href="item?action=authen&item_id={{.item_id}}&active=No&campaign_id={{index $.ARGS.campaign_id 0}}&campaign_md5={{index $.ARGS.campaign_md5 0}}">Reject</a>{{end}}
</td>
            </tr>{{end}}{{end}}
        </tbody>
    </table>
</div>

{{ template "footer" .}}
