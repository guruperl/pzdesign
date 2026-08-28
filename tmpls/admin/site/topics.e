{{ template "header" .}}
{{ template "siteheader" .}}

<h3>All Websites and Apps</h3>
<div class="table-responsive">
    <table class="table table-striped table-sm">
        <thead>
        <tr>
            <th>Name</th>
            <th>Traffic Source</th>
            <th>Traffic Classification</th>
            <th>URL</th>
            <th>Status</th>
            <th>Created</th>
            <th></th>
            <th></th>
        </tr>
        </thead>
        <tbody>{{ with .Lists }}{{ range . }}
            <tr>
                <td><a href="site?action=edit&site_id={{.site_id}}">{{.site_name}}</a> · <a href="slot?action=topics&pub_id={{.pub_id}}&site_id={{.site_id}}&site_name={{.site_name|urlquery}}">Ad Slots</a></td>
                <td>{{.company}}</td>
                <td>{{.inventory_environment}} / {{.integration_mode}}</td>
                <td>{{.site_url}}</td>
                <td>{{.active}}</td>
                <td>{{.created}}</td>
                <td>
{{if eq .active "New"}}<a class="btn btn-sm btn-primary" href="site?action=update&active=Yes&site_id={{.site_id}}">Activate</a>{{end}}
{{if eq .active "Yes"}}<a class="btn btn-sm btn-danger" href="site?action=update&active=No&site_id={{.site_id}}">Disable</a>{{end}}
{{if eq .active "No"}}<a class="btn btn-sm btn-warning" href="site?action=update&active=Yes&site_id={{.site_id}}">Reactivate</a>{{end}}
</td>
                <td><a href="site?action=delete&site_id={{.site_id}}">Delete</a></td>
            </tr>{{end}}{{end}}
        </tbody>
    </table>
</div>

{{ template "footer" .}}
