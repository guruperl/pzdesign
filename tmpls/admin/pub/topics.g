{{ template "header" .}}
{{ template "pubheader" .}}

<h3>所有媒体商家</h3>
<div class="table-responsive">
	<table class="table table-striped table-sm">
    	<thead>
        <tr>
            <th>邮箱</th>
            <th>联系人</th>
        	<th>公司</th>
			<th>状态</th>
            <th>入网时间</th>
            <th></th>
            <th></th>
            <th></th>
        </tr>
        </thead>
        <tbody>{{ with .Lists }}{{ range . }}
			<tr>
				<td><a href="pub?action=edit&pub_id={{.pub_id}}">{{.email}}</a></td>
				<td>{{.firstname}} {{.lastname}}</td>
				<td>{{.company}}</td>
				<td>{{.active}}</td>
				<td>{{.created}}</td>
				<td>
{{if eq .active "New"}}<a class="btn btn-sm btn-primary" href="pub?action=update&active=Yes&pub_id={{.pub_id}}">激活</a>{{end}}
{{if eq .active "Yes"}}<a class="btn btn-sm btn-danger" href="pub?action=update&active=No&pub_id={{.pub_id}}">拿下</a>{{end}}
{{if eq .active "No"}}<a class="btn btn-sm btn-warning" href="pub?action=update&active=Yes&pub_id={{.pub_id}}">重新激活</a>{{end}}
</td>
				<td><a class="btn btn-sm btn-success" href="manage?action=login_as&role=pub&email={{.email | urlquery}}" target="_blank">As</a></td>
				<td><a href="pub?action=delete&pub_id={{.pub_id}}">删除</a></td>
			</tr>{{end}}{{end}}
		</tbody>
	</table>
</div>

{{ template "footer" .}}
