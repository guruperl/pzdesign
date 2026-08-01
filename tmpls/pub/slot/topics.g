{{ template "header" .}}
{{ template "slotheader" .}}

          <div class="card">
            <div class="card-header">
              流量源“<em>{{index .ARGS.site_name 0}}</em>”下的广告位
            </div>
            <div class="card-body">

<div class="table-responsive">
<table class="table table-striped table-sm">
              <thead>
                <tr>
                  <th>广告位名称</th>
                  <th>设备平台</th>
                  <th>启用状态</th>
                  <th>上线时间</th>
                  <th colspan=3 class="text-right"><a class="btn btn-primary" href="javascript:void(0);" data-title="添加广告位" data-href="slot?action=startnew&site_id={{index .ARGS.site_id 0}}&site_md5={{index .ARGS.site_md5 0}}&site_name={{index .ARGS.site_name 0 | urlquery}}" id="startnewPopup">添加广告位</a></th>
                </tr>
              </thead>
              <tbody>{{ range .Lists }}
<tr><td><a href="javascript:void(0);" data-title="广告位更新：{{.slot_name}}" data-href="slot?action=edit&site_id={{index $.ARGS.site_id 0}}&site_md5={{index $.ARGS.site_md5 0}}&site_name={{index $.ARGS.site_name 0 | urlquery}}&slot_id={{.slot_id}}&slot_md5={{.slot_md5}}&slot_name={{.slot_name | urlquery}}" id="editPopup">{{.slot_name}}</a></td>
<td>{{.qa_device_g}}</td>
<td>{{if eq "Yes" .active}}&check; {{else if eq "No" .active}}&#10007;{{else}}&check;{{end}}</td>
<td>{{.created}}</td>
<td><button class="btn btn-sm btn-info" type="button" data-toggle="modal" data-target="#modal{{.slot_id}}">广告码</button></td>
<td><button class="btn btn-sm btn-success" type="button" data-toggle="modal" data-target="#modalAPI{{.slot_id}}">API 接入代码</button></td>
<td><a class="btn btn-sm btn-danger" onClick="return (confirm('确认删除广告位“{{.slot_name}}”吗？此操作不可撤销。')) ? true : false;" href="slot?action=delete&slot_id={{.slot_id}}&site_id={{index $.ARGS.site_id 0}}&site_md5={{index $.ARGS.site_md5 0}}&site_name={{index $.ARGS.site_name 0 | urlquery}}">删除</a></td>
{{end}}</tobdy>

</table>
</div>

{{ range $item := .Lists }}
<div class="modal fade" id="modal{{$item.slot_id}}" tabindex="-1" role="dialog" aria-labelledby="modal{{$item.slot_id}}Label" aria-hidden="true">
          <div class="modal-dialog" role="document">
            <div class="modal-content">
              <div class="modal-header">
                <h4 class="modal-title">网页广告码</h4>
                <button type="button" class="close" data-dismiss="modal" aria-label="关闭">
                  <span aria-hidden="true">×</span>
                </button>
              </div>
              <div class="modal-body">
                <textarea class="form-control" rows="24" id="browserCode{{$item.slot_id}}" readonly>{{$item.browser_code}}</textarea>
              </div>
              <div class="modal-footer">
                <button type="button" class="btn btn-primary" onclick="pzCopyCode('browserCode{{$item.slot_id}}')">复制</button>
                <button type="button" class="btn btn-success" onclick="pzDownloadCode('browserCode{{$item.slot_id}}', 'aofei-slot-{{$item.slot_id}}.html')">下载</button>
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
                <h4 class="modal-title">SDK / API 接入代码</h4>
                <button type="button" class="close" data-dismiss="modal" aria-label="关闭">
                  <span aria-hidden="true">×</span>
                </button>
              </div>
              <div class="modal-body">
                <textarea class="form-control" rows="22" id="apiCode{{$item.slot_id}}" readonly>{{$item.api_code}}</textarea>
              </div>
              <div class="modal-footer">
                <button type="button" class="btn btn-primary" onclick="pzCopyCode('apiCode{{$item.slot_id}}')">复制</button>
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

  function pzCopyCode(id) {
    var field = document.getElementById(id);
    if (!field) {
      return;
    }
    field.focus();
    field.select();
    if (navigator.clipboard && navigator.clipboard.writeText) {
      navigator.clipboard.writeText(field.value);
      return;
    }
    document.execCommand('copy');
  }

  function pzDownloadCode(id, filename) {
    var field = document.getElementById(id);
    if (!field) {
      return;
    }
    var blob = new Blob([field.value], {type: 'text/html;charset=utf-8'});
    var link = document.createElement('a');
    link.href = URL.createObjectURL(blob);
    link.download = filename;
    document.body.appendChild(link);
    link.click();
    document.body.removeChild(link);
    URL.revokeObjectURL(link.href);
  }
</script>


</body>
</html>
