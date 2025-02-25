{{$attach := print "campaign_id=" (index .ARGS.campaign_id 0) "&campaign_md5=" (index .ARGS.campaign_md5 0) "&campaign_name=" (index .ARGS.campaign_name 0 | urlquery)}}

{{$item := index .Lists 0}}{{$small := print "item_id=" ($item.item_id) "&item_md5=" ($item.item_md5) "&item_name=" ($item.item_name | urlquery)}}

                <div class="panel panel-primary">
                    <div class="panel-heading">
                        修改广告活动的创意之一：{{$item.item_name}}
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
    <label for="inputCampaigName" class="col-sm-2 col-form-label text-right">创意名称:</label>
    <div class="col-sm-4">
        <input type=text class="form-control" name="item_name" value="{{$item.item_name}}">
    </div>
    <label for="inputLanding" class="col-sm-2 col-form-label text-right">落地页:</label>
    <div class="col-sm-4">
        <input type=text class="form-control" name="item_click" value="{{ if $item.item_click}}{{$item.item_click}}{{end}}">
    </div>
</div>

<div class="form-group row">
    <label for="inputStartx" class="col-sm-2 col-form-label text-right">起始时间:</label>
    <div class="col-sm-4">
        <input type=text class="form-control" name="startx" value="{{if $item.startx}}{{$item.startx}}{{end}}">
    </div>
    <label for="inputEndx" class="col-sm-2 col-form-label text-right">截止时间:</label>
    <div class="col-sm-4">
        <input type=text class="form-control" name="endx" value="{{if $item.endx}}{{$item.endx}}{{end}}">
    </div>
</div>

<div class="row">
	<div class="col-sm-6">

<div class="form-group row">
    <label for="inputSizeID" class="col-sm-4 col-form-label text-right">尺寸:</label>
    <div class="col-sm-4">
        <input type=text class="form-control" name="w" value="{{$item.w}}">
    </div>
    <div class="col-sm-4">
        <input type=text class="form-control" name="h" value="{{$item.h}}">
    </div>
</div>

<div class="form-group row">
    <label for="inputEndx" class="col-sm-4 col-form-label text-right">价格:</label>
    <div class="col-sm-4">
        <input type=text class="form-control" name="cost" value="{{if $item.cost}}{{$item.cost}}{{end}}">
    </div>
</div>

<div class="form-group row">
    <label for="costType" class="col-sm-4 col-form-label text-right">计费方式:</label>
    <div class="col-sm-8">
<input type=radio name=cost_type {{if eq $item.cost_type "ROI"}}checked{{end}} value=ROI>ROI
<input type=radio name=cost_type {{if eq $item.cost_type "CPM"}}checked{{end}} value=CPM>CPM
<input type=radio name=cost_type {{if eq $item.cost_type "CPC"}}checked{{end}} value=CPC>CPC
<input type=radio name=cost_type {{if eq $item.cost_type "CPA"}}checked{{end}} value=CPA>CPA
	</div>
</div>

	</div>
	<div class="col-sm-6">
<div class="form-group row">
    <div class="col-sm-12">

<div class="table-responsive">
<table class="table-sm table-condensed">
<tbody><tr><th class="col-sm-4 col-form-label text-right">创意预算: </th><th>花费金额</th><th>曝光次数</th><th>点击次数</th></tr>
{{range $one := $item.balance_topics}}
<tr><td>{{if eq $one.which "total_balance_id"}}全部{{else}}每天{{end}}: </td>
<td>{{$one.limit_spend}}</td>
<td>{{$one.limit_imp}}</td>
<td>{{$one.limit_cli}}</td>
</tr>
{{end}}</tbody>
</table>
</div>
    </div>
</div>
	</div>
</div>

<div class="panel panel-primary">
	<div class="panel-body">

<div class="form-group row">
    <label for="inputEndx" class="col-sm-2 col-form-label text-right">创意MIME类
:</label>
    <div class="col-sm-10">{{ range $item := .Other.qa_mime }}
<input class="form-check-input" type=radio name=qa_mime value="{{$item.which}}" {{if $item.selected}}checked{{end}} />{{$item.label_chinese}}{{end}}
    </div>
</div>

<div class="form-group row">
    <label for="inputYaxis" class="col-sm-2 col-form-label text-right">创意特点:</label>
    <div class="col-sm-10">{{ range $item := .Other.qa_creative }}
<input class="form-check-input" id="fl_{{$item.which}}" type=checkbox name=qa_creative value="{{$item.which}}" {{if $item.selected}}checked{{end}} />{{$item.label_chinese}}{{end}}
    </div>
</div>

<div class="form-group row">
    <label for="inputPlatform" class="col-sm-2 col-form-label text-right">可投放设备平台:</label>
    <div class="col-sm-10">{{ range $item := .Other.fl_device }}
<input class="form-check-input" id="fl_{{$item.which}}" type=checkbox name=fl_device value="{{$item.which}}" {{if $item.selected}}checked{{end}} />{{$item.label_chinese}}{{end}}
    </div>
</div>

<div class="form-group row">
    <label for="inputPageLevel" class="col-sm-2 col-form-label text-right">投放位置:</label>
    <div class="col-sm-10">{{ range $item := .Other.fl_position }}
<input class="form-check-input" id="fl_{{$item.which}}" type=checkbox name=fl_position value="{{$item.which}}" {{if $item.selected}}checked{{end}} />{{$item.label_chinese}}{{end}}
    </div>
</div>

<div class="form-group row">
    <label for="inputClock" class="col-sm-2 col-form-label text-right">投放环境:</label>
    <div class="col-sm-10">{{ range $item := .Other.fl_content }}
<input class="form-check-input" id="fl_{{$item.which}}" type=checkbox name=fl_content value="{{$item.which}}" {{if $item.selected}}checked{{end}} />{{$item.label_chinese}}{{end}}
    </div>
</div>

	</div>
</div>

<div class="form-group row">
    <div class="col-sm-1">
	</div>
    <div class="col-sm-11">
<button type="submit" class="btn btn-primary">保存并更新</button>
    </div>
</div>

</form>

	</div>
</div>
