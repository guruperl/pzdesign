{{$attach := print "site_id=" (index .ARGS.site_id 0) "&site_md5=" (index .ARGS.site_md5 0) "&site_name=" (index .ARGS.site_name 0 | urlquery)}}
{{ template "header" .}}
{{ template "slotheader" .}}

          <div class="card">
            <div class="card-header">
              如下网站的所用广告位：<em>{{index .ARGS.site_name 0}}</em>
            </div>
            <div class="card-body">

<div class="table-responsive">
<table class="table table-striped table-sm">
              <thead>
                <tr>
                  <th>广告位名</th>
                  <th>平台</th>
                  <th>页面等级</th>
                  <th>时钟位置</th>
                  <th>上下位置</th>
                  <th>激活状况</th>
                  <th>上线时间</th>
                  <th colspan=2 class="text-right"><a class="btn btn-info" href="slot?action=startnew&{{$attach}}">填加广告位</a> </th>
                </tr>
              </thead>
              <tbody>{{ range .Lists }}
{{$small := print "slot_id=" .slot_id "&slot_md5=" .slot_md5 "&slot_name=" (.slot_name | urlquery)}}
<tr><td><a href="slot?action=edit&slot_id={{.slot_id}}&{{$attach}}&{{$small}}">{{.slot_name}}</a></td>
<td>{{.qa_platform}}</td>
<td>{{.qa_pagelevel}}</td>
<td>{{.qa_clock}}</td>
<td>{{.qa_yaxis}}</td>
<td>{{.active}}</td>
<td>{{.created}}</td>
<td><a class="btn btn-sm btn-primary" href="/pz/{{.site_id}}/{{.slot_id}}.js">广告码</a></td>
<td><a class="btn btn-sm btn-danger" onClick="return (confirm('Do you want to remove your site {{.slot_name}}?')) ? true : false;" href="slot?action=delete&slot_id={{.slot_id}}&{{$attach}}">删除</a></td>
{{end}}</tobdy>

</table>
</div>

            </div>
          </div>

{{ template "footer" }}

</body>
</html>

