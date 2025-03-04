
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
	<div class="col-sm-3">
	</div>
	<div class="col-sm-9">
<button type="submit" class="btn btn-primary">提交！</button>
	</div>
</div>

</form>

	</div>
</div>
