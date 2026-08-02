{{ template "header" .}}
{{ template "itemheader" .}}

            <div class="row">
                <div class="col-lg-12">
                    <div class="panel panel-primary">
                        <div class="panel-heading">
                            Create New Ad Item
                        </div>
                        <!-- /.panel-heading -->
                        <div class="panel-body">

<form class="form" method=post action=item>
<input type=hidden name="action" value="insert" />
<input type=hidden name=campaign_id value="{{index .ARGS.campaign_id 0}}" />
<input type=hidden name=campaign_md5 value="{{index .ARGS.campaign_md5 0}}" />
<input type=hidden name=campaign_name value="{{index .ARGS.campaign_name 0}}" />


<div class="form-group row">
    <label for="inputCampaigName" class="col-sm-2 col-form-label text-right">Item Name:</label>
    <div class="col-sm-4">
        <input type=text class="form-control" name="item_name" placeholder="Name of Item" />
    </div>
    <label for="inputLanding" class="col-sm-2 col-form-label text-right">After Click:</label>
    <div class="col-sm-4">
        <input type=text class="form-control" name="item_click" placeholder="https://advertiser.example/landing.html" />
    </div>
</div>

<div class="form-group row">
    <label for="inputStartx" class="col-sm-2 col-form-label text-right">Start:</label>
    <div class="col-sm-4">
        <input type=text class="form-control" name="startx" placeholder="yyyy-mm-dd hh:mm:ss" />
    </div>
    <label for="inputEndx" class="col-sm-2 col-form-label text-right">End:</label>
    <div class="col-sm-4">
        <input type=text class="form-control" name="endx" placeholder="yyyy-mm-dd hh:mm:ss" />
    </div>
</div>

{{template "deliveryschedule" .}}

<div class="form-group row">
    <label for="inputSizeID" class="col-sm-2 col-form-label text-right">Size:</label>
    <div class="col-sm-2">
        <input type=text class="form-control" name="w" placeholder="width">
    </div>
    <div class="col-sm-2">
        <input type=text class="form-control" name="h" placeholder="height">
    </div>
    <label for="inputEndx" class="col-sm-2 col-form-label text-right">Mime:</label>
    <div class="col-sm-4">{{ range $item := .Other.qa_mime }}
<input class="form-check-input" type=radio name=qa_mime value="{{$item.which}}" {{if $item.default}}checked{{end}} />{{$item.label}}{{end}}
    </div>
</div>

<div class="form-group row">
	<label for="inputCost" class="col-sm-2 col-form-label text-right">Cost Type:</label>
	<div class="col-sm-4">
	<input type=hidden name=cost_type value=CPM>
	<span class="form-control-plaintext">CPM (USD per 1,000 impressions)</span>
	</div>
	<label for="inputEndx" class="col-sm-2 col-form-label text-right">CPM Bid:</label>
    <div class="col-sm-4">
        <input type=text class="form-control" name="cost" placeholder="1.23" />
    </div>
</div>

<div class="form-group row">
    <label for="tableBudget" class="col-sm-2 col-form-label text-right">Budget:</label>
    <div class="col-sm-6">
<table class="table table-condensed">
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
    <div class="col-sm-1">
<input type=hidden name="fl_language" value="Chinese" />
    </div>
    <label for="inputCost" class="col-sm-11 col-form-label">Should Appear In The Following Slots</label>
</div>

<div class="panel panel-primary">
	<div class="panel-body">

<div class="form-group row">
    <label for="inputPlatform" class="col-sm-2 col-form-label text-right">Platform:</label>
    <div class="col-sm-10">{{ range $item := .Other.fl_device }}
<input class="form-check-input" id="fl_{{$item.which}}" type=checkbox name=fl_device value="{{$item.which}}" {{if $item.default}}checked{{end}} />{{$item.label}}{{end}}
    </div>
</div>

<div class="form-group row">
    <label for="inputPageLevel" class="col-sm-2 col-form-label text-right">Page Level:</label>
    <div class="col-sm-10">{{ range $item := .Other.fl_position }}
<input class="form-check-input" id="fl_{{$item.which}}" type=checkbox name=fl_position value="{{$item.which}}" {{if $item.default}}checked{{end}} />{{$item.label}}{{end}}
    </div>
</div>

<div class="form-group row">
    <label for="inputClock" class="col-sm-2 col-form-label text-right">Clock:</label>
    <div class="col-sm-10">{{ range $item := .Other.fl_content }}
<input class="form-check-input" id="fl_{{$item.which}}" type=checkbox name=fl_content value="{{$item.which}}" {{if $item.default}}checked{{end}} />{{$item.label}}{{end}}
    </div>
</div>

<div class="form-group row">
    <label for="inputYaxis" class="col-sm-2 col-form-label text-right">Yaxis:</label>
    <div class="col-sm-10">{{ range $item := .Other.fl_creative }}
<input class="form-check-input" id="fl_{{$item.which}}" type=checkbox name=fl_creative value="{{$item.which}}" {{if $item.default}}checked{{end}} />{{$item.label}}{{end}}
    </div>
</div>


	</div>
</div>

<div class="form-group row">
    <div class="col-sm-1">
    </div>
    <div class="col-sm-11">
<button type="submit" class="btn btn-primary">Create Now Item!</button>
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
