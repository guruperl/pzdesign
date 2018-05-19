{{ template "header" .}}
{{ template "itemheader" .}}

{{$item := index .Lists 0}}

            <div class="row">
                <div class="col-lg-12">
                    <div class="panel panel-primary">
                        <div class="panel-heading">
                            编辑修改创意
                        </div>
                        <!-- /.panel-heading -->
                        <div class="panel-body">

<form class="form" method=post action=item>
<input type=hidden name="action" value="update" />
<input type=hidden name="campaign_id" value="{{$item.campaign_id}}" />
<input type=hidden name=campaign_id value="{{index .ARGS.campaign_id 0}}" />
<input type=hidden name=campaign_md5 value="{{index .ARGS.campaign_md5 0}}" />
<input type=hidden name=campaign_name value="{{index .ARGS.campaign_name 0}}" />


<div class="form-group row">
    <label for="inputCampaigName" class="col-sm-3 col-form-label">创意名称:</label>
    <div class="col-sm-9">
        <input type=text class="form-control" name="item_name" value="{{$item.item_name}}" placeholder="Name of Item" />
    </div>
</div>

<div class="form-group row">
    <label for="inputLanding" class="col-sm-3 col-form-label">点击后去向:</label>
    <div class="col-sm-9">
        <input type=text class="form-control" name="item_click" value="{{$item.item_click}}" placeholder="http://www.sample.com/landing.html" />
    </div>
</div>

<div class="form-group row">
    <label for="inputStartx" class="col-sm-3 col-form-label">起始时间:</label>
    <div class="col-sm-4">
        <input type=text class="form-control" name="startx" value="{{$item.startx}}" placeholder="yyyy-mm-dd" />
    </div>
	<div class="col-sm-1">
    <label for="inputEndx" class="col-sm-1 col-form-label align-right">截止时间:</label>
	</div>
    <div class="col-sm-4">
        <input type=text class="form-control" name="endx" value="{{$item.endx}}" placeholder="yyyy-mm-dd" />
    </div>
</div>

<div class="form-group row">
    <label for="inputSizeID" class="col-sm-3 col-form-label">创意尺寸:</label>
    <div class="col-sm-4">
        <select class="form-control" name="size_id">
<option {{if eq $item.size_id 1}}selected{{end}} value=1>Half Banner 234x60</option>
<option {{if eq $item.size_id 2}}selected{{end}} value=2>Banner 468x60</option>
<option {{if eq $item.size_id 3}}selected{{end}} value=3 selected>Leaderboard 728x90</option>
<option {{if eq $item.size_id 4}}selected{{end}} value=4>Micro Bar 88x31</option>
<option {{if eq $item.size_id 5}}selected{{end}} value=5>Button 120x60</option>
<option {{if eq $item.size_id 6}}selected{{end}} value=6>Button 120x90</option>
<option {{if eq $item.size_id 7}}selected{{end}} value=7>Button 125x125</option>
<option {{if eq $item.size_id 8}}selected{{end}} value=8>Vertical Banner 120x240</option>
<option {{if eq $item.size_id 9}}selected{{end}} value=9>Skyscraper 120x600</option>
<option {{if eq $item.size_id 10}}selected{{end}} value=10>Wide Skyscraper 160x600</option>
<option {{if eq $item.size_id 11}}selected{{end}} value=11>Vertical Rectangle 240x400</option>
<option {{if eq $item.size_id 12}}selected{{end}} value=12>Small Rectangle 180x150</option>
<option {{if eq $item.size_id 13}}selected{{end}} value=13>Small Square 200x200</option>
<option {{if eq $item.size_id 14}}selected{{end}} value=14>Square 250x250</option>
<option {{if eq $item.size_id 15}}selected{{end}} value=15>3:1 Rectangle 300x100</option>
<option {{if eq $item.size_id 16}}selected{{end}} value=16>Medium Rectangle 300x250</option>
<option {{if eq $item.size_id 17}}selected{{end}} value=17>Large Rectangle 336x280</option>
<option {{if eq $item.size_id 18}}selected{{end}} value=18>Half Page Ad 300x600</option></select>
    </div>
    <label for="inputEndx" class="col-sm-1 col-form-label">类别:</label>
    <div class="col-sm-4">
        <select class="form-control" name="qa_mime">
