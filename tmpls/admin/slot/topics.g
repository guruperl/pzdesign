{{ template "header" .}}
{{ template "siteheader" .}}

<h3>站{{index .ARGS.site_name 0}}下的广告位</h3>
<div class="table-responsive">
	<table class="table table-striped table-sm">
    	<thead>
        <tr>
            <th>广告位名</th>
            <th>尺寸</th>
			<th>分类 / 质量</th>
			<th>状态</th>
            <th>创建时间</th>
            <th></th>
            <th></th>
        </tr>
        </thead>
        <tbody>{{ with .Lists }}{{ range . }}
			<tr>
				<td><a href="slot?action=edit&slot_id={{.slot_id}}">{{.slot_name}}</a></td>
				<td>{{.w}} × {{.h}}</td>
				<td>{{.media_intent}} / {{.placement}} / {{.traffic_quality}} / {{.source_quality}}</td>
				<td>{{.active}}</td>
				<td>{{.created}}</td>
				<td>
{{if eq .active "New"}}<a class="btn btn-sm btn-primary" href="slot?action=update&active=Yes&slot_id={{.slot_id}}">激活</a>{{end}}
{{if eq .active "Yes"}}<a class="btn btn-sm btn-danger" href="slot?action=update&active=No&slot_id={{.slot_id}}">停用</a>{{end}}
{{if eq .active "No"}}<a class="btn btn-sm btn-warning" href="slot?action=update&active=Yes&slot_id={{.slot_id}}">重新激活</a>{{end}}
</td>
				<td><a href="slot?action=delete&slot_id={{.slot_id}}">删除</a></td>
			</tr>{{end}}{{end}}
		</tbody>
	</table>
</div>

{{ template "footer" .}}
