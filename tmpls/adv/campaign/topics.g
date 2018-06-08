{{ template "header" .}}
{{ template "campaignheader" .}}

<div class="row">
                <div class="col-lg-12">
                    <div class="panel panel-primary">
                        <div class="panel-heading">
                            推广活动
                        </div>
                        <!-- /.panel-heading -->
                        <div class="panel-body">
                            <div class="table-responsive">
<table class="table table-striped table-nordered table-hover">
              <thead>
                <tr>
                  <th>活动名称</th>
				  <th>创建日期</th>
                  <th>预算</th>
                  <th>总曝光</th>
                  <th>总点击</th>
                  <td colspan=3 class="text-right"><a class="btn btn-info" href="campaign?action=startnew">创建活动</a>
</td>
                </tr>
              </thead>
              <tbody>{{ with .Lists }}{{ range . }}
<tr>
{{$small := print "campaign_id=" .campaign_id "&campaign_md5=" .campaign_md5 "&campaign_name=" (.campaign_name | urlquery )}}
<td><a href="campaign?action=edit&{{$small}}">{{.campaign_name}}</a></td>
<td>{{.created}}</td>
<td>{{.limit_spend}}</td>
<td>{{.limit_imp}}</td>
<td>{{.limit_cli}}</td>
<td><a class="btn btn-sm btn-primary" href="item?action=topics&{{$small}}">所属创意</a></td>
<td><a class="btn btn-sm btn-success" href="targetname?action=topics&{{$small}}">标签定向</a></td>
<td><a class="btn btn-sm btn-danger" onClick="return (confirm('您确定要删除活动（{{.campaign_name}}）吗？')) ? true : false;" href="campaign?action=delete&campaign_id={{.campaign_id}}">删除</a></td>
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
{{ template "footer" }}
