{{ template "header" .}}
{{ template "itemheader" .}}

<h3>Ad Groups Under Campaign “{{index .ARGS.campaign_name 0}}”</h3>
<div class="table-responsive">
    <table class="table table-striped table-sm">
        <thead>
        <tr>
            <th>Ad Group Name</th>
            <th>Pricing Model and Price</th>
            <th>Start</th>
            <th>End</th>
            <th>Status</th>
            <th>(Immediate Update)</th>
            <th></th>
        </tr>
        </thead>
        <tbody>{{ with .Lists }}{{ range . }}
            <tr>
                <td><a href="item?action=edit&item_id={{.item_id}}">{{.item_name}}</a></td>
                <td>{{if eq .cost_type "CPM"}}{{.cost}} USD CPM{{else}}Disabled (legacy {{.cost_type}} record){{end}}</td>
                <td>{{.startx}}</td>
                <td>{{.endx}}</td>
                <td>{{.active}}</td>
                <td>
{{if eq .active "New"}}<a class="btn btn-sm btn-primary" href="item?action=update&how=Get&active=Yes&item_id={{.item_id}}">Activate</a>{{end}}
{{if eq .active "Yes"}}<a class="btn btn-sm btn-info" href="item?action=update&how=Delete&active=Pause&item_id={{.item_id}}">Pause</a> <a class="btn btn-sm btn-danger" href="item?action=update&how=Delete&active=No&item_id={{.item_id}}">Disable</a>{{end}}
{{if eq .active "Pause"}}<a class="btn btn-sm btn-warning" href="item?action=update&how=Get&active=Yes&item_id={{.item_id}}">Resume Delivery</a>
<a class="btn btn-sm btn-warning" href="item?action=update&active=No&item_id={{.item_id}}">Disable</a>{{end}}
{{if eq .active "No"}}<a class="btn btn-sm btn-warning" href="item?action=update&Get=Yes&item_id={{.item_id}}">Reactivate</a>{{end}}
</td>
                <td><a href="item?action=delete&item_id={{.item_id}}">Delete</a></td>
            </tr>{{end}}{{end}}
        </tbody>
    </table>
</div>

{{ template "footer" .}}
