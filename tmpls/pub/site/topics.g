{{ template "header" .}}
{{ template "siteheader" .}}

          <div class="card">
            <div class="card-header">
              媒体组罗列
            </div>
            <div class="card-body">

<div class="table-responsive">
<table class="table table-striped table-sm">
              <thead>
                <tr>
                  <th>组名称</th>
                  <th>URL</th>
                  <th>上线时间</th>
                  <th>激活状况</th>
                  <th colspan=2 class="text-right"><a class="btn btn-info" href="site?action=startnew">添加App或网站</a> </th>
                </tr>
              </thead>
              <tbody>{{ with .Lists }}{{ range . }}
<tr>
<td><a href="site?action=edit&site_id={{.site_id}}&site_md5={{.site_md5}}&site_name={{.site_name | urlquery }}">{{.site_name}}</a></td>
<td>{{.site_url}}</td>
<td>{{.created}}</td>
<td>{{.active}}</td>
<td><a class="btn btn-sm btn-primary" href="slot?action=topics&site_id={{.site_id}}&site_md5={{.site_md5}}&site_name={{.site_name | urlquery }}">所有广告位</a></td>
<!--
td><a href="chac?action=topics&site_id={{.site_id}}&site_md5={{.site_md5}}&site_name={{.site_name | urlquery }}&entitytype_id=31">Channels</a></td>
<td><a href="ac?action=topics&site_id={{.site_id}}&site_md5={{.site_md5}}&site_name={{.site_name | urlquery }}&entitytype_id=31">BW</a></td
-->
<td><a class="btn btn-sm btn-danger" onClick="return (confirm('Do you want to remove your site {{.site_name}}?')) ? true : false;" href="site?action=delete&site_id={{.site_id}}">删除</a></td>
</tr>
{{end}}{{end}}</tobdy>
</table>
</div>

            </div>
            <!-- /.card body -->
          </div>
          <!-- /.card -->


{{ template "footer" }}

</body>
</html>

