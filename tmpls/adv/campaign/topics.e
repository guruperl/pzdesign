{{ template "header" .}}
{{ template "campaignheader" .}}

<div class="row">
                <div class="col-lg-12">
                    <div class="panel panel-primary">
                        <div class="panel-heading">
                            Campaigns
                        </div>
                        <!-- /.panel-heading -->
                        <div class="panel-body">
                            <div class="table-responsive">
<table class="table table-striped table-nordered table-hover">
              <thead>
                <tr>
                  <th>Campaign Name</th>
          <th>Type</th>
          <th>Created</th>
                  <th>Budget</th>
                  <th>Impressions</th>
                  <th>Clicks</th>
                  <th colspan=3 class="text-right"><a class="btn btn-primary" href="#" data-title="Add Campaign" data-href="campaign?action=startnew" id="startnewPopup">Create Campaign</a></th>
                </tr>
              </thead>
              <tbody>{{ with .Lists }}{{ range . }}
<tr>
<td><a href="#" data-title="Update Campaign: {{.campaign_name}}" data-href="campaign?action=edit&campaign_id={{.campaign_id}}&campaign_md5={{.campaign_md5}}&campaign_name={{.campaign_name | urlquery}}" id="editPopup">{{.campaign_name}}</a></td>
<td>{{.target_type}}</td>
<td>{{.created}}</td>
<td>{{.limit_spend}}</td>
<td>{{.limit_imp}}</td>
<td>{{.limit_cli}}</td>
<td><a class="btn btn-sm btn-primary" href="item?action=topics&campaign_id={{.campaign_id}}&campaign_md5={{.campaign_md5}}&campaign_name={{.campaign_name | urlquery}}">Ad Groups</a></td>
<td><a class="btn btn-sm btn-info" href="#" data-title="Campaign Budget: {{.campaign_name}}" data-href="balance?action=topics&campaign_id={{.campaign_id}}&campaign_md5={{.campaign_md5}}&campaign_name={{.campaign_name | urlquery}}&entitytype_id=41" id="balancePopup">Campaign Budget</a></td>
<td><a class="btn btn-sm btn-danger" onClick="return (confirm('Delete campaign “{{.campaign_name}}”? This action cannot be undone.')) ? true : false;" href="campaign?action=delete&campaign_id={{.campaign_id}}">Delete</a></td>
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
        <h4 id="d-title" class="modal-title">Campaign</h4>
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

{{ template "footer" }}
