{{$attach := print "campaign_id=" (index .ARGS.campaign_id 0) "&campaign_md5=" (index .ARGS.campaign_md5 0) "&campaign_name=" (index .ARGS.campaign_name 0 | urlquery)}}

{{ template "header" .}}
{{ template "itemheader" .}}

<div class="row">
                <div class="col-lg-12">
                    <div class="panel panel-primary">
                        <div class="panel-heading">
                            {{index .ARGS.campaign_name 0}}的创意
                        </div>
                        <!-- /.panel-heading -->
                        <div class="panel-body">

                            <div class="table-responsive">
								<table class="table table-striped table-nordered table-hover">
<thead><tr>
<th>创意名</th>
<th>价格</th>
<th>状态</th>
<th>媒体类</th>
<th>时间</th>
<th colspan=3 class="text-right"><a class="btn btn-primary" href="javascript:void(0);" data-title="添加创意" data-href="item?action=startnew&{{$attach}}" id="startnewPopup">新建创意</a></th>
</tr></thead>
<tbody>{{with .Lists}}{{range .}}
{{$second := print "item_id=" .item_id "&item_md5=" .item_md5 "&item_name=" (.item_name | urlquery)}}
<tr {{if eq .active "New"}}class="warning"{{else if eq .active "Pause"}}class="danger"{{else}}{{end}}>
<td><a href="javascript:void(0);" data-title="更新创意：{{.item_name}}" data-href="item?action=edit&{{$attach}}&{{$second}}" id="editPopup">{{.item_name}}</a></td>
<td>{{.cost}} {{.cost_type}}</td>
<td>{{if eq .active "Prepare"}} <a class="btn btn-sm btn-success" onClick="return (confirm('一旦送审，物料将无法再做修改。请添加完物料之后再送审。确认送审吗？')) ? true : false;" href="item?action=review&item_id={{.item_id}}&active=New&{{$attach}}">送审</a>{{else}}{{.active}}{{end}}</td>
<td>{{.qa_mime}}</td>
<td>{{.startx}}/{{.endx}}</td>
<td><a class="btn btn-sm btn-primary" href="javascript:void(0);" data-title="物料管理：{{.item_name}}" data-href="creative?action=topics&{{$attach}}&{{$second}}&active={{.active}}&qa_mime={{.qa_mime}}&size_id={{.size_id}}&item_click={{.item_click|urlquery}}" id="creativePopup">物料管理</a></td>
<td><a class="btn btn-sm btn-info" href="javascript:void(0);" data-title="创意预算：{{.item_name}}" data-href="balance?action=topics&{{$attach}}&{{$second}}&entitytype_id=42" id="balancePopup">创意预算</a></td>
<td><a class="btn btn-sm btn-danger" onClick="return (confirm('确认要删除此创意 {{.item_name}}吗？此操作不可更改。')) ? true : false;" href="item?action=delete&{{$attach}}&{{$second}}">删除</a></td>
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
        <h4 id="d-title" class="modal-title">创意</h4>
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
