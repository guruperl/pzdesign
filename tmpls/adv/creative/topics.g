{{$attach := print "campaign_id=" (index .ARGS.campaign_id 0) "&campaign_md5=" (index .ARGS.campaign_md5 0) "&campaign_name=" (index .ARGS.campaign_name 0 | urlquery)}}
{{$second := print "item_id=" (index .ARGS.item_id 0) "&item_md5=" (index .ARGS.item_md5 0) "&item_name=" (index .ARGS.item_name 0 | urlquery)}}
{{$mime := index .ARGS.qa_mime 0}}
{{$active := index .ARGS.active 0}}


			<div class="row">
                <div class="col-lg-12">
                    <div class="panel panel-primary">
                        <div class="panel-heading">
                          活动： {{index .ARGS.campaign_name 0}}  &nbsp; / &nbsp; Ad Group：{{index .ARGS.item_name 0}}  
                        </div>
                        <!-- /.panel-heading -->
                        <div class="panel-body">
                            <div class="table-responsive">
<table class="table table-striped table-nordered table-hover">
<thead><tr>
<th>素材名</th>
<th>尺寸</th>
<th>投放比重</th>
<th>素材地址</th>
<th></th>
<th></th>
</tr></thead>
<tbody>{{with .Lists}}{{range .}}
<td>{{.creative_name}}</td>
<td>{{.w}} x {{.h}}</td>
<td>{{.weight}}</td>
<td>{{.content}}</td>
<td><button class="btn btn-sm btn-warning" data-toggle="modal" data-target="#myModal{{.creative_id}}">预览</button>
<!-- Modal -->
	<div class="modal fade" id="myModal{{.creative_id}}" tabindex="-1" role="dialog" aria-labelledby="myModalLabel" aria-hidden="true">
		<div class="modal-dialog">
			<div class="modal-content">
				<div class="modal-body">
<iframe frameborder=0 src="{{.content}}"></iframe>
				</div>
			</div>
			<!-- /.modal-content -->
		</div>
		<!-- /.modal-dialog -->
	</div>
	<!-- /.modal -->
</td>
<td>{{if eq $active "Prepare"}}<a class="btn btn-sm btn-danger" onClick="return (confirm('确认要删除此素材吗？此操作不可更改。')) ? true : false;" href="creative?action=delete&creative_id={{.creative_id}}&{{$attach}}&{{$second}}">删除</a>{{end}}</td>
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
                          新增素材
                        </div>
                        <!-- /.panel-heading -->
                        <div class="panel-body">

<form name=newcreative class="form" method=post action="creative" enctype="multipart/form-data">
<input type=hidden name=action value="insert" />
<input type=hidden name=campaign_id value="{{index .ARGS.campaign_id 0}}" />
<input type=hidden name=campaign_md5 value="{{index .ARGS.campaign_md5 0}}" />
<input type=hidden name=campaign_name value="{{index .ARGS.campaign_name 0}}" />
<input type=hidden name=item_id value="{{index .ARGS.item_id 0}}" />
<input type=hidden name=item_md5 value="{{index .ARGS.item_md5 0}}" />
<input type=hidden name=item_name value="{{index .ARGS.item_name 0}}" />
<input type=hidden name=qa_mime value="{{index .ARGS.qa_mime 0}}" />


<div class="form-group row">
    <label for="inputCreativeName" class="col-sm-1 col-form-label">名称：</label>
    <div class="col-sm-2">
        <input id="inputCreativeName" type=text class="form-control" name="creative_name" placeholder="" />
    </div>
    <label for="inputCreativeName" class="col-sm-1 col-form-label">尺寸：</label>
    <div class="col-sm-2">
        <input id="inputW" type=text class="form-control" name="w" placeholder="" />
    </div>
    <label for="inputCreativeName" class="col-sm-1 col-form-label">x</label>
    <div class="col-sm-2">
        <input id="inputW" type=text class="form-control" name="h" placeholder="" /> 
    </div>
	<label for="inputWeight" class="col-sm-1 col-form-label">比重:</label>
    <div class="col-sm-2">
        <input id="inputWeight" type=text class="form-control" name="weight" placeholder="0.5" />
    </div>
</div>

<div class="form-group row">
    <label for="inputRandomChoices" class="col-sm-3 col-form-label">选择下面其中一种:</label>
    <div class="col-sm-1">
        <input id="inputRandom1" type=radio class="form-control" name="randomChoice" value=1 />
    </div>
    <label for="inputRandom1" class="col-sm-2 col-form-label">素材表达</label>
    <div class="col-sm-1">
        <input id="inputRandom1" type=radio class="form-control" name="randomChoice" value=2 />
    </div>
    <label for="inputRandom1" class="col-sm-2 col-form-label">上传图片</label> 
    <div class="col-sm-1">
        <input id="inputRandom1" type=radio class="form-control" name="randomChoice" value=3 />
    </div>
    <label for="inputRandom1" class="col-sm-2 col-form-label">原生广告</label>
</div>

<div class="form-group row">
    <label for="inputContent" class="col-sm-2 col-form-label">素材表达:</label>
    <div class="col-sm-8">
		<textarea id="inputContent" name=content class="form-control" rows="2">
http://www.creative.site/sample.png
		</textarea>
	</div>
	<div class="col-sm-2">
	</div>
</div>
<div class="form-group row">
    <label for="inputContent" class="col-sm-2 col-form-label">或上传图片:</label>
	<div class="col-sm-8">
		<input type=file class="form-control" name="media_1" />
	</div>
	<div class="col-sm-2">
	</div>
</div>
<div class="form-group row">
    <label for="inputContent" class="col-sm-2 col-form-label">或原生广告:</label>
	<div class="col-sm-8">
		<table class="table table-nordered table-hover">
<tr>
<th>标题（50字）</th><td><input type=text class="form-control" name="title" placeholder="" /> </td>
</tr>
<tr>
<th>描述（255字）</th><td><input type=text class="form-control" name="description" placeholder="" /> </td>
</tr>
<tr>
<th>配文CTA（50字）</th><td><input type=text class="form-control" name="cta" placeholder="" /> </td>
</tr>
<tr>
<th>ICON地址</th><td><input type=text class="form-control" name="iconImg" placeholder="" /> </td>
</tr>
<tr>
<th>MAIN IMAGE地址</th><td><input type=text class="form-control" name="mainImg" placeholder="" /> </td>
</tr>
        </table>
	</div>
	<div class="col-sm-2">
	</div>
</div>

<div class="form-group row">
    <div class="col-sm-2">
	</div>
    <div class="col-sm-10">
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

