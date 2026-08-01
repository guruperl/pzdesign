{{ template "header" .}}
{{ template "itemheader" .}}

{{$attach := print "campaign_id=" (index .ARGS.campaign_id 0) "&campaign_md5=" (index .ARGS.campaign_md5 0)}}
{{$next := (index .ARGS.agent_level 0)}}

<h3>广告组列表</h3>
<div class="table-responsive">
	<table class="table table-striped table-sm">
    	<thead>
        <tr>
        	<th>名称</th>
	        <th>广告素材</th>
			<th>审核状态</th>
            <th>创建时间</th>
            <th></th>
        </tr>
        </thead>
        <tbody>{{ with .Lists }}{{ range . }}
			<tr>
				<td>{{.item_name}}</td>
				<td>{{$qa_mime := .qa_mime}}{{range $k, $v := .creative_topics}}{{if eq $qa_mime "html"}}{{$v.content}}{{else if eq $qa_mime "js"}}<script>{{$v.content}}</script>{{else if eq $qa_mime "video"}}<video controls><source src="{{$v.content}}"></video>{{else}}<img src="{{$v.content}}" />{{end}}{{end}}
				<td>{{.active}}</td>
				<td>{{.startx}}</td>
				<td>
{{if ne .active "Yes"}}<a class="btn btn-sm btn-primary" href="item?action=authen&item_id={{.item_id}}&active={{if eq $next `1`}}Pass2{{else}}Yes{{end}}&{{$attach}}">通过</a>
<a class="btn btn-sm btn-warning" href="item?action=authen&item_id={{.item_id}}&active=No&{{$attach}}">不通过</a>{{end}}
</td>
			</tr>{{end}}{{end}}
		</tbody>
	</table>
</div>

{{ template "footer" .}}
