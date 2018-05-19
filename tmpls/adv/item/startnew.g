{{ template "header" .}}
{{ template "itemheader" .}}

            <div class="row">
                <div class="col-lg-12">
                    <div class="panel panel-primary">
                        <div class="panel-heading">
                            新建创意
                        </div>
                        <!-- /.panel-heading -->
                        <div class="panel-body">

<form class="form" method=post action=item>
<input type=hidden name="action" value="insert" />
<input type=hidden name=campaign_id value="{{index .ARGS.campaign_id 0}}" />
<input type=hidden name=campaign_md5 value="{{index .ARGS.campaign_md5 0}}" />
<input type=hidden name=campaign_name value="{{index .ARGS.campaign_name 0}}" />


<div class="form-group row">
    <label for="inputCampaigName" class="col-sm-3 col-form-label">创意名称:</label>
    <div class="col-sm-9">
        <input type=text class="form-control" name="item_name" placeholder="名" />
    </div>
</div>

<div class="form-group row">
    <label for="inputLanding" class="col-sm-3 col-form-label">点击后去向:</label>
    <div class="col-sm-9">
        <input type=text class="form-control" name="item_click" placeholder="http://www.sample.com/landing.html" />
    </div>
</div>

<div class="form-group row">
    <label for="inputStartx" class="col-sm-3 col-form-label">起始时间:</label>
    <div class="col-sm-4">
        <input type=text class="form-control" name="startx" placeholder="yyyy-mm-dd" />
    </div>
	<div class="col-sm-1">
    <label for="inputEndx" class="col-sm-1 col-form-label">截止时间:</label>
	</div>
    <div class="col-sm-4">
        <input type=text class="form-control" name="endx" placeholder="yyyy-mm-dd" />
    </div>
</div>

<div class="form-group row">
    <label for="inputSizeID" class="col-sm-3 col-form-label">创意尺寸:</label>
    <div class="col-sm-4">
        <select class="form-control" name="size_id">
<option value=1>Half Banner 234x60</option>
<option value=2>Banner 468x60</option>
<option value=3 selected>Leaderboard 728x90</option>
<option value=4>Micro Bar 88x31</option>
<option value=5>Button 120x60</option>
<option value=6>Button 120x90</option>
<option value=7>Button 125x125</option>
<option value=8>Vertical Banner 120x240</option>
<option value=9>Skyscraper 120x600</option>
<option value=10>Wide Skyscraper 160x600</option>
<option value=11>Vertical Rectangle 240x400</option>
<option value=12>Small Rectangle 180x150</option>
<option value=13>Small Square 200x200</option>
<option value=14>Square 250x250</option>
<option value=15>3:1 Rectangle 300x100</option>
<option value=16>Medium Rectangle 300x250</option>
<option value=17>Large Rectangle 336x280</option>
<option value=18>Half Page Ad 300x600</option></select>
    </div>
    <label for="inputEndx" class="col-sm-1 col-form-label">媒体类:</label>
    <div class="col-sm-4">
        <select class="form-control" name="qa_mime">
<option value="js">Javascript</option>
<option value="html">html</option>
<option value="json">json</option>
<option value="jpg">jpg</option>
<option value="gif">gif</option>
<option value="png">png</option>
<option value="swf">swf</option>
<option value="wmv">wmv</option>
<option value="flv">flv</option></select>
    </div>

</div>

<div class="form-group row">
    <label for="inputCost" class="col-sm-3 col-form-label">结算方式:</label>
    <div class="col-sm-4">
<input type=radio name=cost_type value=CPD>CPD
<input type=radio name=cost_type value=CPM>CPM
<input type=radio name=cost_type value=CPC>CPC
<input type=radio name=cost_type value=CPA>CPA
	</div>
	<div class="col-sm-1">
    <label for="inputEndx" class="col-sm-1 col-form-label">价格:</label>
	</div>
    <div class="col-sm-4">
        <input type=text class="form-control" name="cost" placeholder="1.23" />
    </div>
</div>

<div class="form-group row">
    <label for="tableBudget" class="col-sm-3 col-form-label">预算:</label>
    <div class="col-sm-9">
<table>
<tr><th> </th><th>花费</th><th>曝光量</th><th>点击</th></tr>
<tr><td>全部: </td><td><input type=text name=limit_spend size=8 /></td>
<td><input type=text name=limit_imp size=8 /></td>
<td><input type=text name=limit_cli size=8 /></td></tr>
<tr><td>每天: </td><td><input type=text name=daily_spend size=8 /></td>
<td><input type=text name=daily_imp size=8 /></td>
<td><input type=text name=daily_cli size=8 /></td></tr>
</table>
    </div>
</div>


<div class="form-group row">
    <label for="inputCost" class="col-sm-12 col-form-label">本创意需要投放在如下广告位上</label>
<input type=hidden name="fl_language" value="Chinese" />
</div>

<div class="panel panel-primary">
	<div class="panel-body">

<div class="form-group row">
    <label for="inputPlatform" class="col-sm-3 col-form-label">平台:</label>
    <div class="col-sm-9">{{ range $item := .Other.fl_platform }}
<input class="form-check-input" id="fl_{{$item.which}}" type=checkbox name=fl_platform value="{{$item.which}}" {{if $item.default}}checked{{end}} />{{$item.label_chinese}}{{end}}
    </div>
</div>

<div class="form-group row">
    <label for="inputPageLevel" class="col-sm-3 col-form-label">页面级别:</label>
    <div class="col-sm-9">{{ range $item := .Other.fl_pagelevel }}
<input class="form-check-input" id="fl_{{$item.which}}" type=checkbox name=fl_pagelevel value="{{$item.which}}" {{if $item.default}}checked{{end}} />{{$item.label}}{{end}}
    </div>
</div>

<div class="form-group row">
    <label for="inputClock" class="col-sm-3 col-form-label">页面方向:</label>
    <div class="col-sm-9">{{ range $item := .Other.fl_clock }}
<input class="form-check-input" id="fl_{{$item.which}}" type=checkbox name=fl_clock value="{{$item.which}}" {{if $item.default}}checked{{end}} />{{$item.label_chinese}}点钟{{end}}
    </div>
</div>

<div class="form-group row">
    <label for="inputYaxis" class="col-sm-3 col-form-label">上下位置:</label>
    <div class="col-sm-9">{{ range $item := .Other.fl_yaxis }}
<input class="form-check-input" id="fl_{{$item.which}}" type=checkbox name=fl_yaxis value="{{$item.which}}" {{if $item.default}}checked{{end}} />{{$item.label_chinese}}{{end}}
    </div>
</div>


	</div>
</div>

<div class="form-group row">
    <div class="col-sm-9">
<button type="submit" class="btn btn-primary">新建完成</button>
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
