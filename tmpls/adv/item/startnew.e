{{$cAttrs := .Other.itemAttrs }}
{{$sAttrs := .Other.slotAttrs }}
{{$cDefault := .Other.itemsDefault }}
{{$sDefault := .Other.slotsDefault }}

                <div class="panel panel-primary">
                    <div class="panel-heading">
                        Add Ad Group
                    </div>
                    <div class="panel-body">


<form class="form" method=post action=item>
<input type=hidden name="action" value="insert" />
<input type=hidden name=campaign_id value="{{index .ARGS.campaign_id 0}}" />
<input type=hidden name=campaign_md5 value="{{index .ARGS.campaign_md5 0}}" />
<input type=hidden name=campaign_name value="{{index .ARGS.campaign_name 0}}" />


<div class="form-group row">
    <label for="inputCampaigName" class="col-sm-1 col-form-label text-right">Ad Group Name</label>
    <div class="col-sm-3">
        <input type=text class="form-control" name="item_name" placeholder="Enter an ad group name" />
    </div>
    <label for="costType" class="col-sm-2 col-form-label text-right">Pricing Model:</label>
    <div class="col-sm-3">
        <input type=hidden name=cost_type value=CPM>
        <span class="form-control-plaintext">CPM (USD per thousand impressions)</span>
    </div>
    <label for="inputEndx" class="col-sm-1 col-form-label text-right">CPM Bid</label>
    <div class="col-sm-2">
        <input type=text class="form-control" name="cost" placeholder="1.23" />
    </div>
</div>

<div class="form-group row">
    <label for="inputLanding" class="col-sm-2 col-form-label text-right">Landing Page:</label>
    <div class="col-sm-10">
        <textarea class="form-control" rows=2 name="item_click" placeholder="https://advertiser.example/landing (macros may be used in query parameters)"></textarea>
    </div>
</div>

<div class="form-group row">
    <label for="inputLanding" class="col-sm-2 col-form-label text-right">Impression Tracking URLs:</label>
    <div class="col-sm-10">
        <textarea class="form-control" rows=2 name="imp_url" placeholder="Optional; separate multiple HTTPS/HTTP URLs with commas"></textarea>
    </div>
</div>

<div class="form-group row">
    <label for="inputLanding" class="col-sm-2 col-form-label text-right">Click Tracking URLs:</label>
    <div class="col-sm-10">
        <textarea class="form-control" rows=2 name="click_url" placeholder="Optional; separate multiple HTTPS/HTTP URLs with commas"></textarea>
    </div>
</div>

<div class="form-group row">
    <label for="inputStartx" class="col-sm-2 col-form-label text-right">Start Time:</label>
    <div class="col-sm-4">
        <input type=text class="form-control" name="startx" value="">
    </div>
    <label for="inputEndx" class="col-sm-2 col-form-label text-right">End Time:</label>
    <div class="col-sm-4">
        <input type=text class="form-control" name="endx" value="">
    </div>
</div>

{{template "deliveryschedule" .}}


<div class="form-group row">
    <label for="inputEndx" class="col-sm-2 col-form-label text-right">Creative Rendering Mode:</label>
    <div class="col-sm-10">Choose XHTML Banner for mobile; choose Iframe for other devices.</div>
</div>
<div class="form-group row">
    <label class="col-sm-2 col-form-label text-right"> </label>
    <div class="col-sm-10">{{ range $item := .Other.qa_mime }}
<input class="form-check-input" type=radio name=qa_mime value="{{$item.which}}" {{if eq $item.which "4"}}checked{{end}} />{{$item.label}}{{end}}
    </div>
</div>

<div class="form-group row">
    <label for="tableFrequencyCap" class="col-sm-2 col-form-label">Controls:</label>
    <div class="col-sm-5">
        <div class="panel panel-primary">
            <div class="panel-heading">Per-User Frequency Cap</div>
            <div class="panel-body">
<div class="table-responsive">
<table class="table-sm table-bordered table-condensed">
<tr><th>Type</th><th>Count</th><th>Period</th><th>Interval</th></tr>
<tr><td>Impressions: </td>
<td><input type=text name=cpm_fc size=3></td>
<td><input type=text name=cpm_length size=6>minutes</td>
<td><input type=text name=cpm_throttle size=6>minutes</td></tr>
<tr><td>Clicks: </td>
<td><input type=text name=cpc_fc size=3></td>
<td><input type=text name=cpc_length size=6>minutes</td>
<td></td></tr>
</table>
</div>
            </div>
        </div>
    </div>
    <div class="col-sm-5">
        <div class="panel panel-primary">
            <div class="panel-heading">Ad Group Budget</div>
            <div class="panel-body">
<div class="table-responsive">
<table class="table-sm table-bordered table-condensed">
<tr><th> </th><th>Spend Cap</th><th>Impression Cap</th><th>Click Cap</th></tr>
<tr><td>Total: </td><td><input type=text name=limit_spend size=8 /></td>
<td><input type=text name=limit_imp size=8 /></td>
<td><input type=text name=limit_cli size=8 /></td></tr>
<tr><td>Daily: </td><td><input type=text name=daily_spend size=8 /></td>
<td><input type=text name=daily_imp size=8 /></td>
<td><input type=text name=daily_cli size=8 /></td></tr>
</table>
</div>
            </div>
        </div>
    </div>
</div>


<div class="form-group row">
    <div class="col-sm-1">
    </div>
    <div class="col-sm-11">
<button type="submit" class="btn btn-primary">Create Ad Group</button>
    </div>
</div>

</form>

    </div>
</div>
