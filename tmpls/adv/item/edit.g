{{$attach := print "campaign_id=" (index .ARGS.campaign_id 0) "&campaign_md5=" (index .ARGS.campaign_md5 0) "&campaign_name=" (index .ARGS.campaign_name 0 | urlquery)}}
{{$item := index .Lists 0}}
{{$small := print "item_id=" ($item.item_id) "&item_md5=" ($item.item_md5) "&item_name=" ($item.item_name | urlquery)}}

{{$cAttrs := .Other.itemAttrsChinese}}
{{$sAttrs := .Other.slotAttrsChinese}}

                <div class="panel panel-primary">
                    <div class="panel-heading">
                        修改 {{$item.item_name}}
                    </div>
                    <div class="panel-body">

<form class="form" method=post action=item>
<input type=hidden name="action" value="update" />
<input type=hidden name="item_id" value="{{$item.item_id}}" />
<input type=hidden name="campaign_id" value="{{$item.campaign_id}}" />
<input type=hidden name=campaign_id value="{{index .ARGS.campaign_id 0}}" />
<input type=hidden name=campaign_md5 value="{{index .ARGS.campaign_md5 0}}" />
<input type=hidden name=campaign_name value="{{index .ARGS.campaign_name 0}}" />


<div class="form-group row">
    <label for="inputCampaigName" class="col-sm-2 col-form-label text-right">名称:</label>
    <div class="col-sm-4">
        <input type=text class="form-control" name="item_name" value="{{$item.item_name}}">
    </div>
    <label for="inputLanding" class="col-sm-2 col-form-label text-right">落地页:</label>
    <div class="col-sm-4">
        <input type=text class="form-control" name="item_click" value="{{$item.item_click}}">
    </div>
</div>

<div class="form-group row">
    <label for="inputStartx" class="col-sm-2 col-form-label text-right">起始时间:</label>
    <div class="col-sm-4">
        <input type=text class="form-control" name="startx" value="{{if $item.startx}}{{$item.startx}}{{end}}">
    </div>
    <label for="inputEndx" class="col-sm-2 col-form-label text-right">截止时间:</label>
    <div class="col-sm-4">
        <input type=text class="form-control" name="endx" value="{{ if $item.endx }}{{$item.endx}}{{end}}">
    </div>
</div>

<div class="form-group row">
    <label for="inputSizeID" class="col-sm-2 col-form-label text-right">尺寸:</label>
    <div class="col-sm-2">
        <input type=text class="form-control" name="w" value="{{$item.w}}" />
	</div>
    <div class="col-sm-2">
        <input type=text class="form-control" name="h" value="{{$item.h}}" />
	</div>
    <label for="inputPageCap" class="col-sm-2 col-form-label text-right">单页Ad数:</label>
    <div class="col-sm-4">
        <input type=text class="form-control" name="page_cap" value="{{$item.page_cap}}" />
    </div>
</div>

<div class="form-group row">
    <label for="inputEndx" class="col-sm-2 col-form-label text-right">价格:</label>
    <div class="col-sm-4">
        <input type=text class="form-control" name="cost" value="{{$item.cost}}" />
    </div>
    <label for="costType" class="col-sm-2 col-form-label text-right">计费方式:</label>
    <div class="col-sm-4">
<input type=radio name=cost_type {{if eq $item.cost_type "ROI"}}checked{{end}} value=ROI>ROI
<input type=radio name=cost_type {{if eq $item.cost_type "CPM"}}checked{{end}} value=CPM>CPM
<input type=radio name=cost_type {{if eq $item.cost_type "CPC"}}checked{{end}} value=CPC>CPC
<input type=radio name=cost_type {{if eq $item.cost_type "CPA"}}checked{{end}} value=CPA>CPA
	</div>
</div>



<div class="form-group row">
    <label for="inputEndx" class="col-sm-2 col-form-label text-right">MIME类:</label>
    <div class="col-sm-10">本Ad Group的MIME归属类型。PC上显示广告选H5类型</div>
</div>
<div class="form-group row">
    <label class="col-sm-2 col-form-label text-right"> </label>
    <div class="col-sm-10">{{ range $one := .Other.qa_mime }}
<input class="form-check-input" type=radio name=qa_mime value="{{$one.which}}" {{if $one.selected}}checked{{end}} />{{$one.label_chinese}}{{end}}
    </div>
</div>

<div class="form-group row">
    <label for="inputYaxis" class="col-sm-2 col-form-label text-right">特点:</label>
    <div class="col-sm-10">一般性Ad Group选普通类</div>
</div>
<div class="form-group row">
    <label class="col-sm-2 col-form-label text-right"> </label>
    <div class="col-sm-10">{{ range $one := .Other.qa_creative }}
<input class="form-check-input" type=radio name=qa_creative value="{{$one.which}}" {{if $one.selected}}checked{{end}} />{{$one.label_chinese}}{{end}}
    </div>
</div>

<div class="form-group row">
    <label for="inputClock" class="col-sm-2 col-form-label text-right">展开:</label>
    <div class="col-sm-10">如果广告不展开选正常</div>
