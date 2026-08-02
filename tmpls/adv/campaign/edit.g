

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
	<label for="inputCampaigName" class="col-sm-2 col-form-label">活动名称：</label>
	<div class="col-sm-4">
		<input type=text class="form-control" name=campaign_name value="{{$item.campaign_name}}" />
	</div>
	<label for="inputCampaigName" class="col-sm-2 col-form-label">活动分类：</label>
	<div class="col-sm-4">
		<input type=radio class="form-input" name=target_type value="Web" {{if eq $item.target_type "Web"}}checked{{end}} />Web
		<input type=radio class="form-input" name=target_type value="App" {{if eq $item.target_type "Web"}}checked{{end}} />App
	</div>
</div>

<div class="form-group row">
	<label for="inputCampaigName" class="col-sm-2 col-form-label">外部业务编号：</label>
	<div class="col-sm-4">
		<input type=text class="form-control" name=foreign_id value="{{$item.foreign_id}}" />
	</div>
	<label for="inputCampaigName" class="col-sm-2 col-form-label">质量审核图片：</label>
	<div class="col-sm-4">
		<input type=url class="form-control" name=iurl value="{{$item.iurl}}" />
	</div>
</div>

<div class="form-group row">
    <label for="inputCampaigName" class="col-sm-2 col-form-label">起始时间:</label>
    <div class="col-sm-4">
        <input type=text class="form-control" name="startx" value="{{$item.startx}}" />
    </div>
    <label for="inputCampaigName" class="col-sm-2 col-form-label">截止时间:</label>
    <div class="col-sm-4">
        <input type=text class="form-control" name="endx" value="{{$item.endx}}" />
    </div>
</div>

{{template "deliveryschedule" .}}

<div class="form-group row">
		<label for="inputCampaigName" class="col-sm-2 col-form-label">活动描述：</label>
	<div class="col-sm-4">
		<textarea class="form-control" name=description rows=4 cols=40>{{$item.description}}</textarea>
	</div>
	<div class="col-sm-6">
		<div class="table-responsive">
<table class="table-sm table-bordered table-condensed">
<thead><tr><th>类型</th><th>花费金额</th><th>曝光次数</th><th>点击次数</th></tr></thead>
<tbody>{{range $one := $item.balance_topics}}{{if eq $one.which "total_balance_id"}}
<tr><td>全部: </td><td>{{$one.limit_spend}}</td>
<td>{{$one.limit_imp}}</td>
<td>{{$one.limit_cli}}</td></tr>{{else}}
<tr><td>每天: </td><td>{{$one.limit_spend}}</td>
<td>{{$one.limit_imp}}</td>
<td>{{$one.limit_cli}}</td></tr>{{end}}
{{end}}</tbody>
</table>
</div>
	</div>
</div>

<div class="form-group row">
    <label for="checkChannels" class="col-sm-2 col-form-label">所属行业：</label>
    <div class="col-sm-10">
        <div class="panel panel-primary">
            <div class="panel-body">
<div class="table-responsive">
<table class="table-sm table-condensed table-striped">
<thead>
<tr>
<th>行业名</th>
<th>本属行业</th>
</tr>
</thead>
<tbody>{{ with $item.chac_topics }}{{ range . }}
<tr><td>{{.channel_name_g}}</td>
<td class="text-center"><input class="form-control-inline" name=belong_ids {{if .chbelong_id}}checked{{end}} type=checkbox value="{{.channel_id}}" /></td>
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
