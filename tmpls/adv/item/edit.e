{{ template "header" .}}
{{ template "itemheader" .}}

{{$item := index .Lists 0}}

            <div class="row">
                <div class="col-lg-12">
                    <div class="panel panel-primary">
                        <div class="panel-heading">
                            Edit Item
                        </div>
                        <!-- /.panel-heading -->
                        <div class="panel-body">

<form class="form" method=post action=item>
<input type=hidden name="action" value="update" />
<input type=hidden name="item_id" value="{{$item.item_id}}" />
<input type=hidden name="campaign_id" value="{{$item.campaign_id}}" />
<input type=hidden name=campaign_id value="{{index .ARGS.campaign_id 0}}" />
<input type=hidden name=campaign_md5 value="{{index .ARGS.campaign_md5 0}}" />
<input type=hidden name=campaign_name value="{{index .ARGS.campaign_name 0}}" />


<div class="form-group row">
    <label for="inputCampaigName" class="col-sm-2 col-form-label text-right">Item Name:</label>
    <div class="col-sm-4">
        <input type=text class="form-control" name="item_name" value="{{$item.item_name}}" placeholder="Name of Item" />
    </div>
    <label for="inputLanding" class="col-sm-2 col-form-label text-right">After Click:</label>
    <div class="col-sm-4">
        <input type=text class="form-control" name="item_click" value="{{$item.item_click}}" placeholder="https://advertiser.example/landing.html" />
    </div>
</div>

<div class="form-group row">
    <label for="inputStartx" class="col-sm-2 col-form-label text-right">Start:</label>
    <div class="col-sm-4">
        <input type=text class="form-control" name="startx" value="{{$item.startx}}" placeholder="yyyy-mm-dd" />
    </div>
    <label for="inputEndx" class="col-sm-2 col-form-label text-right">End:</label>
    <div class="col-sm-4">
        <input type=text class="form-control" name="endx" value="{{$item.endx}}" placeholder="yyyy-mm-dd" />
    </div>
</div>

{{template "deliveryschedule" .}}

<div class="form-group row">
    <label for="inputSizeID" class="col-sm-2 col-form-label text-right">Size:</label>
    <div class="col-sm-2">
        <input type=text class="form-control" name="w" value="{{$item.w}}">
    </div>
    <div class="col-sm-2">
        <input type=text class="form-control" name="h" value="{{$item.h}}">
    </div>

    <label for="inputEndx" class="col-sm-2 col-form-label text-right">Mime:</label>
    <div class="col-sm-4">{{ range $item := .Other.qa_mime }}
<input class="form-check-input" type=radio name=qa_mime value="{{$item.which}}" {{if $item.selected}}checked{{end}} />{{$item.label}}{{end}}
    </div>
</div>

<div class="form-group row">
	<label for="inputCost" class="col-sm-2 col-form-label text-right">Cost Type:</label>
	<div class="col-sm-4">
	<input type=hidden name=cost_type value=CPM>
	<span class="form-control-plaintext">CPM (USD per 1,000 impressions)</span>
	{{if $item.legacy_cost_type}}<small class="text-warning">This is a legacy {{$item.cost_type}} record. Review its business meaning and enter a new CPM bid before saving; W8M does not auto-convert it.</small>{{end}}
	</div>
	<label for="inputEndx" class="col-sm-2 col-form-label text-right">CPM Bid:</label>
    <div class="col-sm-4">
        <input type=text class="form-control" name="cost" value="{{$item.cost}}" placeholder="1.23" />
    </div>
</div>

<div class="form-group row">
	<div class="col-sm-1">
	</div>
    <label for="inputCost" class="col-sm-11 col-form-label">Should Appear In The Following Slots</label>
</div>

<div class="panel panel-primary">
	<div class="panel-body">

<div class="form-group row">
    <label for="inputPlatform" class="col-sm-2 col-form-label text-right">Platform:</label>
    <div class="col-sm-10">{{ range $item := .Other.fl_device }}
<input class="form-check-input" id="fl_{{$item.which}}" type=checkbox name=fl_device value="{{$item.which}}" {{if $item.selected}}checked{{end}} />{{$item.label}}{{end}}
    </div>
</div>

<div class="form-group row">
    <label for="inputPageLevel" class="col-sm-2 col-form-label text-right">Page Level:</label>
    <div class="col-sm-10">{{ range $item := .Other.fl_position }}
<input class="form-check-input" id="fl_{{$item.which}}" type=checkbox name=fl_position value="{{$item.which}}" {{if $item.selected}}checked{{end}} />{{$item.label}}{{end}}
    </div>
</div>

<div class="form-group row">
    <label for="inputClock" class="col-sm-2 col-form-label text-right">Clock:</label>
    <div class="col-sm-10">{{ range $item := .Other.fl_content }}
<input class="form-check-input" id="fl_{{$item.which}}" type=checkbox name=fl_content value="{{$item.which}}" {{if $item.selected}}checked{{end}} />{{$item.label}}{{end}}
    </div>
</div>

<div class="form-group row">
    <label for="inputYaxis" class="col-sm-2 col-form-label text-right">Yaxis:</label>
    <div class="col-sm-10">{{ range $item := .Other.fl_creative }}
<input class="form-check-input" id="fl_{{$item.which}}" type=checkbox name=fl_creative value="{{$item.which}}" {{if $item.selected}}checked{{end}} />{{$item.label}}{{end}}
    </div>
</div>

	</div>
</div>

<div class="form-group row">
	<div class="col-sm-1"> </div>
    <div class="col-sm-11">
<button type="submit" class="btn btn-primary">Save and Update!</button>
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
