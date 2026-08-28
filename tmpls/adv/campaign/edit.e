

{{$item := index .Lists 0}}

                <div class="panel panel-primary">
                    <div class="panel-heading">
                        Edit Campaign
                    </div>
                    <div class="panel-body">

<form method=post action=campaign>
<input type=hidden name="action" value="update" />
<input type=hidden name="campaign_id" value="{{$item.campaign_id}}" />

<div class="form-group row">
    <label for="inputCampaigName" class="col-sm-2 col-form-label">Campaign Name:</label>
    <div class="col-sm-4">
        <input type=text class="form-control" name=campaign_name value="{{$item.campaign_name}}" />
    </div>
    <label for="inputCampaigName" class="col-sm-2 col-form-label">Campaign Type:</label>
    <div class="col-sm-4">
        <input type=radio class="form-input" name=target_type value="Web" {{if eq $item.target_type "Web"}}checked{{end}} />Web
        <input type=radio class="form-input" name=target_type value="App" {{if eq $item.target_type "Web"}}checked{{end}} />App
    </div>
</div>

<div class="form-group row">
    <label for="inputCampaigName" class="col-sm-2 col-form-label">External Business Reference:</label>
    <div class="col-sm-4">
        <input type=text class="form-control" name=foreign_id value="{{$item.foreign_id}}" />
    </div>
    <label for="inputCampaigName" class="col-sm-2 col-form-label">Quality-Review Image:</label>
    <div class="col-sm-4">
        <input type=url class="form-control" name=iurl value="{{$item.iurl}}" />
    </div>
</div>

<div class="form-group row">
    <label for="inputCampaigName" class="col-sm-2 col-form-label">Start Time:</label>
    <div class="col-sm-4">
        <input type=text class="form-control" name="startx" value="{{$item.startx}}" />
    </div>
    <label for="inputCampaigName" class="col-sm-2 col-form-label">End Time:</label>
    <div class="col-sm-4">
        <input type=text class="form-control" name="endx" value="{{$item.endx}}" />
    </div>
</div>

{{template "deliveryschedule" .}}

<div class="form-group row">
        <label for="inputCampaigName" class="col-sm-2 col-form-label">Campaign Description:</label>
    <div class="col-sm-4">
        <textarea class="form-control" name=description rows=4 cols=40>{{$item.description}}</textarea>
    </div>
    <div class="col-sm-6">
        <div class="table-responsive">
<table class="table-sm table-bordered table-condensed">
<thead><tr><th>Type</th><th>Spend Cap</th><th>Impression Cap</th><th>Click Cap</th></tr></thead>
<tbody>{{range $one := $item.balance_topics}}{{if eq $one.which "total_balance_id"}}
<tr><td>Total: </td><td>{{$one.limit_spend}}</td>
<td>{{$one.limit_imp}}</td>
<td>{{$one.limit_cli}}</td></tr>{{else}}
<tr><td>Daily: </td><td>{{$one.limit_spend}}</td>
<td>{{$one.limit_imp}}</td>
<td>{{$one.limit_cli}}</td></tr>{{end}}
{{end}}</tbody>
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
<table class="table-sm table-condensed table-striped">
<thead>
<tr>
<th>Industry</th>
<th>Campaign Industry</th>
</tr>
</thead>
<tbody>{{ with $item.chac_topics }}{{ range . }}
<tr><td>{{.channel_name}}</td>
<td class="text-center"><input class="form-control-inline" name=belong_ids {{if .chbelong_id}}checked{{end}} type=checkbox value="{{.channel_id}}" /></td>
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
<button type="submit" class="btn btn-primary">Save</button>
    </div>
</div>

</form>

    </div>
</div>
