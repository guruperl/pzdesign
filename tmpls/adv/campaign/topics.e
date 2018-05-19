{{ template "header" .}}
{{ template "campaignheader" .}}

<div class="row">
                <div class="col-lg-12">
                    <div class="panel panel-primary">
                        <div class="panel-heading">
                            Active Campaigns
                        </div>
                        <!-- /.panel-heading -->
                        <div class="panel-body">
                            <div class="table-responsive">
<table class="table table-striped table-nordered table-hover">
              <thead>
                <tr>
                  <th>Name</th>
                  <th>Since</th>
		          <th>Budget</th>	
		          <th>Impres</th>	
		          <th>Clicks</th>	
                  <td colspan=3 class="text-right"><a class="btn btn-info" href="campaign?action=startnew">New Campaign</a>
</td>
                </tr>
              </thead>
              <tbody>{{ with .Lists }}{{ range . }}
<tr {{if eq .active "New"}}class="warning"{{else if eq .active "Pause"}}class="danger"{{else}}{{end}}>
{{$small := print "campaign_id=" .campaign_id "&campaign_md5=" .campaign_md5 "&campaign_name=" (.campaign_name | urlquery)}}
<td><a href="campaign?action=edit&campaign_id={{.campaign_id}}">{{.campaign_name}}</a></td>
<td>{{.created}}</td>
<td>{{.limit_spend}}</td>
<td>{{.limit_imp}}</td>
<td>{{.limit_cli}}</td>
<td><a class="btn btn-sm btn-primary" href="item?action=topics&{{$small}}">Items</a></td>
<td><a class="btn btn-sm btn-success" href="targetname?action=topics&{{$small}}">Audience</a></td>
<td><a class="btn btn-sm btn-danger" onClick="return (confirm('Do you want to remove your site {{.campaign_name}}?')) ? true : false;" href="campaign?action=delete&campaign_id={{.campaign_id}}">Del</a></td>
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

{{ template "footer" }}
