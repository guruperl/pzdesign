{{ template "header" .}}
{{ template "siteheader" .}}

<h3>所有App和站</h3>
<div class="table-responsive">
	<table class="table table-striped table-sm">
    	<thead>
        <tr>
            <th>名称</th>
            <th>媒体公司</th>
        	<th>URL</th>
			<th>状态</th>
            <th>入网时间</th>
            <th></th>
			<th></th>
        </tr>
        </thead>
        <tbody>{{ with .Lists }}{{ range . }}
			<tr>
				<td><a href="slot?action=topics&pub_id={{.pub_id}}&site_id={{.site_id}}&site_name={{.site_name|urlquery}}">{{.site_name}}</a></td>
				<td>{{.company}}</td>
				<td>{{.site_url}}</td>
				<td>{{.active}}</td>
				<td>{{.created}}</td>
				<td>
{{if eq .active "New"}}<a class="btn btn-sm btn-primary" href="site?action=update&active=Yes&site_id={{.site_id}}">激活</a>{{end}}
{{if eq .active "Yes"}}<a class="btn btn-sm btn-danger" href="site?action=update&active=No&site_id={{.site_id}}">拿下</a>{{end}}
{{if eq .active "No"}}<a class="btn btn-sm btn-warning" href="site?action=update&active=Yes&site_id={{.site_id}}">重新激活</a>{{end}}
</td>
				<td><a href="site?action=delete&site_id={{.site_id}}">删除</a></td>
			</tr>{{end}}{{end}}
		</tbody>
	</table>
</div>

{{ template "footer" .}}
