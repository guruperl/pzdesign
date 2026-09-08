{{ template "header" .}}
{{ template "pubheader" .}}

<h3>All Publisher Accounts</h3>
<div class="table-responsive">
    <table class="table table-striped table-sm">
        <thead>
        <tr>
            <th>Publisher ID</th>
            <th>Domain</th>
            <th>QPS</th>
            <th>Actual QPS</th>
            <th>Status</th>
            <th>Created</th>
            <th></th>
            <th></th>
        </tr>
        </thead>
        <tbody>{{ with .Lists }}{{ range . }}
            <tr>
                <td><a href="pub?action=edit&pub_id={{.pub_id}}">{{.pub_id}}</a></td>
                <td>{{.domain}}</td>
                <td>{{.limit_imp}}</td>
                <td>{{.current_imp}}</td>
                <td>{{.active}}</td>
                <td>{{.created}}</td>
                <td>
{{if eq .active "New"}}<a class="btn btn-sm btn-primary" href="pub?action=update&active=Yes&pub_id={{.pub_id}}">Activate</a>{{end}}
{{if eq .active "Yes"}}<a class="btn btn-sm btn-danger" href="pub?action=takedown&active=No&pub_id={{.pub_id}}">Disable</a>{{end}}
{{if eq .active "No"}}<a class="btn btn-sm btn-warning" href="pub?action=takedown&active=Yes&pub_id={{.pub_id}}">Reactivate</a>{{end}}
</td>
                <td><form method="post" action="manage" target="_blank"><input type="hidden" name="action" value="login_as"><input type="hidden" name="role" value="pub"><input type="hidden" name="pub_id" value="{{.pub_id}}"><button class="btn btn-sm btn-success" type="submit">Enter Account</button></form></td>
            </tr>{{end}}{{end}}
            <tr>
            <th colspan=8>Add Publisher (SSP/ADX)</th>
            </tr>
            <tr><form class="form" action=pub method=post>
            <input type=hidden name=action value="insert" />
            <input type=hidden name=active value="Yes" />
            <td> </td>
            <td><input class="form-input" type=text name=domain placeholder="Domain" /><input class="form-input" type=email name=email placeholder="Account email" required /></td>
            <td><input class="form-input" type=text name=limit_imp /></td>
            <td><input class="form-input" type=hidden name=current_imp value=0 /></td>
            <td colspan=4><button type="submit" class="btn btn-sm btn-primary">Add</button></td>
            </form></tr>
        </tbody>
    </table>
</div>

{{ template "footer" .}}
