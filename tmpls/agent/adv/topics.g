{{ template "header" .}}
{{ template "advheader" .}}

<h3>所有广告主</h3>
<div class="table-responsive">
	<table class="table table-striped table-sm">
    	<thead>
        <tr>
        	<th>名称</th>
        	<th>公司</th>
			<th>活跃状态</th>
        </tr>
        </thead>
        <tbody>{{ with .Lists }}{{ range . }}
			<tr>
				<td><a href="campaign?action=topics&adv_id={{.adv_id}}&adv_md5={{.adv_md5}}">{{.firstname}}</a></td>
				<td>{{.company}}</td>
				<td>{{.active}}</td>
			</tr>{{end}}{{end}}
		</tbody>
	</table>
</div>

{{ template "footer" .}}
