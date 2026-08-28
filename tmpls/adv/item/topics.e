{{ template "header" .}}
{{ template "itemheader" .}}

<div class="row">
                <div class="col-lg-12">
                    <div class="panel panel-primary">
                        <div class="panel-heading">
                            Ad Groups Under Campaign “{{index .ARGS.campaign_name 0}}”
                        </div>
                        <!-- /.panel-heading -->
                        <div class="panel-body">

                            <div class="table-responsive">
                                <table class="table table-striped table-nordered table-hover">
<thead><tr>
<th>Name</th>
<th>Price</th>
<th>Review</th>
<th>MIME</th>
<th>Time</th>
<th colspan=4 class="text-right"><a class="btn btn-primary" href="#" data-title="Add Ad Group" data-href="item?action=startnew&campaign_id={{index .ARGS.campaign_id 0}}&campaign_md5={{index .ARGS.campaign_md5 0}}&campaign_name={{index .ARGS.campaign_name 0 | urlquery}}" id="startnewPopup">Create Ad Group</a></th>
</tr></thead>
<tbody>{{with .Lists}}{{range .}}
<tr {{if eq .active "New"}}class="warning"{{else if eq .active "Pause"}}class="danger"{{else}}{{end}}>
<td><a href="#" data-title="Update Ad Group: {{.item_name}}" data-href="item?action=edit&campaign_id={{index $.ARGS.campaign_id 0}}&campaign_md5={{index $.ARGS.campaign_md5 0}}&campaign_name={{index $.ARGS.campaign_name 0 | urlquery}}&item_id={{.item_id}}&item_md5={{.item_md5}}&item_name={{.item_name | urlquery}}" id="editPopup">{{.item_name}}</a></td>
    <td>{{if eq .cost_type "CPM"}}{{.cost}} USD CPM{{else}}Disabled (legacy {{.cost_type}} record){{end}}</td>
<td>{{if eq .active "Prepare"}} <a class="btn btn-sm btn-success" onClick="return (confirm('After submission for review, creatives can no longer be changed. Add all creatives before submitting. Submit for review now?')) ? true : false;" href="item?action=review&item_id={{.item_id}}&active=New&campaign_id={{index $.ARGS.campaign_id 0}}&campaign_md5={{index $.ARGS.campaign_md5 0}}&campaign_name={{index $.ARGS.campaign_name 0 | urlquery}}">Submit for Review</a>{{else if eq .active "Yes"}}Approved{{else}}{{.active}}{{end}}</td>
<td>{{.qa_mime}}</td>
<td>{{.startx}}/{{.endx}}</td>
<td><a class="btn btn-sm btn-primary" href="#" data-title="Creative Management: {{.item_name}}" data-href="creative?action=topics&campaign_id={{index $.ARGS.campaign_id 0}}&campaign_md5={{index $.ARGS.campaign_md5 0}}&campaign_name={{index $.ARGS.campaign_name 0 | urlquery}}&item_id={{.item_id}}&item_md5={{.item_md5}}&item_name={{.item_name | urlquery}}&active={{.active}}&qa_mime={{.qa_mime}}&item_click={{.item_click|urlquery}}" id="creativePopup">Creatives</a></td>
<td><a class="btn btn-sm btn-info" href="#" data-title="Budget Plan: {{.item_name}}" data-href="balance?action=topics&campaign_id={{index $.ARGS.campaign_id 0}}&campaign_md5={{index $.ARGS.campaign_md5 0}}&campaign_name={{index $.ARGS.campaign_name 0 | urlquery}}&item_id={{.item_id}}&item_md5={{.item_md5}}&item_name={{.item_name | urlquery}}&entitytype_id=42" id="balancePopup">Budget Plan</a></td>
<td><a class="btn btn-sm btn-success" href="targetname?action=topics&campaign_id={{index $.ARGS.campaign_id 0}}&campaign_md5={{index $.ARGS.campaign_md5 0}}&campaign_name={{index $.ARGS.campaign_name 0 | urlquery}}&item_id={{.item_id}}&item_md5={{.item_md5}}&item_name={{.item_name | urlquery}}&entitytype_id=42">Audience Targeting</a></td>
<td><a class="btn btn-sm btn-danger" onClick="return (confirm('Delete ad group “{{.item_name}}”? This action cannot be undone.')) ? true : false;" href="item?action=delete&campaign_id={{index $.ARGS.campaign_id 0}}&campaign_md5={{index $.ARGS.campaign_md5 0}}&campaign_name={{index $.ARGS.campaign_name 0 | urlquery}}&item_id={{.item_id}}&item_md5={{.item_md5}}&item_name={{.item_name | urlquery}}">Delete</a></td>
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
        <h4 id="d-title" class="modal-title">Ad Group</h4>
        <button type="button" class="close" data-dismiss="modal">&times;</button>
      </div>
      <div id="d-body" class="modal-body"></div>
      <div class="modal-footer">
        <button type="button" class="btn btn-default" data-dismiss="modal">Close</button>
      </div>
    </div>
    <!-- Modal content-->
  </div>
</div>
<!-- /Modal -->

{{template "footer"}}
