{{ template "header" .}}
{{ template "agentheader" .}}

<h3>所有审查单位名单</h3>
<div class="table-responsive">
	<table class="table table-striped table-sm">
    	<thead>
        <tr>
        	<th>名称</th>
        	<th>等级</th>
			<th>附注</th>
            <th>状态</th>
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
			<td><a class="btn btn-sm btn-success" href="manage?action=login_as&role=agent&login={{.login | urlquery}}" target="_blank">As</a></td>
			<td><a href="agent?action=delete&agent_id={{.agent_id}}">删除</a></td>
			</tr>{{end}}{{end}}
		</tbody>
	</table>
</div>

<form class="form" action=agent method=post><input type=hidden name=action value="insert">
<h3>添加审核单位</h3>
<div class="table-responsive">
	<table class="table table-striped table-sm">
    	<thead>
        <tr>
        	<th>用户名</th>
        	<th>密码</th>
        	<th>等级</th>
			<th>附录</th>
            <th>状态</th>
            <th></th>
		<tr>
        </thead>
		<tbody>
			<td><input class="form-input" type=text name=login></td>
			<td><input class="form-input" type=text name=passwd></td>
			<td><input class="form-input" type=radio name=level value=1>1 <input class="form-input" type=radio name=level value=2>2 <input class="form-input" type=radio name=level value=3>both</td>
			<td><input class="form-input" type=text name=notes></td>
			<td><input class="form-input" type=radio name=active value=Yes>Yes <input class="form-input" type=radio name=active value=New>New</td>
			<td><button type="submit" class="btn btn-sm btn-primary">添加</button></td>
			</tr>
		</tbody>
	</table>
</div>
</form>

{{ template "footer" .}}
