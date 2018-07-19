{{$attach := print "campaign_id=" (index .ARGS.campaign_id 0) "&campaign_md5=" (index .ARGS.campaign_md5 0) "&campaign_name=" (index .ARGS.campaign_name 0 | urlquery)}}

{{ template "header" .}}
{{ template "itemheader" .}}

<div class="row">
                <div class="col-lg-12">
                    <div class="panel panel-primary">
                        <div class="panel-heading">
                            Items of {{index .ARGS.campaign_name 0}}
                        </div>
                        <!-- /.panel-heading -->
                        <div class="panel-body">
                            <div class="table-responsive">
								<table class="table table-striped table-nordered table-hover">
<thead><tr>
<th>Name</th>
<th>Price</th>
<th>Status</th>
<th>Mime</th>
<th>From/To</th>
<th colspan=3 class="text-right"><a class="btn btn-info" href="item?action=startnew&{{$attach}}">New Item</a></th>
</tr></thead>
<tbody>{{with .Lists}}{{range .}}
{{$second := print "item_id=" .item_id "&item_md5=" .item_md5 "&item_name=" (.item_name | urlquery)}}
<tr {{if eq .active "New"}}class="warning"{{else if eq .active "Pause"}}class="danger"{{else}}{{end}}>
<td><a href="item?action=edit&{{$attach}}&{{$second}}">{{.item_name}}</a></td>
<td>{{.cost}} {{.cost_type}}</td>
<td>{{.active}}{{if eq .active "Prepare"}} <a class="btn btn-sm btn-primary" href="item?action=review&item_id={{.item_id}}&active=New&{{$attach}}">Review</a>{{end}}</td>
<td>{{.qa_mime}}</td>
<td>{{.startx}}/{{.endx}}</td>
<td><a class="btn btn-sm btn-primary" href="creative?action=topics&{{$attach}}&{{$second}}&active={{.active}}&qa_mime={{.qa_mime}}&size_id={{.size_id}}&item_click={{.item_click|urlquery}}">Creatives</a></td>
<td><a class="btn btn-sm btn-success" href="balance?action=topics&{{$attach}}&{{$second}}&entitytype_id=42">Budget</a></td>
<td><a class="btn btn-sm btn-danger" onClick="return (confirm('Do you want to remove your site {{.campaign_name}}?')) ? true : false;" href="item?action=delete&{{$attach}}&{{$second}}">Del</a></td>
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

{{template "footer"}}
