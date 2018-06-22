{{$attach := print "site_id=" (index .ARGS.site_id 0) "&site_md5=" (index .ARGS.site_md5 0) "&site_name=" (index .ARGS.site_name 0 | urlquery)}}
{{$serverUrl := index .ARGS.serverUrl 0}}
{{ template "header" .}}
{{ template "slotheader" .}}
{{$site_str := index .ARGS.site_str 0}}

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
<tr><td><a href="slot?action=edit&{{$attach}}&{{$small}}">{{.slot_name}}</a></td>
<td>{{.qa_platform}}</td>
<td>{{.qa_pagelevel}}</td>
<td>{{.qa_clock}}</td>
<td>{{.qa_yaxis}}</td>
<td>{{.active}}</td>
<td>{{.created}}</td>
<td><button class="btn btn-sm btn-primary" type="button" data-toggle="modal" data-target="#modal{{.slot_id}}">广告码</button></td>
<td><a class="btn btn-sm btn-danger" onClick="return (confirm('Do you want to remove your site {{.slot_name}}?')) ? true : false;" href="slot?action=delete&slot_id={{.slot_id}}&{{$attach}}">删除</a></td>
{{end}}</tobdy>

</table>
</div>

{{ range $item := .Lists }}
<div class="modal fade" id="modal{{$item.slot_id}}" tabindex="-1" role="dialog" aria-labelledby="modal{{$item.slot_id}}Label" aria-hidden="true">
          <div class="modal-dialog" role="document">
            <div class="modal-content">
              <div class="modal-header">
                <h4 class="modal-title">应用网页广告码放置</h4>
                <button type="button" class="close" data-dismiss="modal" aria-label="Close">
                  <span aria-hidden="true">×</span>
                </button>
              </div>
              <div class="modal-body">
                <pre><code>
&lt;html&gt;
&lt;head&gt;
&lt;script src=&quot;{{$serverUrl}}/js/ads.js&quot;&gt;&lt;/script&gt;
&lt;/head&gt;
&lt;body&gt;
...
&lt;div id=&quot;pz-{{$item.code}}&quot;&gt;&lt;/div&gt;
...
&lt;/body&gt;
&lt;script&gt;
pzLoadAds({
    platform: 'browser',
    site: '{{$site_str}}',
    adUnits: [{
        code: 'pz-{{$item.code}}',
        slot: '{{$item.slot_str}}',
        mediaTypes: {
{{$item.mediaTypes}}
        }
    }]
})
&lt;/script&gt;
&lt;/html&gt;
                </code></pre>
              </div>
              <div class="modal-footer">
                <button type="button" class="btn btn-secondary" data-dismiss="modal">Close</button>
              </div>
            </div>
            <!-- /.modal-content -->
          </div>
          <!-- /.modal-dialog -->
        </div>
        <!-- /.modal -->
{{end}}

            </div>
          </div>

{{ template "footer" }}

</body>
</html>

