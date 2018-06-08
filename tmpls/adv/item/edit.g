{{ template "header" .}}
{{ template "itemheader" .}}

{{$item := index .Lists 0}}

            <div class="row">
                <div class="col-lg-12">
                    <div class="panel panel-primary">
                        <div class="panel-heading">
                            编辑修改创意
                        </div>
                        <!-- /.panel-heading -->
                        <div class="panel-body">

<form class="form" method=post action=item>
<input type=hidden name="action" value="update" />
<input type=hidden name="item_id" value="{{$item.item_id}}" />
<input type=hidden name="campaign_id" value="{{$item.campaign_id}}" />
<input type=hidden name=campaign_id value="{{index .ARGS.campaign_id 0}}" />
<input type=hidden name=campaign_md5 value="{{index .ARGS.campaign_md5 0}}" />
<input type=hidden name=campaign_name value="{{index .ARGS.campaign_name 0}}" />


<div class="form-group row">
    <label for="inputCampaigName" class="col-sm-2 col-form-label text-right">创意名称:</label>
    <div class="col-sm-4">
        <input type=text class="form-control" name="item_name" value="{{$item.item_name}}" placeholder="Name of Item" />
    </div>
    <label for="inputLanding" class="col-sm-2 col-form-label text-right">点击去往:</label>
    <div class="col-sm-4">
        <input type=text class="form-control" name="item_click" value="{{$item.item_click}}" placeholder="http://www.sample.com/landing.html" />
    </div>
</div>

<div class="form-group row">
    <label for="inputStartx" class="col-sm-2 col-form-label text-right">起始时间:</label>
    <div class="col-sm-4">
        <input type=text class="form-control" name="startx" value="{{$item.startx}}" placeholder="yyyy-mm-dd" />
    </div>
    <label for="inputEndx" class="col-sm-2 col-form-label text-right">截止时间:</label>
    <div class="col-sm-4">
        <input type=text class="form-control" name="endx" value="{{$item.endx}}" placeholder="yyyy-mm-dd" />
    </div>
</div>

<div class="form-group row">
    <label for="inputSizeID" class="col-sm-2 col-form-label text-right">创意尺寸:</label>
    <div class="col-sm-2">
        <input type=text class="form-control" name="w" value="{{$item.w}}">
    </div>
    <div class="col-sm-2">
        <input type=text class="form-control" name="h" value="{{$item.h}}">
    </div>
    <label for="inputEndx" class="col-sm-2 col-form-label text-right">类别:</label>
    <div class="col-sm-4">
        <select class="form-control" name="qa_mime">
<option {{if eq $item.qa_mime "js"}}selected{{end}} value="js">Javascript</option>
<option {{if eq $item.qa_mime "html"}}selected{{end}} value="html">页面</option>
<option {{if eq $item.qa_mime "image"}}selected{{end}} value="image">图片</option>
<option {{if eq $item.qa_mime "video"}}selected{{end}} value="video">视频</option></select>
    </div>
</div>

<div class="form-group row">
    <label for="inputCost" class="col-sm-2 col-form-label text-right">结算方式:</label>
    <div class="col-sm-4">
<input type=radio name=cost_type {{if eq $item.cost_type "CPD"}}checked{{end}} value=CPD>CPD
<input type=radio name=cost_type {{if eq $item.cost_type "CPM"}}checked{{end}} value=CPM>CPM
<input type=radio name=cost_type {{if eq $item.cost_type "CPC"}}checked{{end}} value=CPC>CPC
<input type=radio name=cost_type {{if eq $item.cost_type "CPA"}}checked{{end}} value=CPA>CPA
	</div>
    <label for="inputEndx" class="col-sm-2 col-form-label text-right">价格:</label>
    <div class="col-sm-4">
        <input type=text class="form-control" name="cost" value="{{$item.cost}}" placeholder="1.23" />
    </div>
</div>

<div class="form-group row">
	<div class="col-sm-1"> </div>
    <label for="inputCost" class="col-sm-11 col-form-label">本创意需要投放在如下
广告位上</label>
</div>

<div class="panel panel-primary">
	<div class="panel-body">

<div class="form-group row">
    <label for="inputPlatform" class="col-sm-2 col-form-label text-right">平台:</label>
    <div class="col-sm-10">{{ range $item := .Other.fl_platform }}
<input class="form-check-input" id="fl_{{$item.which}}" type=checkbox name=fl_platform value="{{$item.which}}" {{if $item.selected}}checked{{end}} />{{$item.label}}{{end}}
    </div>
</div>

<div class="form-group row">
    <label for="inputPageLevel" class="col-sm-2 col-form-label text-right">页面级别:</label>
    <div class="col-sm-10">{{ range $item := .Other.fl_pagelevel }}
<input class="form-check-input" id="fl_{{$item.which}}" type=checkbox name=fl_pagelevel value="{{$item.which}}" {{if $item.selected}}checked{{end}} />{{$item.label}}{{end}}
    </div>
</div>

<div class="form-group row">
    <label for="inputClock" class="col-sm-2 col-form-label text-right">页面方向:</label>
    <div class="col-sm-10">{{ range $item := .Other.fl_clock }}
<input class="form-check-input" id="fl_{{$item.which}}" type=checkbox name=fl_clock value="{{$item.which}}" {{if $item.selected}}checked{{end}} />{{$item.label}}{{end}}
    </div>
</div>

<div class="form-group row">
    <label for="inputYaxis" class="col-sm-2 col-form-label text-right">上下位置:</label>
    <div class="col-sm-10">{{ range $item := .Other.fl_yaxis }}
<input class="form-check-input" id="fl_{{$item.which}}" type=checkbox name=fl_yaxis value="{{$item.which}}" {{if $item.selected}}checked{{end}} />{{$item.label}}{{end}}
    </div>
</div>

	</div>
</div>

<div class="form-group row">
    <div class="col-sm-1">
	</div>
    <div class="col-sm-11">
<button type="submit" class="btn btn-primary">保存并更新</button>
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
            <!-- /.row -->
{{template "footer"}}
