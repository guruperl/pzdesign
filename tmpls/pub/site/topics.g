{{ template "header" .}}
{{ template "siteheader" .}}

          <div class="card">
            <div class="card-header">
              流量源列表
            </div>
            <div class="card-body">

<div class="table-responsive">
<table class="table table-striped table-sm">
              <thead>
                <tr>
                  <th>流量源名称</th>
                  <th>URL</th>
                  <th>流量环境</th>
                  <th>接入方式</th>
                  <th>上线时间</th>
                  <th>激活状况</th>
<th colspan=2 class="text-right"><a class="btn btn-primary" href="#" data-title="添加流量源" data-href="site?action=startnew" id="startnewPopup">添加网站或 App</a> </th>
                </tr>
              </thead>
              <tbody>{{ with .Lists }}{{ range . }}
<tr>
<td><a href="#" data-title="流量源更新：{{.site_name}}" data-href="site?action=edit&site_id={{.site_id}}&site_md5={{.site_md5}}&site_name={{.site_name | urlquery }}" id="editPopup">{{.site_name}}</a></td>
<td>{{.site_url}}</td>
<td>{{.inventory_environment}}</td>
<td>{{.integration_mode}}</td>
<td>{{.created}}</td>
<td>{{.active}}</td>
<td><a class="btn btn-sm btn-info" href="slot?action=topics&site_id={{.site_id}}&site_md5={{.site_md5}}&site_name={{.site_name | urlquery }}&site_type={{.site_type | urlquery}}">所有广告位</a></td>
<td><a class="btn btn-sm btn-danger" onClick="return (confirm('确认删除流量源“{{.site_name}}”吗？此操作不可撤销。')) ? true : false;" href="site?action=delete&site_id={{.site_id}}">删除</a></td>
</tr>
{{end}}{{end}}</tobdy>
</table>
</div>

            </div>
            <!-- /.card body -->
          </div>
          <!-- /.card -->


<!-- Modal -->
<div class="modal fade" id="myModal" role="dialog">
  <div class="modal-dialog modal-lg">
    <!-- Modal content-->
    <div class="modal-content">
      <div class="modal-header">
        <h4 id="d-title" class="modal-title">站</h4>
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
      $('#d-title').text(dataTITLE);
      $('#d-body').load(dataURL,function(){
        $('#myModal').modal({show:true});
      });
    });
  });
</script>


</body>
</html>
