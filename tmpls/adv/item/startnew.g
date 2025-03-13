{{$cAttrs := .Other.itemAttrsChinese }}
{{$sAttrs := .Other.slotAttrsChinese }}
{{$cDefault := .Other.itemsDefault }}
{{$sDefault := .Other.slotsDefault }}

                <div class="panel panel-primary">
                    <div class="panel-heading">
                        添加Ad Group
                    </div>
                    <div class="panel-body">


<form class="form" method=post action=item>
<input type=hidden name="action" value="insert" />
<input type=hidden name=campaign_id value="{{index .ARGS.campaign_id 0}}" />
<input type=hidden name=campaign_md5 value="{{index .ARGS.campaign_md5 0}}" />
<input type=hidden name=campaign_name value="{{index .ARGS.campaign_name 0}}" />


<div class="form-group row">
    <label for="inputCampaigName" class="col-sm-2 col-form-label text-right">名称:</label>
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
        <input type=text class="form-control" name="startx" value="">
    </div>
    <label for="inputEndx" class="col-sm-2 col-form-label text-right">截止时间:</label>
    <div class="col-sm-4">
        <input type=text class="form-control" name="endx" value="">
    </div>
</div>

<div class="form-group row">
    <label for="inputEndx" class="col-sm-2 col-form-label text-right">价格:</label>
    <div class="col-sm-4">
        <input type=text class="form-control" name="cost" placeholder="1.23" />
    </div>
    <label for="costType" class="col-sm-2 col-form-label text-right">计费方式:</label>
    <div class="col-sm-4">
<input type=radio name=cost_type value=ROI>ROI
<input type=radio name=cost_type value=CPM>CPM
<input type=radio name=cost_type value=CPC>CPC
<input type=radio name=cost_type value=CPA>CPA
	</div>
</div>



<div class="form-group row">
    <label for="inputEndx" class="col-sm-2 col-form-label text-right">如何显示:</label>
    <div class="col-sm-10">手机可选XHTML Banner，其它选Iframe</div>
</div>
<div class="form-group row">
    <label class="col-sm-2 col-form-label text-right"> </label>
    <div class="col-sm-10">{{ range $item := .Other.qa_mime }}
<input class="form-check-input" type=radio name=qa_mime value="{{$item.which}}" {{if eq $item.which "4"}}checked{{end}} />{{$item.label_chinese}}{{end}}
    </div>
</div>

<div class="form-group row">
	<label for="tableFrequencyCap" class="col-sm-2 col-form-label">参数设置：</label>
	<div class="col-sm-5">
        <div class="panel panel-primary">
            <div class="panel-heading">个人频次控制</div>
            <div class="panel-body">
<div class="table-responsive">
<table class="table-sm table-bordered table-condensed">
<tr><th>类型</th><th>次数</th><th>周期</th><th>间隔</th></tr>
<tr><td>曝光: </td>
<td><input type=text name=cpm_fc size=3></td>
<td><input type=text name=cpm_length size=6>分钟</td>
<td><input type=text name=cpm_throttle size=6>分钟</td></tr>
<tr><td>点击: </td>
<td><input type=text name=cpc_fc size=3></td>
<td><input type=text name=cpc_length size=6>分钟</td>
<td></td></tr>
</table>
</div>
		    </div>
		</div>
    </div>
	<div class="col-sm-5">
        <div class="panel panel-primary">
            <div class="panel-heading">活动总预算</div>
            <div class="panel-body">
<div class="table-responsive">
<table class="table-sm table-bordered table-condensed">
<tr><th> </th><th>花费金额</th><th>曝光次数</th><th>点击次数</th></tr>
<tr><td>全部: </td><td><input type=text name=limit_spend size=8 /></td>
<td><input type=text name=limit_imp size=8 /></td>
<td><input type=text name=limit_cli size=8 /></td></tr>
<tr><td>每天: </td><td><input type=text name=daily_spend size=8 /></td>
<td><input type=text name=daily_imp size=8 /></td>
<td><input type=text name=daily_cli size=8 /></td></tr>
</table>
</div>
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
