{{ template "header" .}}
{{ template "campaignheader" .}}

<h3>All Campaigns</h3>
<div class="table-responsive">
    <table class="table table-striped table-sm">
        <thead>
        <tr>
            <th>Campaign Name</th>
            <th>Type</th>
            <th>Company</th>
            <th>Bundle</th>
            <th>Created</th>
        <th>Status</th>
            <th>(Scheduled Update)</th>
            <th></th>
        </tr>
        </thead>
        <tbody>{{ with .Lists }}{{ range . }}
            <tr>
                <!-- td><a href="campaign?action=edit&campaign_id={{.campaign_id}}">{{.campaign_name}}</a></td -->
                <td><a href="item?action=topics&campaign_id={{.campaign_id}}&campaign_name={{.campaign_name|urlquery}}">{{.campaign_name}}</a></td>
                <td>{{.target_type}}</td>
                <td>{{.domain}}</td>
                <td>{{.foreign_id}}</td>
                <td>{{.created}}</td>
                <td>{{.active}}</td>
                <td>
{{if eq .active "New"}}<a class="btn btn-sm btn-primary" href="campaign?action=update&active=Yes&campaign_id={{.campaign_id}}">Activate</a>{{end}}
{{if eq .active "Yes"}}<a class="btn btn-sm btn-info" href="campaign?action=update&active=Pause&campaign_id={{.campaign_id}}">Pause Delivery</a> <a class="btn btn-sm btn-danger" href="campaign?action=update&active=No&campaign_id={{.campaign_id}}">Disable</a>{{end}}
{{if eq .active "Pause"}}<a class="btn btn-sm btn-warning" href="campaign?action=update&active=Yes&campaign_id={{.campaign_id}}">Resume Delivery</a>
<a class="btn btn-sm btn-warning" href="campaign?action=update&active=No&campaign_id={{.campaign_id}}">Disable</a>{{end}}
{{if eq .active "No"}}<a class="btn btn-sm btn-warning" href="campaign?action=update&active=Yes&campaign_id={{.campaign_id}}">Reactivate</a>{{end}}
</td>
                <td><a href="campaign?action=delete&campaign_id={{.campaign_id}}">Delete</a></td>
            </tr>{{end}}{{end}}
        </tbody>
    </table>
</div>

{{ template "footer" .}}
