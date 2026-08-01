{{ template "header" .}}
{{ template "campaignheader" .}}

<div class="row">
                <div class="col-lg-12">
                    <div class="panel panel-primary">
                        <div class="panel-heading">
                            广告活动
                        </div>
                        <!-- /.panel-heading -->
                        <div class="panel-body">
                            <div class="table-responsive">
<table class="table table-striped table-nordered table-hover">
              <thead>
                <tr>
                  <th>活动名称</th>
		  <th>类型</th>
		  <th>创建日期</th>
                  <th>预算</th>
                  <th>曝光</th>
                  <th>点击</th>
                  <th colspan=3 class="text-right"><a class="btn btn-primary" href="javascript:void(0);" data-title="添加广告活动" data-href="campaign?action=startnew" id="startnewPopup">创建广告活动</a></th>
                </tr>
              </thead>
              <tbody>{{ with .Lists }}{{ range . }}
<tr>
{{$small := print "campaign_id=" .campaign_id "&campaign_md5=" .campaign_md5 "&campaign_name=" (.campaign_name | urlquery )}}
<td><a href="javascript:void(0);" data-title="活动更新：{{.campaign_name}}" data-href="campaign?action=edit&{{$small}}" id="editPopup">{{.campaign_name}}</a></td>
<td>{{.target_type}}</td>
<td>{{.created}}</td>
<td>{{.limit_spend}}</td>
<td>{{.limit_imp}}</td>
<td>{{.limit_cli}}</td>
<td><a class="btn btn-sm btn-primary" href="item?action=topics&{{$small}}">广告组</a></td>
<td><a class="btn btn-sm btn-info" href="javascript:void(0);" data-title="活动预算：{{.campaign_name}}" data-href="balance?action=topics&{{$small}}&entitytype_id=41" id="balancePopup">活动预算</a></td>
<td><a class="btn btn-sm btn-danger" onClick="return (confirm('确认删除广告活动“{{.campaign_name}}”吗？此操作不可撤销。')) ? true : false;" href="campaign?action=delete&campaign_id={{.campaign_id}}">删除</a></td>
</tr>
{{end}}{{end}}</tobdy>
                                </table>
                            </div>
                            <!-- /.table-responsive -->
                        </div>
                        <!-- /.panel-body -->
                    </div>
                    <!-- /.panel -->
                </div>
                <!-- /.col-lg-6 -->
 </div>


<!-- Modal -->
<div class="modal fade" id="myModal" role="dialog">
  <div class="modal-dialog modal-lg">
    <!-- Modal content-->
    <div class="modal-content">
      <div class="modal-header">
        <h4 id="d-title" class="modal-title">广告活动</h4>
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
