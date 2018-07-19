{{$attach := print "campaign_id=" (index .ARGS.campaign_id 0) "&campaign_md5=" (index .ARGS.campaign_md5 0) "&campaign_name=" (index .ARGS.campaign_name 0 | urlquery)}}
{{$second := print "item_id=" (index .ARGS.item_id 0) "&item_md5=" (index .ARGS.item_md5 0) "&item_name=" (index .ARGS.item_name 0 | urlquery)}}
{{$mime := index .ARGS.qa_mime 0}}
{{$active := index .ARGS.active 0}}

{{ template "header" .}}
{{ template "creativeheader" .}}

			<div class="row">
                <div class="col-lg-12">
                    <div class="panel panel-primary">
                        <div class="panel-heading">
                          活动： {{index .ARGS.campaign_name 0}}  创意：{{index .ARGS.item_name 0}}  
                        </div>
                        <!-- /.panel-heading -->
                        <div class="panel-body">
                            <div class="table-responsive">
<table class="table table-striped table-nordered table-hover">
<thead><tr>
<th>物料名</th>
<th>投放比重</th>
<th>物料地址</th>
<th></th>
<th></th>
</tr></thead>
<tbody>{{with .Lists}}{{range .}}
<td>{{.creative_name}}</td>
<td>{{.weight}}</td>
<td><textarea class="form-control" rows=4>{{.content}}</textarea></td>
<td><button class="btn btn-sm btn-warning" data-toggle="modal" data-target="#myModal{{.creative_id}}">预览</button>
<!-- Modal -->
                            <div class="modal fade" id="myModal{{.creative_id}}" tabindex="-1" role="dialog" aria-labelledby="myModalLabel" aria-hidden="true">
                                <div class="modal-dialog">
                                    <div class="modal-content">
                                        <div class="modal-body">
{{if eq $mime "html"}}<iframe frameborder=0 src="data:text/html; charset=UTF-8,{{.content}}"></iframe>{{else if eq $mime "js"}}<iframe frameborder=0 src="data:text/html; charset=UTF-8,<script>{{.content}}</script>"></iframe>{{else if eq $mime "video"}}<video controls><source src="{{.content}}"></video>{{else}}<img src="{{.content}}" />{{end}}
                                        </div>
                                    </div>
                                    <!-- /.modal-content -->
                                </div>
                                <!-- /.modal-dialog -->
                            </div>
                            <!-- /.modal -->
</td>
<td>{{if eq $active "Prepare"}}<a class="btn btn-sm btn-danger" href="creative?action=delete&creative_id={{.creative_id}}&{{$attach}}&{{$second}}">删除</a>{{end}}</td>
</tr>{{end}}{{end}}
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



{{if eq (index .ARGS.active 0) "Prepare"}}



			<div class="row">
                <div class="col-lg-12">
                    <div class="panel panel-primary">
                        <div class="panel-heading">
                          新增物料
                        </div>
                        <!-- /.panel-heading -->
                        <div class="panel-body">

<form class="form" method=post action="creative" enctype="multipart/form-data">
<input type=hidden name=action value="insert" />
<input type=hidden name=campaign_id value="{{index .ARGS.campaign_id 0}}" />
<input type=hidden name=campaign_md5 value="{{index .ARGS.campaign_md5 0}}" />
<input type=hidden name=campaign_name value="{{index .ARGS.campaign_name 0}}" />
<input type=hidden name=item_id value="{{index .ARGS.item_id 0}}" />
<input type=hidden name=item_md5 value="{{index .ARGS.item_md5 0}}" />
<input type=hidden name=item_name value="{{index .ARGS.item_name 0}}" />
<input type=hidden name=qa_mime value="{{index .ARGS.qa_mime 0}}" />


<div class="form-group row">
    <label for="inputCreativeName" class="col-sm-3 col-form-label">物料名称：</label>
    <div class="col-sm-5">
        <input type=text class="form-control" name="creative_name" placeholder="" />
    </div>
	<label for="inputWeight" class="col-sm-2 col-form-label">投放比重:</label>
    <div class="col-sm-2">
        <input type=text class="form-control" name="weight" placeholder="0.5" />
    </div>
</div>

{{if or (eq "image" $mime) (eq "video" $mime) }}
<input type=hidden name=content value="MEDIA_1" />

<div class="form-group row">
    <label for="inputMedias" class="col-sm-3 col-form-label">上传 （{{$mime}}）:</label>
    <div class="col-sm-9">
        <div class="panel panel-primary">
            <div class="panel-body">

<label for="inputMedias" class="col-sm-3 col-form-label">物料:</label>
<div class="col-sm-9">
<input type=file class="form-control" name="media_1" />
</div>
	
			</div>
		</div>
	</div>
</div>

{{else}}

<div class="form-group row">
    <label for="inputContent" class="col-sm-3 col-form-label">物料表达 ({{$mime}}):</label>
    <div class="col-sm-9">
		<textarea name=content class="form-control" rows="4">
{{if eq $mime "js"}}document.write("<a href='LANDING'><img src='MEDIA_1'></a>"){{else}}<a href='LANDING'><img src='MEDIA_1'></a>{{end}}
		</textarea>
	</div>
</div>

<div class="form-group row">
    <label for="inputMedias" class="col-sm-3 col-form-label">上传物料 (可上传多个):</label>
    <div class="col-sm-9">
        <div class="panel panel-primary">
            <div class="panel-body">

<label for="inputMedias" class="col-sm-3 col-form-label">物料1:</label>
<div class="col-sm-9">
<input type=file class="form-control" name="media_1" />
</div>
	
{{if or (or (eq (index .ARGS.qa_mime 0) "js") (eq (index .ARGS.qa_mime 0) "html")) (eq (index .ARGS.qa_mime 0) "json")}}

<label for="inputMedias" class="col-sm-3 col-form-label">物料2:</label>
<div class="col-sm-9">
<input type=file class="form-control" name="media_2" />
</div>
	
<label for="inputMedias" class="col-sm-3 col-form-label">物料3:</label>
<div class="col-sm-9">
<input type=file class="form-control" name="media_3" />
</div>
	
<label for="inputMedias" class="col-sm-3 col-form-label">物料4:</label>
<div class="col-sm-9">
<input type=file class="form-control" name="media_4" />
</div>
	
<label for="inputMedias" class="col-sm-3 col-form-label">物料5:</label>
<div class="col-sm-9">
<input type=file class="form-control" name="media_5" />
</div>
{{end}}	
			</div>
		</div>
	</div>
</div>
{{end}}

<div class="form-group row">
    <div class="col-sm-3">
	</div>
    <div class="col-sm-9">
<button type="submit" class="btn btn-primary"> 提交 </button>
    </div>
</div>

</form>
                        </div>
                        <!-- /.panel-body -->
                    </div>
                    <!-- /.panel -->
                </div>
                <!-- /.col-lg-6 -->
			</div>



{{end}}



{{template "footer"}}
