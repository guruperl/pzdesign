{{$item := index .Lists 0}}

{{$cAttrs := .Other.itemAttrs}}
{{$sAttrs := .Other.slotAttrs}}

                <div class="panel panel-primary">
                    <div class="panel-heading">
                        Edit {{$item.item_name}}
                    </div>
                    <div class="panel-body">

<form class="form" method=post action=item>
<input type=hidden name="action" value="update" />
<input type=hidden name="item_id" value="{{$item.item_id}}" />
<input type=hidden name="campaign_id" value="{{$item.campaign_id}}" />
<input type=hidden name=campaign_id value="{{index .ARGS.campaign_id 0}}" />
<input type=hidden name=campaign_md5 value="{{index .ARGS.campaign_md5 0}}" />
<input type=hidden name=campaign_name value="{{index .ARGS.campaign_name 0}}" />


<div class="form-group row">
    <label for="inputCampaigName" class="col-sm-1 col-form-label text-right">Name:</label>
    <div class="col-sm-3">
        <input type=text class="form-control" name="item_name" value="{{$item.item_name}}">
    </div>
    <label for="costType" class="col-sm-2 col-form-label text-right">Pricing Model:</label>
    <div class="col-sm-3">
    <input type=hidden name=cost_type value=CPM>
    <span class="form-control-plaintext">CPM (USD per thousand impressions)</span>
    {{if $item.legacy_cost_type}}<small class="text-warning">This record uses the legacy {{$item.cost_type}} type. Before saving, review its business meaning and enter a new CPM bid; the system does not convert it automatically.</small>{{end}}
    </div>
    <label for="inputEndx" class="col-sm-1 col-form-label text-right">CPM Bid:</label>
    <div class="col-sm-2">
        <input type=text class="form-control" name="cost" value="{{$item.cost}}" />
    </div>
</div>

<div class="form-group row">
    <label for="inputLanding" class="col-sm-2 col-form-label text-right">Landing Page:</label>
    <div class="col-sm-10">
        <textarea class="form-control" rows=2 name="item_click">{{$item.item_click}}</textarea>
    </div>
</div>

<div class="form-group row">
    <label for="inputLanding" class="col-sm-2 col-form-label text-right">Impression Tracking URLs:</label>
    <div class="col-sm-10">
        <textarea class="form-control" rows=2 name="imp_url">{{$item.imp_url}}</textarea>
    </div>
</div>

<div class="form-group row">
    <label for="inputLanding" class="col-sm-2 col-form-label text-right">Click Tracking URLs:</label>
    <div class="col-sm-10">
        <textarea class="form-control" rows=2 name="click_url">{{$item.click_url}}</textarea>
    </div>
</div>

<div class="form-group row">
    <label for="inputStartx" class="col-sm-2 col-form-label text-right">Start Time:</label>
    <div class="col-sm-4">
        <input type=text class="form-control" name="startx" value="{{if $item.startx}}{{$item.startx}}{{end}}">
    </div>
    <label for="inputEndx" class="col-sm-2 col-form-label text-right">End Time:</label>
    <div class="col-sm-4">
        <input type=text class="form-control" name="endx" value="{{ if $item.endx }}{{$item.endx}}{{end}}">
    </div>
</div>

{{template "deliveryschedule" .}}


<div class="form-group row">
    <label for="inputEndx" class="col-sm-2 col-form-label text-right">Creative Rendering Mode:</label>
    <div class="col-sm-10">Choose XHTML Banner for mobile; choose Iframe for other devices.</div>
</div>
<div class="form-group row">
    <label class="col-sm-2 col-form-label text-right"> </label>
    <div class="col-sm-10">{{ range $one := .Other.qa_mime }}
<input class="form-check-input" type=radio name=qa_mime value="{{$one.which}}" {{if $one.selected}}checked{{end}} />{{$one.label}}{{end}}
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
<td><input type=text name=cpm_fc value="{{$item.cpm_fc}}" size=3 ></td>
<td><input type=text name=cpm_length value="{{$item.cpm_length}}" size=6>minutes</td>
<td><input type=text name=cpm_throttle value="{{$item.cpm_throttle}}" size=6>minutes</td></tr>
<tr><td>Clicks: </td>
<td><input type=text name=cpc_fc value="{{$item.cpc_fc}}" size=3></td>
<td><input type=text name=cpc_length value="{{$item.cpc_fc}}" size=6>minutes</td>
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
<tr><th> </th><th>Spend Cap</th><th>Impression Cap</th><th>Click Cap</th></tr>{{range $one := $item.balance_topics}}
<tr><td>{{if eq $one.which "total_balance_id"}}Total{{else}}Daily{{end}}: </td>
<td>{{$one.limit_spend}}</td>
<td>{{$one.limit_imp}}</td>
<td>{{$one.limit_cli}}</td>
</tr>{{end}}
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
<button type="submit" class="btn btn-primary">Save and Update</button>
    </div>
</div>

</form>

    </div>
</div>
