{{ template "header" .}}
{{ template "itemheader" .}}

<div class="row">
                <div class="col-lg-12">
                    <div class="panel panel-primary">
                        <div class="panel-heading">
                            广告活动“{{index .ARGS.campaign_name 0}}”下的广告组
                        </div>
                        <!-- /.panel-heading -->
                        <div class="panel-body">

                            <div class="table-responsive">
								<table class="table table-striped table-nordered table-hover">
<thead><tr>
<th>名称</th>
<th>价格</th>
<th>审核</th>
<th>MIME</th>
<th>时间</th>
<th colspan=4 class="text-right"><a class="btn btn-primary" href="javascript:void(0);" data-title="添加广告组" data-href="item?action=startnew&campaign_id={{index .ARGS.campaign_id 0}}&campaign_md5={{index .ARGS.campaign_md5 0}}&campaign_name={{index .ARGS.campaign_name 0 | urlquery}}" id="startnewPopup">新建广告组</a></th>
</tr></thead>
<tbody>{{with .Lists}}{{range .}}
<tr {{if eq .active "New"}}class="warning"{{else if eq .active "Pause"}}class="danger"{{else}}{{end}}>
<td><a href="javascript:void(0);" data-title="更新广告组：{{.item_name}}" data-href="item?action=edit&campaign_id={{index $.ARGS.campaign_id 0}}&campaign_md5={{index $.ARGS.campaign_md5 0}}&campaign_name={{index $.ARGS.campaign_name 0 | urlquery}}&item_id={{.item_id}}&item_md5={{.item_md5}}&item_name={{.item_name | urlquery}}" id="editPopup">{{.item_name}}</a></td>
<td>{{.cost}} {{.cost_type}}</td>
<td>{{if eq .active "Prepare"}} <a class="btn btn-sm btn-success" onClick="return (confirm('一旦送审，素材将无法再做修改。请添加完素材之后再送审。确认送审吗？')) ? true : false;" href="item?action=review&item_id={{.item_id}}&active=New&campaign_id={{index $.ARGS.campaign_id 0}}&campaign_md5={{index $.ARGS.campaign_md5 0}}&campaign_name={{index $.ARGS.campaign_name 0 | urlquery}}">送审</a>{{else if eq .active "Yes"}}通过{{else}}{{.active}}{{end}}</td>
<td>{{.qa_chinese}}</td>
<td>{{.startx}}/{{.endx}}</td>
<td><a class="btn btn-sm btn-primary" href="javascript:void(0);" data-title="素材管理：{{.item_name}}" data-href="creative?action=topics&campaign_id={{index $.ARGS.campaign_id 0}}&campaign_md5={{index $.ARGS.campaign_md5 0}}&campaign_name={{index $.ARGS.campaign_name 0 | urlquery}}&item_id={{.item_id}}&item_md5={{.item_md5}}&item_name={{.item_name | urlquery}}&active={{.active}}&qa_mime={{.qa_mime}}&item_click={{.item_click|urlquery}}" id="creativePopup">素材管理</a></td>
<td><a class="btn btn-sm btn-info" href="javascript:void(0);" data-title="预算规划：{{.item_name}}" data-href="balance?action=topics&campaign_id={{index $.ARGS.campaign_id 0}}&campaign_md5={{index $.ARGS.campaign_md5 0}}&campaign_name={{index $.ARGS.campaign_name 0 | urlquery}}&item_id={{.item_id}}&item_md5={{.item_md5}}&item_name={{.item_name | urlquery}}&entitytype_id=42" id="balancePopup">预算规划</a></td>
<td><a class="btn btn-sm btn-success" href="targetname?action=topics&campaign_id={{index $.ARGS.campaign_id 0}}&campaign_md5={{index $.ARGS.campaign_md5 0}}&campaign_name={{index $.ARGS.campaign_name 0 | urlquery}}&item_id={{.item_id}}&item_md5={{.item_md5}}&item_name={{.item_name | urlquery}}&entitytype_id=42">人群定向</a></td>
<td><a class="btn btn-sm btn-danger" onClick="return (confirm('确认要删除广告组“{{.item_name}}”吗？此操作不可撤销。')) ? true : false;" href="item?action=delete&campaign_id={{index $.ARGS.campaign_id 0}}&campaign_md5={{index $.ARGS.campaign_md5 0}}&campaign_name={{index $.ARGS.campaign_name 0 | urlquery}}&item_id={{.item_id}}&item_md5={{.item_md5}}&item_name={{.item_name | urlquery}}">删除</a></td>
</tr>{{end}}{{end}}
</tbody>
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
        <h4 id="d-title" class="modal-title">广告组</h4>
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

{{template "footer"}}
