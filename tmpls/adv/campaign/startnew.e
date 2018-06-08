{{ template "header" .}}
{{ template "campaignheader" .}}

{{$cAttrs := .Other.campaignAttrs}}
{{$sAttrs := .Other.siteAttrs}}

            <div class="row">
                <div class="col-lg-12">
                    <div class="panel panel-primary">
                        <div class="panel-heading">
                            Create New Campaign
                        </div>
                        <!-- /.panel-heading -->
                        <div class="panel-body">

<form method=post action=campaign>
<input type=hidden name="action" value="insert" />

<div class="form-group row">
	<label for="inputCampaigName" class="col-sm-3 col-form-label">Campaign Name:</label>
	<div class="col-sm-9">
		<input type=text class="form-control" name=campaign_name placeholder="Name of Campaign" />
	</div>
</div>

<div class="form-group row">
	<label for="tableFrequencyCap" class="col-sm-3 col-form-label">Frequency Cap:</label>
	<div class="col-sm-9">
<table class="table-bordered table-condensed">
<tr><th>Type</th><th>Number</th><th>Period</th><th>Throttle</th></tr>
<tr><td>Impressions: </td>
<td><input type=text name=cpm_fc size=3></td>
<td><input type=text name=cpm_length size=6>min</td>
<td><input type=text name=cpm_throttle size=6>min</td></tr>
<tr><td>Clicks: </td>
<td><input type=text name=cpc_fc size=3></td>
<td><input type=text name=cpc_length size=6>min</td>
<td></td></tr>
</table>
	</div>
</div>

<div class="form-group row">
	<label for="inputPageCap" class="col-sm-3 col-form-label">Page Cap:</label>
	<div class="col-sm-9">
		<input type=text class="form-control-sm" name=page_cap placeholder="campaign items on a page" />
	</div>
</div>

<div class="form-group row">
	<label for="tableBudget" class="col-sm-3 col-form-label">Budget:</label>
	<div class="col-sm-9">
<table class="table-bordered table-condensed">
<tr><th> </th><th>Budget</th><th>Impressions</th><th>Clicks</th></tr>
<tr><td>Total: </td><td><input type=text name=limit_spend size=8 /></td>
<td><input type=text name=limit_imp size=8 /></td>
<td><input type=text name=limit_cli size=8 /></td></tr>
<tr><td>Daily: </td><td><input type=text name=daily_spend size=8 /></td>
<td><input type=text name=daily_imp size=8 /></td>
<td><input type=text name=daily_cli size=8 /></td></tr>
</table>
	</div>
</div>

<div class="form-group row">
	<label for="inputAccessOrder" class="col-sm-3 col-form-label">Access Order:</label>
	<div class="col-sm-9">
		<div class="form-check form-check-inline">
			<input class="form-check-input" type="radio" name="access_order" id="ao_black" value="Black">
			<label class="form-check-label" for="ao_black">Black</label>
			<input class="form-check-input" type="radio" name="access_order" id="ao_white" value="White">
			<label class="form-check-label" for="ao_white">White</label>
			<input class="form-check-input" type="radio" name="access_order" id="ao_inherit" value="Inherit">
			<label class="form-check-label" for="ao_inherit">Inherit</label>
		</div>
		<p id="myP" class="hidden">
			<input class="form-control" name="other_ids" placeholder="site IDs separated by comma" />
		</p>
	</div>
</div>

<div class="form-group row">
	<label for="selectCampaignQuality" class="col-sm-3 col-form-label">Quality:</label>
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
	<label for="selectSiteQuality" class="col-sm-3 col-form-label">Accept Site:</label>
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
</table>
			</div>
		</div>
	</div>
</div>

<div class="form-group row">
    <label for="checkChannels" class="col-sm-3 col-form-label">Channels:</label>
    <div class="col-sm-9">
		<div class="panel panel-primary">
			<div class="panel-body">
<table>
<tr>
<th>Name</th>
<th>Belong&nbsp; </th>
<th>&nbsp; 
<input type=radio name=channel_order value="Black" />Black
<input type=radio name=channel_order value="White" />White
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
<button type="submit" class="btn btn-primary">Create Now!</button>
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
