{{ template "header" .}}
{{ template "campaignheader" .}}

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
	<label for="tableFrequencyCap" class="col-sm-3 col-form-label">Frequency Cap:</label>
	<div class="col-sm-9">
<table>
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
	<label for="tableBudget" class="col-sm-3 col-form-label">Budgeting:</label>
	<div class="col-sm-9">
		<a class="btn btn-xs btn-warning" href="balance?action=topics&campaign_id={{$item.campaign_id}}&campaign_md5={{$item.campaign_md5}}&campaign_name={{$item.campaign_name | urlquery }}&entitytype_id=41">Check</a>
	</div>
</div>

<div class="form-group row">
	<label for="inputAccessOrder" class="col-sm-3 col-form-label">Access Order:</label>
	<div class="col-sm-9">
		<div class="form-check form-check-inline">
			{{$item.access_order}}
			<a class="btn btn-xs btn-warning" href="ac?action=topics&campaign_id={{$item.campaign_id}}&campaign_md5={{$item.campaign_md5}}&campaign_name={{$item.campaign_name | urlquery }}&entitytype_id=41">Check</a>
		</div>
	</div>
</div>

<div class="form-group row">
	<label class="col-sm-3 col-form-label">Quality:</label>
	<div class="col-sm-9">
		<div class="panel panel-primary">
			<div class="panel-body">
<table>
<tr><th>c_act:</th><td>{{$item.c_act}}</td></tr>
<tr><th>c_content:</th><td>{{$item.c_content}}</td></tr>
<tr><th>c_download:</th><td>{{$item.c_download}}</td></tr>
<tr><th>c_postclick:</th><td>{{$item.c_postclick}}</td></tr>
<tr><th>c_speed:</th><td>{{$item.c_speed}}</td></tr>
<tr><th>c_visual:</th><td>{{$item.c_visual}}</td></tr>
</table>
			<a class="btn btn-xs btn-warning" href="chac?action=topics&campaign_id={{$item.campaign_id}}&campaign_md5={{$item.campaign_md5}}&campaign_name={{$item.campaign_name | urlquery }}&entitytype_id=41">Check</a>
			</div>
		</div>
	</div>
</div>

<div class="form-group row">
	<label for="selectSiteQuality" class="col-sm-3 col-form-label">Accept Site:</label>
	<div class="col-sm-9">
		<div class="panel panel-primary">
			<div class="panel-body">
<table>
<tr><th>s_age</th><td>{{$item.s_age}}</td></tr>
<tr><th>s_control</th><td>{{$item.s_control}}</td></tr>
<tr><th>s_crowd</th><td>{{$item.s_crowd}}</td></tr>
<tr><th>s_domain</th><td>{{$item.s_domain}}</td></tr>
<tr><th>s_internet</th><td>{{$item.s_internet}}</td></tr>
<tr><th>s_local</th><td>{{$item.s_local}}</td></tr>
<tr><th>s_popup</th><td>{{$item.s_popup}}</td></tr>
<tr><th>s_source</th><td>{{$item.s_source}}</td></tr>
<tr><th>s_traffic</th><td>{{$item.s_traffic}}</td></tr>
<tr><th>s_visual</th><td>{{$item.s_visual}}</td></tr>
<tr><th>s_world</th><td>{{$item.s_world}}</td></tr>
</table>
			<a class="btn btn-xs btn-warning" href="chac?action=topics&campaign_id={{$item.campaign_id}}&campaign_md5={{$item.campaign_md5}}&campaign_name={{$item.campaign_name | urlquery }}&entitytype_id=41">Check</a>
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
<th>{{$item.channel_order}}
</th>
</tr>
<tbody>{{ with $item.chac_topics }}{{ range . }}{{if or .chac_id .chbelong_id}}
<tr><td>{{.channel_name}}</td>
<td>{{if .chac_id}}Selected{{end}}</td>
<td>{{if .chbelong_id}}Selected{{end}}</td>
</tr>{{end}}{{end}}{{end}}
</tobdy>
</table>
            <a class="btn btn-xs btn-warning" href="chac?action=topics&campaign_id={{$item.campaign_id}}&campaign_md5={{$item.campaign_md5}}&campaign_name={{$item.campaign_name | urlquery }}&entitytype_id=41">Check</a>
			</div>
		</div>
	</div>
</div>

<div class="form-group row">
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