</div>
<div class="form-group row">
    <label class="col-sm-2 col-form-label text-right"> </label>
    <div class="col-sm-10">{{ range $one := .Other.qa_expnd }}
<input class="form-check-input" type=radio name=qa_expnd value="{{$one.which}}" {{if $one.selected}}checked{{end}} />{{$one.label_chinese}}{{end}}
    </div>
</div>

<div class="form-group row">
    <label for="inputLanguage" class="col-sm-2 col-form-label text-right">可投放语言平台:</label>
    <div class="col-sm-10">本Ad Group投放平台所用语言？多选</div>
</div>
<div class="form-group row">
    <label class="col-sm-2 col-form-label text-right"> </label>
    <div class="col-sm-10">{{ range $one := .Other.fl_language }}
<input class="form-check-input" type=checkbox name=fl_language value="{{$one.which}}" {{if $one.selected}}checked{{end}} />{{$one.label_chinese}}{{end}}
    </div>
</div>

<div class="form-group row">
    <label for="inputPlatform" class="col-sm-2 col-form-label text-right">可投放设备平台:</label>
    <div class="col-sm-10">本Ad Group投放到何种硬件设备上？多选</div>
</div>
<div class="form-group row">
    <label class="col-sm-2 col-form-label text-right"> </label>
    <div class="col-sm-10">{{ range $one := .Other.fl_device }}
<input class="form-check-input" type=checkbox name=fl_device value="{{$one.which}}" {{if $one.selected}}checked{{end}} />{{$one.label_chinese}}{{end}}
    </div>
</div>

<div class="form-group row">
    <label for="inputPageLevel" class="col-sm-2 col-form-label text-right">投放位置:</label>
    <div class="col-sm-10">选择投放在页面哪些位置上？多选</div>
</div>
<div class="form-group row">
    <label class="col-sm-2 col-form-label text-right"> </label>
    <div class="col-sm-10">{{ range $one := .Other.fl_position }}
<input class="form-check-input" type=checkbox name=fl_position value="{{$one.which}}" {{if $one.selected}}checked{{end}} />{{$one.label_chinese}}{{end}}
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
<td><input type=text name=cpm_fc value="{{$item.cpm_fc}}" size=3 ></td>
<td><input type=text name=cpm_length value="{{$item.cpm_length}}" size=6>分钟</td>
<td><input type=text name=cpm_throttle value="{{$item.cpm_throttle}}" size=6>分钟</td></tr>
<tr><td>点击: </td>
<td><input type=text name=cpc_fc value="{{$item.cpc_fc}}" size=3></td>
<td><input type=text name=cpc_length value="{{$item.cpc_fc}}" size=6>分钟</td>
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
<tr><th> </th><th>花费金额</th><th>曝光次数</th><th>点击次数</th></tr>{{range $one := $item.balance_topics}}
<tr><td>{{if eq $one.which "total_balance_id"}}全部{{else}}每天{{end}}: </td>
<td>{{$one.limit_spend}}</td>
<td>{{$one.limit_imp}}</td>
<td>{{$one.limit_cli}}</td>
</tr>{{end}}
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
    <tbody>{{range $key, $val := .Other.itemsChinese }}{{$obs := index $item $key}}
<tr><td class="text-right">{{index $cAttrs $key}}:</th><td><select size=1 name={{$key}}>{{range $k, $v := $val}}
<option {{if eq $k $obs}}selected{{end}} value="{{$k}}">{{$v}}</option>{{end}}</td></tr>{{end}}
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
    <tbody>{{range $key, $val := .Other.slotsChinese }}{{$obs := index $item $key}}
<tr><td class="text-right">{{index $sAttrs $key}}:</td><td><select size=1 name={{$key}}>{{range $k, $v := $val}}
<option {{if eq $k $obs}}selected{{end}} value="{{$k}}">{{$v}}</option>{{end}}</td></tr>{{end}}
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
<table class="table-sm table-condensed table-striped">
<thead>
<tr>
<th>行业名</th>
<th>本属行业</th>
<th>要求投放媒体行业：
<input class="form-control-inline" type=radio name=channel_order value="Black" {{if eq "Black" $item.channel_order}}checked{{end}} />黑名单
<input type=radio name=channel_order value="White" {{if eq "White" $item.channel_order}}checked{{end}} />白名单</th>
</tr>
</thead>
<tbody>{{ with $item.chac_topics }}{{ range . }}
<tr><td>{{.channel_name_g}}</td>
<td class="text-center"><input class="form-control-inline" name=belong_ids {{if .chbelong_id}}checked{{end}} type=checkbox value="{{.channel_id}}" /></td>
<td class="text-center"><input class="form-control-inline" name=ac_ids {{if .chac_id}}checked{{end}} type=checkbox value="{{.channel_id}}" /></td>
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
<button type="submit" class="btn btn-primary">保存并更新</button>
    </div>
</div>

</form>

	</div>
</div>
