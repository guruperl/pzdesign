{{ template "header" .}}
{{ template "itemheader" .}}

            <div class="row">
                <div class="col-lg-12">
                    <div class="panel panel-primary">
                        <div class="panel-heading">
                            新建创意
                        </div>
                        <!-- /.panel-heading -->
                        <div class="panel-body">

<form class="form" method=post action=item>
<input type=hidden name="action" value="insert" />
<input type=hidden name=campaign_id value="{{index .ARGS.campaign_id 0}}" />
<input type=hidden name=campaign_md5 value="{{index .ARGS.campaign_md5 0}}" />
<input type=hidden name=campaign_name value="{{index .ARGS.campaign_name 0}}" />


<div class="form-group row">
    <label for="inputCampaigName" class="col-sm-2 col-form-label text-right">创意名称:</label>
    <div class="col-sm-4">
        <input type=text class="form-control" name="item_name" placeholder="名" />
    </div>
    <label for="inputLanding" class="col-sm-2 col-form-label text-right">点击去往:</label>
    <div class="col-sm-4">
        <input type=text class="form-control" name="item_click" placeholder="http://www.sample.com/landing.html" />
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

<div class="form-group row">
    <label for="inputSizeID" class="col-sm-2 col-form-label text-right">创意尺寸:</label>
    <div class="col-sm-2">
        <input type=text class="form-control" name="w" placeholder="宽">
	</div>
    <div class="col-sm-2">
        <input type=text class="form-control" name="h" placeholder="高">
	</div>
    <label for="inputEndx" class="col-sm-2 col-form-label text-right">媒体类:</label>
    <div class="col-sm-4">{{ range $item := .Other.qa_mime }}
<input class="form-check-input" type=radio name=qa_mime value="{{$item.which}}" {{if $item.default}}checked{{end}} />{{$item.label_chinese}}{{end}}
    </div>
</div>

<div class="form-group row">
    <label for="inputCost" class="col-sm-2 col-form-label text-right">结算方式:</label>
    <div class="col-sm-4">
<input type=radio name=cost_type value=CPD>CPD
<input type=radio name=cost_type value=CPM>CPM
<input type=radio name=cost_type value=CPC>CPC
<input type=radio name=cost_type value=CPA>CPA
	</div>
    <label for="inputEndx" class="col-sm-2 col-form-label text-right">价格:</label>
    <div class="col-sm-4">
        <input type=text class="form-control" name="cost" placeholder="1.23" />
    </div>
</div>

<div class="form-group row">
    <label for="tableBudget" class="col-sm-2 col-form-label text-right">预算:</label>
    <div class="col-sm-6">
<table class="table table-condensed">
<tr><th> </th><th>花费</th><th>曝光量</th><th>点击</th></tr>
<tr><td>全部: </td><td><input type=text name=limit_spend size=8 /></td>
<td><input type=text name=limit_imp size=8 /></td>
<td><input type=text name=limit_cli size=8 /></td></tr>
<tr><td>每天: </td><td><input type=text name=daily_spend size=8 /></td>
<td><input type=text name=daily_imp size=8 /></td>
<td><input type=text name=daily_cli size=8 /></td></tr>
</table>
    </div>
</div>


<div class="form-group row">
	<div class="col-sm-1">
<input type=hidden name="fl_language" value="Chinese" />
	</div>
    <label for="inputCost" class="col-sm-11 col-form-label">本创意需要投放在如下广告位上</label>
</div>

<div class="panel panel-primary">
	<div class="panel-body">

<div class="form-group row">
    <label for="inputPlatform" class="col-sm-2 col-form-label text-right">平台:</label>
    <div class="col-sm-10">{{ range $item := .Other.fl_platform }}
<input class="form-check-input" id="fl_{{$item.which}}" type=checkbox name=fl_platform value="{{$item.which}}" {{if $item.default}}checked{{end}} />{{$item.label_chinese}}{{end}}
    </div>
</div>

<div class="form-group row">
    <label for="inputPageLevel" class="col-sm-2 col-form-label text-right">页面级别:</label>
    <div class="col-sm-10">{{ range $item := .Other.fl_pagelevel }}
<input class="form-check-input" id="fl_{{$item.which}}" type=checkbox name=fl_pagelevel value="{{$item.which}}" {{if $item.default}}checked{{end}} />{{$item.label}}{{end}}
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
                        <!-- /.panel-body -->
                    </div>
                    <!-- /.panel -->
                </div>
                <!-- /.col-lg-6 -->
            </div>
            <!-- /.row -->
{{template "footer"}}
