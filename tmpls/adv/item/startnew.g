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
    <label for="inputSizeID" class="col-sm-2 col-form-label text-right">尺寸:</label>
    <div class="col-sm-2">
        <input type=text class="form-control" name="w" placeholder="宽">
	</div>
    <div class="col-sm-2">
        <input type=text class="form-control" name="h" placeholder="高">
	</div>
    <label for="inputPageCap" class="col-sm-2 col-form-label text-right">单页Ad数:</label>
    <div class="col-sm-4">
        <input type=text class="form-control" name="page_cap" placeholder="最多不超过" />
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
    <label for="inputEndx" class="col-sm-2 col-form-label text-right">MIME类:</label>
    <div class="col-sm-10">本Ad Group的MIME归属类型。PC上显示广告选H5类型</div>
</div>
<div class="form-group row">
    <label class="col-sm-2 col-form-label text-right"> </label>
    <div class="col-sm-10">{{ range $item := .Other.qa_mime }}
<input class="form-check-input" type=radio name=qa_mime value="{{$item.which}}" {{if eq $item.which "4"}}checked{{end}} />{{$item.label_chinese}}{{end}}
    </div>
</div>

<div class="form-group row">
    <label for="inputYaxis" class="col-sm-2 col-form-label text-right">特点:</label>
    <div class="col-sm-10">一般性Ad Group选普通类</div>
</div>
<div class="form-group row">
    <label class="col-sm-2 col-form-label text-right"> </label>
    <div class="col-sm-10">{{ range $item := .Other.qa_creative }}
<input class="form-check-input" id="qa_{{$item.which}}" type=radio name=qa_creative value="{{$item.which}}" {{if eq $item.which "0"}}checked{{end}} />{{$item.label_chinese}}{{end}}
    </div>
</div>

<div class="form-group row">
    <label for="inputClock" class="col-sm-2 col-form-label text-right">展开:</label>
    <div class="col-sm-10">如果广告不展开选正常</div>
</div>
<div class="form-group row">
    <label class="col-sm-2 col-form-label text-right"> </label>
    <div class="col-sm-10">{{ range $item := .Other.qa_expnd }}
<input class="form-check-input" id="fl_{{$item.which}}" type=radio name=qa_expnd value="{{$item.which}}" {{if eq $item.which "0"}}checked{{end}} />{{$item.label_chinese}}{{end}}
    </div>
</div>

<div class="form-group row">
    <label for="inputLanguage" class="col-sm-2 col-form-label text-right">可投放语言平台:</label>
    <div class="col-sm-10">本Ad Group投放平台所用语言？多选</div>
</div>
<div class="form-group row">
    <label class="col-sm-2 col-form-label text-right"> </label>
    <div class="col-sm-10">{{ range $item := .Other.fl_language }}
<input class="form-check-input" id="fl_{{$item.which}}" type=checkbox name=fl_language value="{{$item.which}}" {{if $item.default}}checked{{end}} />{{$item.label_chinese}}{{end}}
    </div>
</div>

<div class="form-group row">
    <label for="inputPlatform" class="col-sm-2 col-form-label text-right">可投放设备平台:</label>
    <div class="col-sm-10">本Ad Group投放到何种硬件设备上？多选</div>
</div>
<div class="form-group row">
    <label class="col-sm-2 col-form-label text-right"> </label>
    <div class="col-sm-10">{{ range $item := .Other.fl_device }}
<input class="form-check-input" id="fl_{{$item.which}}" type=checkbox name=fl_device value="{{$item.which}}" {{if $item.default}}checked{{end}} />{{$item.label_chinese}}{{end}}
    </div>
</div>

<div class="form-group row">
    <label for="inputPageLevel" class="col-sm-2 col-form-label text-right">投放位置:</label>
    <div class="col-sm-10">选择投放在页面哪些位置上？多选</div>
</div>
<div class="form-group row">
    <label class="col-sm-2 col-form-label text-right"> </label>
    <div class="col-sm-10">{{ range $item := .Other.fl_position }}
<input class="form-check-input" id="fl_{{$item.which}}" type=checkbox name=fl_position value="{{$item.which}}" checked />{{$item.label_chinese}}{{end}}
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
	<label for="selectCampaignQuality" class="col-sm-2 col-form-label">质量控制：</label>
	<div class="col-sm-5">
		<div class="panel panel-primary">
            <div class="panel-heading">本广告活动质量</div>
			<div class="panel-body">
<div class="table-responsive">
<table class="table-sm table-condensed table-striped">
	<colgroup>
            <col class="col-md-3">
            <col class="col-md-9">
	</colgroup>
    <tbody>{{range $key, $val := .Other.itemsChinese }}{{$default := index $cDefault $key}}
<tr><td class="text-right">{{index $cAttrs $key}}:</td><td><select size=1 name={{$key}}>{{range $k, $v := $val}}
<option {{if eq $k $default}}selected{{end}} value="{{$k}}">{{$v}}</option>{{end}}</td></tr>{{end}}
	</tbody>
</table>
</div>
			</div>
		</div>
	</div>
	<div class="col-sm-5">
		<div class="panel panel-primary">
            <div class="panel-heading">要求媒体的质量</div>
			<div class="panel-body">
<div class="table-responsive">
<table class="table-sm table-condensed table-striped">
    <colgroup>
            <col class="col-md-3">
            <col class="col-md-9">
    </colgroup>
    <tbody>{{range $key, $val := .Other.slotsChinese }}{{$default := index $sDefault $key}}
<tr><td class="text-right">{{index $sAttrs $key}}:</td><td><select size=1 name={{$key}}>{{range $k, $v := $val}}
<option {{if eq $k $default}}selected{{end}} value="{{$k}}">{{$v}}</option>{{end}}</td></tr>{{end}}
	</tbody>
</table>
</div>
			</div>
		</div>
	</div>
</div>

<div class="form-group row">
    <label for="checkChannels" class="col-sm-2 col-form-label">行业匹配：</label>
    <div class="col-sm-10">
		<div class="panel panel-primary">
			<div class="panel-body">
<div class="table-responsive">
<table class="table-condensed table-sm table-striped">
<thead>
<tr>
<th>行业名</th>
<th>本属行业</th>
<th>要求发布媒体行业：
<input class="form-control-inline" type=radio name=channel_order value="Black" checked />黑名单
<input class="form-control-inline" type=radio name=channel_order value="White" />白名单
</th>
</tr>
</thead>
<tbody>{{ with .Other.channel_topics }}{{ range . }}
<tr><td>{{.channel_name_g}}</td>
<td class="text-center"><input class="form-control-inline" name=belong_ids type=checkbox value="{{.channel_id}}" /></td>
<td class="text-center"><input class="form-control-inline" name=ac_ids type=checkbox value="{{.channel_id}}" /></td>
</tr>{{end}}{{end}}
</tobdy>
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
