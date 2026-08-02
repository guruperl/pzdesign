{{ template "header" .}}
{{ template "campaignheader" .}}

{{$cAttrs := .Other.campaignAttrs}}
{{$sAttrs := .Other.siteAttrs}}

{{$item := index .Lists 0}}

            <div class="row">
                <div class="col-lg-12">
                    <div class="panel panel-primary">
                        <div class="panel-heading">
                            Edit Campaign
                        </div>
                        <!-- /.panel-heading -->
                        <div class="panel-body">

<form method=post action=campaign>
<input type=hidden name="action" value="update" />
<input type=hidden name="campaign_id" value="{{$item.campaign_id}}" />

<div class="form-group row">
	<label for="inputCampaigName" class="col-sm-3 col-form-label">Campaign Name:</label>
	<div class="col-sm-9">
		<input type=text class="form-control" name="campaign_name" value="{{$item.campaign_name}}" placeholder="Name of Campaign" />
	</div>
</div>

<div class="form-group row">
	<label class="col-sm-2 col-form-label">Start (UTC):</label>
	<div class="col-sm-4"><input type="text" class="form-control" name="startx" value="{{$item.startx}}" placeholder="YYYY-MM-DD HH:MM:SS"></div>
	<label class="col-sm-2 col-form-label">End (UTC):</label>
	<div class="col-sm-4"><input type="text" class="form-control" name="endx" value="{{$item.endx}}" placeholder="YYYY-MM-DD HH:MM:SS"></div>
</div>

{{template "deliveryschedule" .}}

<div class="form-group row">
	<label for="tableFrequencyCap" class="col-sm-3 col-form-label">Frequency Cap:</label>
	<div class="col-sm-9">
<table class="table table-sm table-bordered table-condensed">
<tr><th>Type</th><th>Number</th><th>Period</th><th>Throttle</th></tr>
<tr><td>Impressions: </td>
<td><input type=text name=cpm_fc value="{{$item.cpm_fc}}" size=3></td>
<td><input type=text name=cpm_length value="{{$item.cpm_length}}" size=6>min</td>
<td><input type=text name=cpm_throttle value="{{$item.cpm_throttle}}" size=6>min</td></tr>
<tr><td>Clicks: </td>
<td><input type=text name=cpc_fc value="{{$item.cpc_fc}}" size=3></td>
<td><input type=text name=cpc_length value="{{$item.cpc_fc}}" size=6>min</td>
<td></td></tr>
</table>
	</div>
</div>

<div class="form-group row">
	<label for="inputPageCap" class="col-sm-3 col-form-label">Page Cap:</label>
	<div class="col-sm-9">
		<input type=text class="form-control-sm" name="page_cap" value="{{$item.page_cap}}" placeholder="campaign items on a page" />
	</div>
</div>

<div class="form-group row">
	<label for="tableBudget" class="col-sm-3 col-form-label">Budget:</label>
	<div class="col-sm-9">
		<a class="btn btn-xs btn-warning" href="balance?action=topics&campaign_id={{$item.campaign_id}}&campaign_md5={{$item.campaign_md5}}&campaign_name={{$item.campaign_name | urlquery }}&entitytype_id=41">Check</a>
	</div>
</div>

<!-- div class="form-group row">
	<label for="inputAccessOrder" class="col-sm-3 col-form-label">Access Order:</label>
	<div class="col-sm-9">
		<div class="form-check form-check-inline">
			{{$item.access_order}}
			<a class="btn btn-xs btn-warning" href="ac?action=topics&campaign_id={{$item.campaign_id}}&campaign_md5={{$item.campaign_md5}}&campaign_name={{$item.campaign_name | urlquery }}&entitytype_id=41">Check</a>
		</div>
	</div>
</div -->

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
    <tbody>{{range $key, $val := .Other.campaigns }}{{$obs := index $item $key}}
<tr><td class="text-right">{{index $cAttrs $key}}:</td><td><select size=1 name={{$key}}>{{range $k, $v := $val}}
<option {{if eq $k $obs}}selected{{end}} value="{{$k}}">{{$v}}</option>{{end}}</td></tr>{{end}}
</table>
            </div>
        </div>
    </div>
</div>

<div class="form-group row">
    <label for="selectSiteQuality" class="col-sm-3 col-form-label">Site Quality Required:</label>
    <div class="col-sm-9">
        <div class="panel panel-primary">
            <div class="panel-body">
<table class="table table-condensed">
    <colgroup>
            <col class="col-md-3">
            <col class="col-md-9">
    </colgroup>
    <tbody>{{range $key, $val := .Other.sites }}{{$obs := index $item $key}}
<tr><td class="text-right">{{index $sAttrs $key}}:</td><td><select size=1 name={{$key}}>{{range $k, $v := $val}}
<option {{if eq $k $obs}}selected{{end}} value="{{$k}}">{{$v}}</option>{{end}}</td></tr>{{end}}
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
<table class="table table-sm table-bordered table-condensed">
<tr>
<th>Name</th>
<th>Belong&nbsp; </th>
<th>{{$item.channel_order}}
</th>
</tr>
<tbody>{{ with .Other.channel_topics }}{{ range . }}
<tr><td>{{.channel_name_g}}</td>
<td class="text-center"><input class="form-control-inline" name=belong_ids {{if .chbelong_id}}checked{{end}} type=checkbox value="{{.channel_id}}" /></td>
<td class="text-center"><input class="form-control-inline" name=ac_ids {{if .chac_id}}checked{{end}} type=checkbox value="{{.channel_id}}" /></td>
</tr>{{end}}{{end}}
</tobdy>
</table>
            <a class="btn btn-xs btn-warning" href="chac?action=topics&campaign_id={{$item.campaign_id}}&campaign_md5={{$item.campaign_md5}}&campaign_name={{$item.campaign_name | urlquery }}&entitytype_id=41">Check</a>
			</div>
		</div>
	</div>
</div>

<div class="form-group row">
	<div class="col-sm-3">
	</div>
	<div class="col-sm-9">
<button type="submit" class="btn btn-primary">Update Now!</button>
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
