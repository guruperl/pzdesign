<div class="table-responsive">
<table class="table table-striped table-nordered table-hover">
<thead><tr>
<th>广告组名称</th>
<th>价格</th>
<th>状态</th>
<th>素材类型</th>
<th>开始/结束</th>
</tr></thead>
<tbody>{{with .Lists}}{{range .}}
<tr>
<td>{{.item_name}}</td>
<td>{{if eq .cost_type "CPM"}}{{.cost}} USD CPM{{else}}未启用（旧 {{.cost_type}} 记录）{{end}}</td>
<td>{{.active}}</td>
<td>{{.qa_mime}}</td>
<td>{{.startx}}/{{.endx}}</td>
</tr><tr>
<td colspan=5>{{range $c := .creative_topics}}
<p>素材源内容（安全转义，不执行、不加载）：</p><pre class="creative-source">{{$c.content}}</pre>
{{end}}</td>
</tr>{{end}}{{end}}
</tbody>
</table>
</div>
<!-- /.table-responsive -->
