{{ template "header" .}}
{{ template "siteheader" .}}

<h3>Ad Slots Under Traffic Source {{index .ARGS.site_name 0}}</h3>
<div class="table-responsive">
    <table class="table table-striped table-sm">
        <thead>
        <tr>
            <th>Ad Slot Name</th>
            <th>Size</th>
            <th>Classification / Quality</th>
            <th>Status</th>
            <th>Created</th>
            <th></th>
            <th></th>
        </tr>
        </thead>
        <tbody>{{ with .Lists }}{{ range . }}
            <tr>
                <td><a href="slot?action=edit&slot_id={{.slot_id}}">{{.slot_name}}</a></td>
                <td>{{.w}} × {{.h}}</td>
                <td>{{.media_intent}} / {{.placement}} / {{.traffic_quality}} / {{.source_quality}}</td>
                <td>{{.active}}</td>
                <td>{{.created}}</td>
                <td>
{{if eq .active "New"}}<a class="btn btn-sm btn-primary" href="slot?action=update&active=Yes&slot_id={{.slot_id}}">Activate</a>{{end}}
{{if eq .active "Yes"}}<a class="btn btn-sm btn-danger" href="slot?action=update&active=No&slot_id={{.slot_id}}">Disable</a>{{end}}
{{if eq .active "No"}}<a class="btn btn-sm btn-warning" href="slot?action=update&active=Yes&slot_id={{.slot_id}}">Reactivate</a>{{end}}
</td>
                <td><a href="slot?action=delete&slot_id={{.slot_id}}">Delete</a></td>
            </tr>{{end}}{{end}}
        </tbody>
    </table>
</div>

{{ template "footer" .}}
