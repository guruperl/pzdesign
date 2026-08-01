{{ template "header" .}}
{{ template "midrouteheader" .}}
{{ template "midroute_group_nav" .}}
{{$group := index .Other "midroute_group"}}

<div class="mb-3">
  <a class="btn btn-primary" href="midroute?action=startnewTarget&group_id={{$group.group_id}}">添加流量目标</a>
</div>

<div class="table-responsive">
  <table class="table table-striped table-sm">
    <thead>
      <tr>
        <th>ID</th>
        <th>优先级</th>
        <th>范围</th>
        <th>实体</th>
        <th>尺寸</th>
        <th>启用</th>
        <th></th>
      </tr>
    </thead>
    <tbody>{{ with .Lists }}{{ range . }}
      <tr>
        <td>{{.target_id}}</td>
        <td>{{.priority}}</td>
        <td>{{if .entitytype_pub}}流量方{{else if .entitytype_site}}流量源{{else if .entitytype_slot}}广告位{{else}}全部流量{{end}}</td>
        <td>{{.entity_id}} {{.entity_name}}</td>
        <td>{{.size_id}} {{.size_name}}</td>
        <td>{{.active}}</td>
        <td><a class="btn btn-sm btn-primary" href="midroute?action=editTarget&target_id={{.target_id}}">编辑</a></td>
      </tr>
    {{end}}{{else}}
      <tr><td colspan="7">暂无流量目标。</td></tr>
    {{end}}</tbody>
  </table>
</div>

{{ template "footer" .}}
