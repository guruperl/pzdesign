                <div class="panel panel-primary">
                    <div class="panel-heading">
                        添加创意
                    </div>
                    <div class="panel-body">


<form class="form" method=post action=item>
<input type=hidden name="action" value="insert" />
<input type=hidden name="fl_language" value="Chinese" />
<input type=hidden name=campaign_id value="{{index .ARGS.campaign_id 0}}" />
<input type=hidden name=campaign_md5 value="{{index .ARGS.campaign_md5 0}}" />
<input type=hidden name=campaign_name value="{{index .ARGS.campaign_name 0}}" />


<div class="form-group row">
    <label for="inputCampaigName" class="col-sm-2 col-form-label text-right">创意名称:</label>
    <div class="col-sm-4">
        <input type=text class="form-control" name="item_name" placeholder="名" />
    </div>
    <label for="inputLanding" class="col-sm-2 col-form-label text-right">落地页:</label>
    <div class="col-sm-4">
        <input type=text class="form-control" name="item_click" placeholder="http://www.LANDING.PAGE/" />
    </div>
</div>

<div class="form-group row">
    <label for="inputStartx" class="col-sm-2 col-form-label text-right">起始时间:</label>
    <div class="col-sm-4">
        <input type=text class="form-control" name="startx" placeholder="yyyy-mm-dd" />
    </div>
    <label for="inputEndx" class="col-sm-2 col-form-label text-right">截止时间:</label>
    <div class="col-sm-4">
        <input type=text class="form-control" name="endx" placeholder="yyyy-mm-dd" />
    </div>
</div>

<div class="row">
	<div class="col-sm-6">

<div class="form-group row">
    <label for="inputSizeID" class="col-sm-4 col-form-label text-right">尺寸:</label>
    <div class="col-sm-4">
        <input type=text class="form-control" name="w" placeholder="宽">
	</div>
    <div class="col-sm-4">
        <input type=text class="form-control" name="h" placeholder="高">
	</div>
</div>

<div class="form-group row">
    <label for="inputEndx" class="col-sm-4 col-form-label text-right">媒体类:</label>
    <div class="col-sm-8">{{ range $item := .Other.qa_mime }}
<input class="form-check-input" type=radio name=qa_mime value="{{$item.which}}" {{if $item.default}}checked{{end}} />{{$item.label_chinese}}{{end}}
    </div>
</div>

<div class="form-group row">
    <label for="inputEndx" class="col-sm-4 col-form-label text-right">价格:</label>
    <div class="col-sm-3">
        <input type=text class="form-control" name="cost" placeholder="1.23" />
    </div>
    <div class="col-sm-5">
<input type=radio name=cost_type value=CPD>CPD
<input type=radio name=cost_type value=CPM>CPM
<input type=radio name=cost_type value=CPC>CPC
<input type=radio name=cost_type value=CPA>CPA
	</div>
</div>

	</div>
	<div class="col-sm-6">
<h5>创意预算：</h5>
<div class="table-responsive">
<table class="table-sm table-condensed table-striped">
<thead><tr><th> </th><th>花费</th><th>曝光量</th><th>点击</th></tr></thead>
<tbody>
<tr><td>全部: </td><td><input type=text name=limit_spend size=8 /></td>
<td><input type=text name=limit_imp size=8 /></td>
<td><input type=text name=limit_cli size=8 /></td></tr>
<tr><td>每天: </td><td><input type=text name=daily_spend size=8 /></td>
<td><input type=text name=daily_imp size=8 /></td>
<td><input type=text name=daily_cli size=8 /></td></tr>
</tbody>
</table>
</div>
    </div>
</div>

<div class="form-group row">
    <div class="col-sm-1">
	</div>
    <div class="col-sm-11">
    <h5>对投放媒体的要求</h5>
	</div>
</div>

<div class="panel panel-primary">
    <div class="panel-body">


<div class="form-group row">
    <label for="inputPlatform" class="col-sm-2 col-form-label text-right">媒体平台:</label>
    <div class="col-sm-4">{{ range $item := .Other.fl_platform }}
<input class="form-check-input" id="fl_{{$item.which}}" type=checkbox name=fl_platform value="{{$item.which}}" {{if $item.default}}checked{{end}} />{{$item.label_chinese}}{{end}}
    </div>

    <label for="inputPageLevel" class="col-sm-2 col-form-label text-right">广告位深度:</label>
    <div class="col-sm-4">{{ range $item := .Other.fl_pagelevel }}
<input class="form-check-input" id="fl_{{$item.which}}" type=checkbox name=fl_pagelevel value="{{$item.which}}" {{if $item.default}}checked{{end}} />{{$item.label_chinese}}{{end}}
    </div>
</div>

<div class="form-group row">
    <label for="inputClock" class="col-sm-2 col-form-label text-right">页面方向:</label>
    <div class="col-sm-10">{{ range $item := .Other.fl_clock }}
<input class="form-check-input" id="fl_{{$item.which}}" type=checkbox name=fl_clock value="{{$item.which}}" {{if $item.default}}checked{{end}} />{{$item.label_chinese}}点{{end}}
    </div>
</div>

<div class="form-group row">
    <label for="inputYaxis" class="col-sm-2 col-form-label text-right">上下位置:</label>
    <div class="col-sm-10">{{ range $item := .Other.fl_yaxis }}
<input class="form-check-input" id="fl_{{$item.which}}" type=checkbox name=fl_yaxis value="{{$item.which}}" {{if $item.default}}checked{{end}} />{{$item.label_chinese}}{{end}}
    </div>
</div>

	</div>
</div>

<div class="form-group row">
    <div class="col-sm-1">
	</div>
    <div class="col-sm-11">
<button type="submit" class="btn btn-primary">新建完成</button>
    </div>
</div>

</form>

	</div>
</div>
