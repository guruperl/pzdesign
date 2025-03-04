{{$attach := print "site_id=" (index .ARGS.site_id 0) "&site_md5=" (index .ARGS.site_md5 0) "&site_name=" (index .ARGS.site_name 0 | urlquery)}}
{{$serverUrl := index .ARGS.serverUrl 0}}
{{$serverScript := index .ARGS.serverScript 0}}
{{ template "header" .}}
{{ template "slotheader" .}}
{{$site_str := index .ARGS.site_str 0}}

          <div class="card">
            <div class="card-header">
              <em>{{index .ARGS.site_name 0}}</em>下所有广告位
            </div>
            <div class="card-body">

<div class="table-responsive">
<table class="table table-striped table-sm">
              <thead>
                <tr>
                  <th>广告位名</th>
                  <th>设备平台</th>
                  <th>激活</th>
                  <th>上线时间</th>
                  <th colspan=3 class="text-right"><a class="btn btn-primary" href="javascript:void(0);" data-title="新添加广告位" data-href="slot?action=startnew&{{$attach}}" id="startnewPopup">添加广告位</a></th>
                </tr>
              </thead>
              <tbody>{{ range .Lists }}
{{$small := print "slot_id=" .slot_id "&slot_md5=" .slot_md5 "&slot_name=" (.slot_name | urlquery)}}
<tr><td><a href="javascript:void(0);" data-title="广告位更新：{{.slot_name}}" data-href="slot?action=edit&{{$attach}}&{{$small}}" id="editPopup">{{.slot_name}}</a></td>
<td>{{.qa_device_g}}</td>
<td>{{if eq "Yes" .active}}&check; {{else if eq "No" .active}}&#10007;{{else}}&check;{{end}}</td>
<td>{{.created}}</td>
<td><button class="btn btn-sm btn-info" type="button" data-toggle="modal" data-target="#modal{{.slot_id}}">广告码</button></td>
<td><button class="btn btn-sm btn-success" type="button" data-toggle="modal" data-target="#modalAPI{{.slot_id}}">API码</button></td>
<td><a class="btn btn-sm btn-danger" onClick="return (confirm('确信删除此广告位{{.slot_name}}吗？此操作不可更改。')) ? true : false;" href="slot?action=delete&slot_id={{.slot_id}}&{{$attach}}">删除</a></td>
{{end}}</tobdy>

</table>
</div>

{{ range $item := .Lists }}
<div class="modal fade" id="modal{{$item.slot_id}}" tabindex="-1" role="dialog" aria-labelledby="modal{{$item.slot_id}}Label" aria-hidden="true">
          <div class="modal-dialog" role="document">
            <div class="modal-content">
              <div class="modal-header">
                <h4 class="modal-title">应用网页广告码放置</h4>
                <button type="button" class="close" data-dismiss="modal" aria-label="关闭">
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
                <button type="button" class="btn btn-secondary" data-dismiss="modal">关闭</button>
              </div>
            </div>
            <!-- /.modal-content -->
          </div>
          <!-- /.modal-dialog -->
</div>
<!-- /.modal -->

<div class="modal fade" id="modalAPI{{$item.slot_id}}" tabindex="-1" role="dialog" aria-labelledby="modalAPI{{$item.slot_id}}Label" aria-hidden="true">
          <div class="modal-dialog" role="document">
            <div class="modal-content">
              <div class="modal-header">
                <h4 class="modal-title">API广告码</h4>
                <button type="button" class="close" data-dismiss="modal" aria-label="Close">
                  <span aria-hidden="true">×</span>
                </button>
              </div>
              <div class="modal-body">
POST下列JSON请求至{{$serverScript}}:
                <pre><code>
{
    platform: ‘sdk’,
    site: '{{$site_str}}', 
    ua: 'ANY_UA_STRING',
    ip: 'ANY_IP_STRING',
    adUnits: [{
        code: 'pz-{{$item.code}}',
        slot: '{{$item.slot_str}}',
        mediaTypes: {
{{$item.mediaTypes}}
        }
    }]
}
                </code></pre>
获取如下JSON:
                <pre><code>
[{
        code: 'pz-{{$item.code}}',
        slot: '{{$item.slot_str}}',
        html: ‘DYNAMICAL_HTML’,
        click: 'DYNAMICAL_CLICK_URL',
        notification: ‘DYNAMICAL_NOTIFICATION_URL’
}]
                </code></pre>
其中 code，slot 与送来的参数一样。html 表示在此显示广告的HTML代码，开发者需解析后获取广告素材。
              </div>
              <div class="modal-footer">
                <button type="button" class="btn btn-secondary" data-dismiss="modal">关闭</button>
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

<!-- Modal -->
<div class="modal fade" id="myModal" role="dialog">
  <div class="modal-dialog modal-lg">
    <!-- Modal content-->
    <div class="modal-content">
      <div class="modal-header">
        <h4 id="d-title" class="modal-title">广告位</h4>
        <button type="button" class="close" data-dismiss="modal">&times;</button>
      </div>
      <div id="d-body" class="modal-body"></div>
      <div class="modal-footer">
        <button type="button" class="btn btn-default" data-dismiss="modal">关闭</button>
      </div>
    </div>
    <!-- Modal content-->
  </div>
</div>
<!-- /Modal -->

{{ template "footer" }}
<script>
  $(document).ready(function(){
    $('#startnewPopup,#editPopup').on('click',function(){
      var dataTITLE = $(this).attr('data-title');
      var dataURL = $(this).attr('data-href');
      $('#d-title').html(dataTITLE);
      $('#d-body').load(dataURL,function(){
        $('#myModal').modal({show:true});
      });
    });
  });
</script>


</body>
</html>

