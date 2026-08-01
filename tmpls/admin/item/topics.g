{{ template "header" .}}
{{ template "itemheader" .}}

<h3>广告活动“{{index .ARGS.campaign_name 0}}”下的广告组</h3>
<div class="table-responsive">
	<table class="table table-striped table-sm">
    	<thead>
        <tr>
	        <th>广告组名称</th>
            <th>计费方式与价格</th>
            <th>开始</th>
            <th>结束</th>
			<th>状态</th>
            <th>（即时更新）</th>
            <th></th>
        </tr>
        </thead>
        <tbody>{{ with .Lists }}{{ range . }}
			<tr>
				<td><a href="item?action=edit&item_id={{.item_id}}">{{.item_name}}</a></td>
				<td>{{.cost_type}} {{.cost}}</td>
				<td>{{.startx}}</td>
				<td>{{.endx}}</td>
				<td>{{.active}}</td>
				<td>
{{if eq .active "New"}}<a class="btn btn-sm btn-primary" href="item?action=update&how=Get&active=Yes&item_id={{.item_id}}">激活</a>{{end}}
{{if eq .active "Yes"}}<a class="btn btn-sm btn-info" href="item?action=update&how=Delete&active=Pause&item_id={{.item_id}}">暂停</a> <a class="btn btn-sm btn-danger" href="item?action=update&how=Delete&active=No&item_id={{.item_id}}">停用</a>{{end}}
{{if eq .active "Pause"}}<a class="btn btn-sm btn-warning" href="item?action=update&how=Get&active=Yes&item_id={{.item_id}}">恢复投放</a>
<a class="btn btn-sm btn-warning" href="item?action=update&active=No&item_id={{.item_id}}">停用</a>{{end}}
{{if eq .active "No"}}<a class="btn btn-sm btn-warning" href="item?action=update&Get=Yes&item_id={{.item_id}}">重新激活</a>{{end}}
</td>
				<td><a href="item?action=delete&item_id={{.item_id}}">删除</a></td>
			</tr>{{end}}{{end}}
		</tbody>
	</table>
</div>

{{ template "footer" .}}
