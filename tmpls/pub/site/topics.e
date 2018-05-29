{{ template "header" .}}
{{ template "siteheader" .}}

          <div class="card">
            <div class="card-header">
              Current List
            </div>
            <div class="card-body">

<div class="table-responsive">
<table class="table table-striped table-sm">
              <thead>
                <tr>
                  <th>Name</th>
                  <th>URL</th>
                  <th>Since</th>
                  <th>Active</th>
                  <th colspan=2 class="text-right"><a class="btn btn-info" href="site?action=startnew">Create New</a> </th>
                </tr>
              </thead>
              <tbody>{{ with .Lists }}{{ range . }}
<tr>
<td><a href="site?action=edit&site_id={{.site_id}}&site_md5={{.site_md5}}&site_name={{.site_name | urlquery }}">{{.site_name}}</a></td>
<td>{{.site_url}}</td>
<td>{{.created}}</td>
<td>{{.active}}</td>
<td><a class="btn btn-sm btn-primary" href="slot?action=topics&site_id={{.site_id}}&site_md5={{.site_md5}}&site_name={{.site_name | urlquery }}">Slots</a></td>
<!--
td><a href="chac?action=topics&site_id={{.site_id}}&site_md5={{.site_md5}}&site_name={{.site_name | urlquery }}&entitytype_id=31">Channels</a></td>
<td><a href="ac?action=topics&site_id={{.site_id}}&site_md5={{.site_md5}}&site_name={{.site_name | urlquery }}&entitytype_id=31">BW</a></td
-->
<td><a class="btn btn-sm btn-danger" onClick="return (confirm('Do you want to remove your site {{.site_name}}?')) ? true : false;" href="site?action=delete&site_id={{.site_id}}">Del</a></td>
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