<option {{if eq $item.qa_mime "js"}}selected{{end}} value="js">Javascript</option>
<option {{if eq $item.qa_mime "html"}}selected{{end}} value="html">html</option>
<option {{if eq $item.qa_mime "json"}}selected{{end}} value="json">json</option>
<option {{if eq $item.qa_mime "jpg"}}selected{{end}} value="jpg">jpg</option>
<option {{if eq $item.qa_mime "gif"}}selected{{end}} value="gif">gif</option>
<option {{if eq $item.qa_mime "png"}}selected{{end}} value="png">png</option>
<option {{if eq $item.qa_mime "swf"}}selected{{end}} value="swf">swf</option>
<option {{if eq $item.qa_mime "wmv"}}selected{{end}} value="wmv">wmv</option>
<option {{if eq $item.qa_mime "flv"}}selected{{end}} value="flv">flv</option></select>
    </div>
</div>

<div class="form-group row">
    <label for="inputCost" class="col-sm-3 col-form-label">结算方式:</label>
    <div class="col-sm-4">
<input type=radio name=cost_type {{if eq $item.cost_type "CPD"}}checked{{end}} value=CPD>CPD
<input type=radio name=cost_type {{if eq $item.cost_type "CPM"}}checked{{end}} value=CPM>CPM
<input type=radio name=cost_type {{if eq $item.cost_type "CPC"}}checked{{end}} value=CPC>CPC
<input type=radio name=cost_type {{if eq $item.cost_type "CPA"}}checked{{end}} value=CPA>CPA
	</div>
	<div class="col-sm-1">
    <label for="inputEndx" class="col-sm-1 col-form-label align-right">价格:</label>
	</div>
    <div class="col-sm-4">
        <input type=text class="form-control" name="cost" value="{{$item.cost}}" placeholder="1.23" />
    </div>
</div>

<div class="form-group row">
    <label for="inputCost" class="col-sm-12 col-form-label">本创意需要投放在如下
广告位上</label>
</div>

<div class="panel panel-primary">
	<div class="panel-body">

<div class="form-group row">
    <label for="inputPlatform" class="col-sm-3 col-form-label">平台:</label>
    <div class="col-sm-9">{{ range $item := .Other.fl_platform }}
<input class="form-check-input" id="fl_{{$item.which}}" type=checkbox name=fl_platform value="{{$item.which}}" {{if $item.selected}}checked{{end}} />{{$item.label}}{{end}}
    </div>
</div>

<div class="form-group row">
    <label for="inputPageLevel" class="col-sm-3 col-form-label">页面级别:</label>
    <div class="col-sm-9">{{ range $item := .Other.fl_pagelevel }}
<input class="form-check-input" id="fl_{{$item.which}}" type=checkbox name=fl_pagelevel value="{{$item.which}}" {{if $item.selected}}checked{{end}} />{{$item.label}}{{end}}
    </div>
</div>

<div class="form-group row">
    <label for="inputClock" class="col-sm-3 col-form-label">页面方向:</label>
    <div class="col-sm-9">{{ range $item := .Other.fl_clock }}
<input class="form-check-input" id="fl_{{$item.which}}" type=checkbox name=fl_clock value="{{$item.which}}" {{if $item.selected}}checked{{end}} />{{$item.label}}{{end}}
    </div>
</div>

<div class="form-group row">
    <label for="inputYaxis" class="col-sm-3 col-form-label">上下位置:</label>
    <div class="col-sm-9">{{ range $item := .Other.fl_yaxis }}
<input class="form-check-input" id="fl_{{$item.which}}" type=checkbox name=fl_yaxis value="{{$item.which}}" {{if $item.selected}}checked{{end}} />{{$item.label}}{{end}}
    </div>
</div>

	</div>
</div>

<div class="form-group row">
    <div class="col-sm-9">
<button type="submit" class="btn btn-primary">保存！</button>
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
