

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
	<div class="col-sm-3">
	</div>
	<div class="col-sm-9">
<button type="submit" class="btn btn-primary">保存!</button>
	</div>
</div>

</form>

	</div>
</div>
