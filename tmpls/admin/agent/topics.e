{{ template "header" .}}
{{ template "agentheader" .}}

<h3>All Agency Accounts</h3>
<div class="table-responsive">
    <table class="table table-striped table-sm">
        <thead>
        <tr>
            <th>Name</th>
            <th>Level</th>
            <th>Notes</th>
            <th>Status</th>
            <th></th>
            <th></th>
        </tr>
        </thead>
        <tbody>{{ with .Lists }}{{ range . }}
            <tr>
            <td><a href="agent?action=edit&agent_id={{.agent_id}}">{{.login}}</a></td>
            <td>{{.level}}</td>
            <td>{{.notes}}</td>
            <td>{{.active}}</td>
            <td><a class="btn btn-sm btn-success" href="manage?action=login_as&role=agent&login={{.login | urlquery}}" target="_blank">Enter Account</a></td>
            <td><a href="agent?action=delete&agent_id={{.agent_id}}">Delete</a></td>
            </tr>{{end}}{{end}}
        </tbody>
    </table>
</div>

<form class="form" action=agent method=post><input type=hidden name=action value="insert">
<h3>Add Agency Account</h3>
<div class="table-responsive">
    <table class="table table-striped table-sm">
        <thead>
        <tr>
            <th>Username</th>
            <th>Password</th>
            <th>Level</th>
            <th>Notes</th>
            <th>Status</th>
            <th></th>
        <tr>
        </thead>
        <tbody>
            <td><input class="form-input" type=text name=login></td>
            <td><input class="form-input" type=password name=passwd autocomplete="new-password"></td>
            <td><input class="form-input" type=radio name=level value=1>First Review <input class="form-input" type=radio name=level value=2>Final Review <input class="form-input" type=radio name=level value=3>First and Final Review</td>
            <td><input class="form-input" type=text name=notes></td>
            <td><input class="form-input" type=radio name=active value=Yes checked>Enabled <input class="form-input" type=radio name=active value=Pause>Paused</td>
            <td><button type="submit" class="btn btn-sm btn-primary">Add</button></td>
            </tr>
        </tbody>
    </table>
</div>
</form>

{{ template "footer" .}}
