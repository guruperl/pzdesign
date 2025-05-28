{{ template "header" .}}
{{ template "advheader" .}}

<h3>所有商户</h3>
<div class="table-responsive">
	<table class="table table-striped table-sm">
    	<thead>
        <tr>
            <th>邮箱</th>
        	<th>联系人</th>
        	<th>公司</th>
			<th>状态</th>
            <th>余款</th>
            <th>入网时间</th>
            <th></th>
            <th></th>
        </tr>
        </thead>
        <tbody>{{ with .Lists }}{{ range . }}
			<tr>
				<td><a href="adv?action=edit&adv_id={{.adv_id}}">{{.email}}</a></td>
				<td>{{.firstname}}</td>
				<td>{{.company}}</td>
				<td>{{.active}}</td>
				<td>{{.balance}}</td>
				<td>{{.created}}</td>
				<td>
{{if eq .active "New"}}<a class="btn btn-sm btn-primary" href="adv?action=update&active=Yes&adv_id={{.adv_id}}">激活</a>{{end}}
{{if eq .active "Yes"}}<a class="btn btn-sm btn-danger" href="adv?action=takedown&active=No&adv_id={{.adv_id}}">拿下</a>{{end}}
{{if eq .active "No"}}<a class="btn btn-sm btn-warning" href="adv?action=takedown&active=Yes&adv_id={{.adv_id}}">重新激活</a>{{end}}
</td>
				<td><a class="btn btn-sm btn-success" href="manage?action=login_as&role=adv&email={{.email | urlquery}}" target="_blank">As</a></td>
			</tr>{{end}}{{end}}
		</tbody>
	</table>
</div>

{{ template "footer" .}}
