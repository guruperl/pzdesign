{{$cAttrs := .Other.campaignAttrsChinese }}
{{$sAttrs := .Other.siteAttrsChinese }}

{{$item := index .Lists 0}}

                <div class="panel panel-primary">
                    <div class="panel-heading">
                        修改广告活动
                    </div>
                    <div class="panel-body">

<form method=post action=campaign>
<input type=hidden name="action" value="update" />
<input type=hidden name="campaign_id" value="{{$item.campaign_id}}" />

<div class="form-group row">
	<label for="inputCampaigName" class="col-sm-2 col-form-label">活动名称:</label>
	<div class="col-sm-4">
		<input type=text class="form-control" name="campaign_name" value="{{$item.campaign_name}}">
	</div>
	<label for="inputPageCap" class="col-sm-2 col-form-label">单页创意数:</label>
	<div class="col-sm-4">
		<input type=text class="form-control-sm" name="page_cap" value="{{$item.page_cap}}">
	</div>
</div>

<div class="form-group row">
	<label for="tableFrequencyCap" class="col-sm-2 col-form-label">参数设置：</label>
	<div class="col-sm-5">
        <div class="panel panel-primary">
<div class="panel-heading">频次控制</div>
            <div class="panel-body">
<div class="table-responsive">
<table class="table-sm table-bordered table-condensed">
<tr><th>类型</th><th>次数</th><th>周期</th><th>间隔</th></tr>
<tr><td>曝光: </td>
<td><input type=text name=cpm_fc value="{{if $item.cpm_fc}}{{$item.cpm_fc}}{{end}}" size=3></td>
<td><input type=text name=cpm_length value="{{if $item.cpm_length}}{{$item.cpm_length}}{{end}}" size=6>分钟</td>
<td><input type=text name=cpm_throttle value="{{if $item.cpm_throttle}}{{$item.cpm_throttle}}{{end}}" size=6>分钟</td></tr>
<tr><td>点击: </td>
<td><input type=text name=cpc_fc value="{{if $item.cpc_fc}}{{$item.cpc_fc}}{{end}}" size=3></td>
<td><input type=text name=cpc_length value="{{if $item.cpc_length}}{{$item.cpc_length}}{{end}}" size=6>分钟</td>
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
<thead><tr><th>类型</th><th>花费金额</th><th>曝光次数</th><th>点击次数</th></tr></thead>
<tbody>{{range $one := $item.balance_topics}}{{if eq $one.which "total_balance_id"}}
<tr><td>全部: </td><td><input type=text name=limit_spend value="{{$one.limit_spend}}" size=8 /></td>
<td><input type=text name=limit_imp value="{{$one.limit_imp}}" size=8 /></td>
<td><input type=text name=limit_cli value="{{$one.limit_cli}}" size=8 /></td></tr>{{else}}
<tr><td>每天: </td><td><input type=text name=daily_spend value="{{$one.limit_spend}}" size=8 /></td>
<td><input type=text name=daily_imp value="{{$one.limit_imp}}" size=8 /></td>
<td><input type=text name=daily_cli value="{{$one.limit_cli}}" size=8 /></td></tr>{{end}}
{{end}}</tbody>
</table>
</div>
            </div>
        </div>
    </div>
</div>

<div class="form-group row">
    <label for="selectCampaignQuality" class="col-sm-2 col-form-label">质量控制:</label>
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
    <tbody>{{range $key, $val := .Other.campaignsChinese }}{{$obs := index $item $key}}
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
    <tbody>{{range $key, $val := .Other.sitesChinese }}{{$obs := index $item $key}}
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
	<div class="col-sm-3">
	</div>
	<div class="col-sm-9">
<button type="submit" class="btn btn-primary">保存!</button>
	</div>
</div>

</form>

	</div>
</div>
