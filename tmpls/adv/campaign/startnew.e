
                <div class="panel panel-primary">
                    <div class="panel-heading">
                        Create Campaign
                    </div>
                    <div class="panel-body">


<form class=form method=post action=campaign>
<input type=hidden name="action" value="insert" />

<div class="form-group row">
    <label for="inputCampaignName" class="col-sm-2 col-form-label">Campaign Name:</label>
    <div class="col-sm-4">
        <input type=text class="form-control" id="inputCampaignName" name=campaign_name placeholder="Name" />
    </div>
    <label class="col-sm-2 col-form-label">Campaign Type:</label>
    <div class="col-sm-4">
        <input type=radio class="form-input" id="targetTypeWeb" name=target_type value="Web" /><label for="targetTypeWeb">Web</label>
        <input type=radio class="form-input" id="targetTypeApp" name=target_type value="App" /><label for="targetTypeApp">App</label>
    </div>
</div>

<div class="form-group row">
<p>External business reference: enter the advertiser’s own order or campaign number for identification only; it is not used as a URL.</p>
<p>Quality-review image: enter an image URL representative of the campaign content without random cache-busting parameters. The image is used for advertising quality and safety review.</p>
</div>
<div class="form-group row">
    <label for="inputForeignId" class="col-sm-2 col-form-label">External Business Reference:</label>
    <div class="col-sm-4">
        <input type=text class="form-control" id="inputForeignId" name=foreign_id placeholder="Optional, for example ORD-2026-001" />
    </div>
    <label for="inputIurl" class="col-sm-2 col-form-label">Quality-Review Image:</label>
    <div class="col-sm-4">
        <input type=url class="form-control" id="inputIurl" name=iurl placeholder="https://cdn.example/quality.png" />
    </div>
</div>

<div class="form-group row">
    <label for="inputStartx" class="col-sm-2 col-form-label">Start Time:</label>
    <div class="col-sm-4">
        <input type=text class="form-control" id="inputStartx" name="startx" value="">
    </div>
    <label for="inputEndx" class="col-sm-2 col-form-label">End Time:</label>
    <div class="col-sm-4">
        <input type=text class="form-control" id="inputEndx" name="endx" value="">
    </div>
</div>

{{template "deliveryschedule" .}}

<div class="form-group row">
    <label for="inputCampaignDescription" class="col-sm-2 col-form-label">Campaign Description:</label>
    <div class="col-sm-4">
        <textarea class="form-control" id="inputCampaignDescription" name=description rows=4 cols=40></textarea>
    </div>
    <div class="col-sm-6">
        <div class="table-responsive">
<table class="table-sm table-bordered table-condensed">
<tr><th> </th><th>Spend Cap</th><th>Impression Cap</th><th>Click Cap</th></tr>
<tr><td>Total Cap:</td><td><input type=text id="inputLimitSpend" name=limit_spend size=8 /></td>
<td><input type=text id="inputLimitImp" name=limit_imp size=8 /></td>
<td><input type=text id="inputLimitCli" name=limit_cli size=8 /></td></tr>
<tr><td>Daily Cap:</td><td><input type=text id="inputDailySpend" name=daily_spend size=8 /></td>
<td><input type=text id="inputDailyImp" name=daily_imp size=8 /></td>
<td><input type=text id="inputDailyCli" name=daily_cli size=8 /></td></tr>
</table>
        </div>
    </div>
</div>


<div class="form-group row">
    <label for="checkChannels" class="col-sm-2 col-form-label">Industries:</label>
    <div class="col-sm-10">
        <div class="panel panel-primary">
            <div class="panel-body">
<div class="table-responsive">
<table class="table-condensed table-sm table-striped">
<thead>
<tr>
<th>Industry</th>
<th>Campaign Industry</th>
</tr>
</thead>
<tbody>{{ with .Other.channel_topics }}{{ range . }}
<tr><td>{{.channel_name}}</td>
<td class="text-center"><input class="form-control-inline" name=belong_ids type=checkbox value="{{.channel_id}}" /></td>
</tr>{{end}}{{end}}
</tbody>
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
<button type="submit" class="btn btn-primary">Submit</button>
    </div>
</div>

</form>

    </div>
</div>
