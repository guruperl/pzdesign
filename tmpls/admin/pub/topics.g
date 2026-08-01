{{ template "header" .}}
{{ template "pubheader" .}}

<h3>全部流量方账户</h3>
<div class="table-responsive">
	<table class="table table-striped table-sm">
    	<thead>
        <tr>
			<th>流量方 ID</th>
            <th>域名</th>
			<th>QPS</th>
			<th>实际 QPS</th>
			<th>状态</th>
            <th>创建时间</th>
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
{{if eq .active "New"}}<a class="btn btn-sm btn-primary" href="pub?action=update&active=Yes&pub_id={{.pub_id}}">激活</a>{{end}}
{{if eq .active "Yes"}}<a class="btn btn-sm btn-danger" href="pub?action=takedown&active=No&pub_id={{.pub_id}}">停用</a>{{end}}
{{if eq .active "No"}}<a class="btn btn-sm btn-warning" href="pub?action=takedown&active=Yes&pub_id={{.pub_id}}">重新激活</a>{{end}}
</td>
				<td><a class="btn btn-sm btn-success" href="manage?action=login_as&role=pub&email={{.email | urlquery}}" target="_blank">进入账户</a></td>
			</tr>{{end}}{{end}}
			<tr>
			<th colspan=8>添加流量方（SSP/ADX）</th>
			</tr>
			<tr><form class="form" action=pub method=post>
			<input type=hidden name=action value="insert" />
			<input type=hidden name=active value="Yes" />
			<td> </td>
			<td><input class="form-input" type=text name=domain /></td>
			<td><input class="form-input" type=text name=limit_imp /></td>
			<td><input class="form-input" type=hidden name=current_imp value=0 /></td>
			<td colspan=4><button type="submit" class="btn btn-sm btn-primary">添加</button></td>
			</form></tr>
		</tbody>
	</table>
</div>

{{ template "footer" .}}
