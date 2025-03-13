
                <div class="panel panel-primary">
                    <div class="panel-heading">
                        新建广告活动
                    </div>
                    <div class="panel-body">


<form class=form method=post action=campaign>
<input type=hidden name="action" value="insert" />

<div class="form-group row">
	<label for="inputCampaigName" class="col-sm-2 col-form-label">活动名称：</label>
	<div class="col-sm-4">
		<input type=text class="form-control" name=campaign_name placeholder="名称" />
	</div>
	<label for="inputCampaigName" class="col-sm-2 col-form-label">活动分类：</label>
	<div class="col-sm-4">
		<input type=radio class="form-input" name=target_type value="Web" />Web
		<input type=radio class="form-input" name=target_type value="App" />App
	</div>
</div>

<div class="form-group row">
	<label for="inputCampaigName" class="col-sm-2 col-form-label">外部编号:</label>
	<div class="col-sm-4">
		<input type=text class="form-control" name=foreign_id placeholder="编号 可不填" />
	</div>
	<label for="inputCampaigName" class="col-sm-2 col-form-label">应用链接：</label>
	<div class="col-sm-4">
		<input type=text class="form-control" name=extlink placeholder="应用市场链接或落地页" />
	</div>
</div>

<div class="form-group row">
    <label for="inputCampaigName" class="col-sm-2 col-form-label">起始时间:</label>
    <div class="col-sm-4">
        <input type=text class="form-control" name="startx" value="">
    </div>
    <label for="inputCampaigName" class="col-sm-2 col-form-label">截止时间:</label>
    <div class="col-sm-4">
        <input type=text class="form-control" name="endx" value="">
    </div>
</div>

<div class="form-group row">
	<label for="inputCampaigName" class="col-sm-2 col-form-label">活动描述：</label>
	<div class="col-sm-4">
		<textarea class="form-control" name=description rows=4 cols=40></textarea>
	</div>
	<div class="col-sm-6">
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


<div class="form-group row">
    <label for="checkChannels" class="col-sm-2 col-form-label">所属行业：</label>
    <div class="col-sm-10">
		<div class="panel panel-primary">
			<div class="panel-body">
<div class="table-responsive">
<table class="table-condensed table-sm table-striped">
<thead>
<tr>
<th>行业名</th>
<th>本属行业</th>
</tr>
</thead>
<tbody>{{ with .Other.channel_topics }}{{ range . }}
<tr><td>{{.channel_name_g}}</td>
<td class="text-center"><input class="form-control-inline" name=belong_ids type=checkbox value="{{.channel_id}}" /></td>
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
<button type="submit" class="btn btn-primary">提交！</button>
	</div>
</div>

</form>

	</div>
</div>
