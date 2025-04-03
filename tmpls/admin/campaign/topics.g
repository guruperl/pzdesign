{{ template "header" .}}
{{ template "campaignheader" .}}

<h3>所有活动</h3>
<div class="table-responsive">
	<table class="table table-striped table-sm">
    	<thead>
        <tr>
        	<th>活动名</th>
        	<th>分类</th>
        	<th>公司</th>
        	<th>Bundle</th>
            <th>入网时间</th>
		<th>状态</th>
            <th>（限时段更新）</th>
            <th></th>
        </tr>
        </thead>
        <tbody>{{ with .Lists }}{{ range . }}
			<tr>
				<!-- td><a href="campaign?action=edit&campaign_id={{.campaign_id}}">{{.campaign_name}}</a></td -->
				<td><a href="item?action=topics&campaign_id={{.campaign_id}}&campaign_name={{.campaign_name|urlquery}}">{{.campaign_name}}</a></td>
				<td>{{.target_type}}</td>
				<td>{{.domain}}</td>
				<td>{{.foreign_id}}</td>
				<td>{{.created}}</td>
				<td>{{.active}}</td>
				<td>
{{if eq .active "New"}}<a class="btn btn-sm btn-primary" href="campaign?action=update&active=Yes&campaign_id={{.campaign_id}}">激活</a>{{end}}
{{if eq .active "Yes"}}<a class="btn btn-sm btn-info" href="campaign?action=update&active=Pause&campaign_id={{.campaign_id}}">暂停</a> <a class="btn btn-sm btn-danger" href="campaign?action=update&active=No&campaign_id={{.campaign_id}}">拿下</a>{{end}}
{{if eq .active "Pause"}}<a class="btn btn-sm btn-warning" href="campaign?action=update&active=Yes&campaign_id={{.campaign_id}}">重新播</a>
<a class="btn btn-sm btn-warning" href="campaign?action=update&active=No&campaign_id={{.campaign_id}}">拿下</a>{{end}}
{{if eq .active "No"}}<a class="btn btn-sm btn-warning" href="campaign?action=update&active=Yes&campaign_id={{.campaign_id}}">重新激活</a>{{end}}
</td>
				<td><a href="campaign?action=delete&campaign_id={{.campaign_id}}">删除</a></td>
			</tr>{{end}}{{end}}
		</tbody>
	</table>
</div>

{{ template "footer" .}}
