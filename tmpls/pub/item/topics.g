<div class="table-responsive">
<table class="table table-striped table-nordered table-hover">
<thead><tr>
<th>名称</th>
<th>价格</th>
<th>状态</th>
<th>流量源类</th>
<th>开始/结束</th>
</tr></thead>
<tbody>{{with .Lists}}{{range .}}{{$mime := .qa_mime}}
<tr>
<td>{{.item_name}}</td>
<td>{{.cost}} {{.cost_type}}</td>
<td>{{.active}}</td>
<td>{{.qa_mime}}</td>
<td>{{.startx}}/{{.endx}}</td>
</tr><tr>
<td colspan=5>{{range $c := .creative_topics}}
{{if eq $mime "html"}}<iframe frameborder=0 src="data:text/html; charset=UTF-8,{{$c.content}}"></iframe>{{else if eq $mime "js"}}<iframe frameborder=0 src="data:text/html; charset=UTF-8,<script>{{$c.content}}</script>"></iframe>{{else if eq $mime "video"}}<video controls><source src="{{$c.content}}"></video>{{else}}<img src="{{$c.content}}" />{{end}}
{{end}}</td>
</tr>{{end}}{{end}}
</tbody>
</table>
</div>
<!-- /.table-responsive -->
