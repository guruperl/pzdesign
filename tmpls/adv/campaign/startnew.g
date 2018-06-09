{{ template "header" .}}
{{ template "campaignheader" .}}

{{$cAttrs := .Other.campaignAttrsChinese }}
{{$sAttrs := .Other.siteAttrsChinese }}

            <div class="row">
                <div class="col-lg-12">
                    <div class="panel panel-primary">
                        <div class="panel-heading">
                            新建活动
                        </div>
                        <!-- /.panel-heading -->
                        <div class="panel-body">

<form method=post action=campaign>
<input type=hidden name="action" value="insert" />

<div class="form-group row">
	<label for="inputCampaigName" class="col-sm-3 col-form-label">活动名称:</label>
	<div class="col-sm-9">
		<input type=text class="form-control" name=campaign_name placeholder="名称" />
	</div>
</div>

<div class="form-group row">
	<label for="tableFrequencyCap" class="col-sm-3 col-form-label">频次控制:</label>
	<div class="col-sm-9">
<table class="table-bordered table-condensed">
<tr><th>类型</th><th>数值</th><th>周期</th><th>间隔</th></tr>
<tr><td>曝光次数: </td>
<td><input type=text name=cpm_fc size=3></td>
<td><input type=text name=cpm_length size=6>分钟</td>
<td><input type=text name=cpm_throttle size=6>分钟</td></tr>
<tr><td>点击次数: </td>
<td><input type=text name=cpc_fc size=3></td>
<td><input type=text name=cpc_length size=6>分钟</td>
<td></td></tr>
</table>
	</div>
</div>

<div class="form-group row">
	<label for="inputPageCap" class="col-sm-3 col-form-label">单页创意数:</label>
	<div class="col-sm-9">
		<input type=text class="form-control-sm" name=page_cap placeholder="最多不超过" />
	</div>
</div>

<div class="form-group row">
	<label for="tableBudget" class="col-sm-3 col-form-label">预算:</label>
	<div class="col-sm-9">
<table class="table-bordered table-condensed">
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
	<label for="inputAccessOrder" class="col-sm-3 col-form-label">黑白名单:</label>
	<div class="col-sm-9">
		<div class="form-check form-check-inline">
			<input class="form-check-input" type="radio" name="access_order" id="ao_black" value="Black">
			<label class="form-check-label" for="ao_black">黑名单</label>
			<input class="form-check-input" type="radio" name="access_order" id="ao_white" value="White">
			<label class="form-check-label" for="ao_white">白名单</label>
			<input class="form-check-input" type="radio" name="access_order" id="ao_inherit" value="Inherit">
			<label class="form-check-label" for="ao_inherit">系统默认</label>
		</div>
		<p id="myP" class="hidden">
			<input class="form-control" name="other_ids" placeholder="网站ID，用英文逗号分开" />
		</p>
	</div>
</div>

<div class="form-group row">
	<label for="selectCampaignQuality" class="col-sm-3 col-form-label">本活动质量:</label>
	<div class="col-sm-9">
		<div class="panel panel-primary">
			<div class="panel-body">
<table class="table table-condensed">
	<colgroup>
            <col class="col-md-3">
            <col class="col-md-9">
	</colgroup>
    <tbody>{{range $key, $val := .Other.campaigns }}
<tr><td class="text-right">{{index $cAttrs $key}}:</td><td><select size=1 name={{$key}}>{{range $k, $v := $val}}
<option value="{{$k}}">{{$v}}</option>{{end}}</td></tr>{{end}}
	</tbody>
</table>
			</div>
		</div>
	</div>
</div>

<div class="form-group row">
	<label for="selectSiteQuality" class="col-sm-3 col-form-label">可接受网站质量:</label>
	<div class="col-sm-9">
		<div class="panel panel-primary">
			<div class="panel-body">
<table class="table table-condensed">
    <colgroup>
            <col class="col-md-3">
            <col class="col-md-9">
    </colgroup>
    <tbody>{{range $key, $val := .Other.sites }}
<tr><td class="text-right">{{index $sAttrs $key}}:</td><td><select size=1 name={{$key}}>{{range $k, $v := $val}}
<option value="{{$k}}">{{$v}}</option>{{end}}</td></tr>{{end}}
	</tbody>
</table>
			</div>
		</div>
	</div>
</div>

<div class="form-group row">
    <label for="checkChannels" class="col-sm-3 col-form-label">行业设置:</label>
    <div class="col-sm-9">
		<div class="panel panel-primary">
			<div class="panel-body">
<table class="table table-condensed table-sm table-bordered">
<tr>
<th>行业名</th>
<th>所属行业&nbsp; </th>
<th>&nbsp; 
<input type=radio name=channel_order value="Black" />行业黑名单
<input type=radio name=channel_order value="White" />白名单
</th>
</tr>
<tbody>{{ with .Other.channel_topics }}{{ range . }}
<tr><td>{{.channel_name}}</td>
<td class="text-center"><input name=belong_ids type=checkbox value="{{.channel_id}}" /></td>
<td class="text-center"><input name=ac_ids type=checkbox value="{{.channel_id}}" /></td>
</tr>{{end}}{{end}}
</tobdy>
</table>
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
                        <!-- /.panel-body -->
                    </div>
                    <!-- /.panel -->
                </div>
                <!-- /.col-lg-6 -->
            </div>
            <!-- /.row -->
{{template "footer"}}
