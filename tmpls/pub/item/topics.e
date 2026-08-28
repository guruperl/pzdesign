<div class="table-responsive">
<table class="table table-striped table-nordered table-hover">
<thead><tr>
<th>Ad Group Name</th>
<th>Price</th>
<th>Status</th>
<th>Creative Type</th>
<th>Start/End</th>
</tr></thead>
<tbody>{{with .Lists}}{{range .}}
<tr>
<td>{{.item_name}}</td>
<td>{{if eq .cost_type "CPM"}}{{.cost}} USD CPM{{else}}Disabled (legacy {{.cost_type}} record){{end}}</td>
<td>{{.active}}</td>
<td>{{.qa_mime}}</td>
<td>{{.startx}}/{{.endx}}</td>
</tr><tr>
<td colspan=5>{{range $c := .creative_topics}}
<p>Creative source content (safely escaped; never executed or loaded):</p><pre class="creative-source">{{$c.content}}</pre>
{{end}}</td>
</tr>{{end}}{{end}}
</tbody>
</table>
</div>
<!-- /.table-responsive -->
