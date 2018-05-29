{{ template "header" .}}
{{ template "slotheader" .}}

          <div class="card">
            <div class="card-header">
              添加广告位
            </div>
            <div class="card-body">

<form class="form" action="slot" method=post>
<input type=hidden name="action" value="insert" />
<input type=hidden name="site_id"   value="{{index .ARGS.site_id 0}}" />
<input type=hidden name="site_md5"  value="{{index .ARGS.site_md5 0}}" />
<input type=hidden name="site_name" value="{{index .ARGS.site_name 0}}" />

<div class="form-group row">
    <label for="inputSlotName" class="col-sm-3 col-form-label">广告位名称:</label>
    <div class="col-sm-9">
        <input type=text class="form-control" name="slot_name" placeholder="名称" />
    </div>
</div>

<div class="form-group row">
    <label for="inputSizeID" class="col-sm-3 col-form-label">大小:</label>
    <div class="col-sm-4">
        <select class="form-control" name="size_id">
<option value=""></option>
<option value=1>Half Banner 234x60</option>
<option value=2>Banner 468x60</option>
<option value=3>Leaderboard 728x90</option>
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
    <label for="inputEndx" class="col-sm-1 col-form-label">发布形式:</label>
    <div class="col-sm-4">
        <select class="form-control" name="fl_mime">
<option value="js">Javascript</option>
<option value="html">html</option>
<option value="json">json</option>
<option value="jpg">jpg</option>
<option value="gif">gif</option>
<option value="png">png</option>
<option value="mp4">mp4</option>
<option value="swf">swf</option>
<option value="wmv">wmv</option>
<option value="flv">flv</option></select>
    </div>
</div>

<div class="form-group row">
    <label for="inputCost" class="col-sm-12 col-form-label">属性</label>
<input type=hidden name="qa_language" value="Chinese" />
</div>

<div class="panel panel-primary">
    <div class="panel-body">

<div class="form-group row">
    <label for="inputPlatform" class="col-sm-3 col-form-label">所在媒体平台:</label>
    <div class="col-sm-9 col-form-label">{{ range $item := .Other.qa_platform }}
      <div class="form-check form-check-inline mr-1">
        <input class="form-check-input" type="radio" id="qa_{{$item.which}}" value="{{$item.which}}" name="qa_platform" {{if eq "Web" $item.which}}checked{{end}}>
        <label class="form-check-label" for="inline-radio1">{{$item.label}}</label>
      </div>{{end}}
    </div>
</div>

<div class="form-group row">
    <label for="inputPageLevel" class="col-sm-3 col-form-label">页面等级:</label>
    <div class="col-sm-9 col-form-label">{{ range $item := .Other.qa_pagelevel }}
		<div class="form-check form-check-inline mr-1">
           <input class="form-check-input" id="qa_{{$item.which}}" type=radio name=qa_pagelevel value="{{$item.which}}" {{if $item.default}}checked{{end}} >
           <label class="form-check-label" for="inline-radio1">{{$item.label}}</label>
        </div>{{end}}
    </div>
</div>

<div class="form-group row">
    <label for="inputClock" class="col-sm-3 col-form-label">时钟位置:</label>
    <div class="col-sm-9 col-form-label">{{ range $item := .Other.qa_clock }}
		<div class="form-check form-check-inline mr-1">
           <input class="form-check-input" id="qa_{{$item.which}}" type=radio name=qa_clock value="{{$item.which}}" {{if $item.default}}checked{{end}} >
           <label class="form-check-label" for="inline-radio1">{{$item.label}}</label>
        </div>{{end}}
    </div>
</div>

<div class="form-group row">
    <label for="inputYaxis" class="col-sm-3 col-form-label">上下位置:</label>
    <div class="col-sm-9">{{ range $item := .Other.qa_yaxis }}
        <div class="form-check form-check-inline mr-1">
           <input class="form-check-input" id="qa_{{$item.which}}" type=radio name=qa_yaxis value="{{$item.which}}" {{if $item.default}}checked{{end}} >
           <label>{{$item.label}}</label>
        </div>{{end}}
    </div>
</div>

<div class="form-group row">
    <label for="checkChannels" class="col-sm-3 col-form-label">业务类别:</label>
    <div class="col-sm-9">
<table class="table table-sm table-bordered">
<tr>
<th></th>
<th>本属<br />
<input type=radio id="ch_inherit" name=mychannel checked value="Inherit" />默认
<input type=radio id="ch_own"     name=mychannel value="Own" />自定义</th>
<th>接受广告业务<br>
<input type=radio id="ac_inherit" name=channel_order checked value="Inherit" />默认
<input type=radio id="ac_black" name=channel_order value="Black" />黑
<input type=radio id="ac_white" name=channel_order value="White" />白 
</th>
</tr>
<tbody>{{ with .Other.channel_topics }}{{ range . }}
<tr><td>{{.channel_name}}</td>
<td class="text-center"><input name=belong_ids type=checkbox value="{{.channel_id}}" /></td>
<td class="text-center"><input name=ac_ids type=checkbox value="{{.channel_id}}" /></td>
</tr>{{end}}{{end}}
</tobdy>
</table>
    </div>
</div>


    </div>
</div>

<div class="form-group row">
    <div class="col-sm-9">
<button type="submit" class="btn btn-primary">新建广告位!</button>
    </div>
</div>

</form>

        </div>
      </div>

{{ template "footer" .}}
<script>
$(document).ready(function(){
	$("input[name='belong_ids']").hide()
	$("input[name='ac_ids']").hide()
    $("#ch_inherit").click(function(){
        $("input[name='belong_ids']").hide()
    });
    $("#ch_own").click(function(){
        $("input[name='belong_ids']").show()
    });
    $("#ac_inherit").click(function(){
        $("input[name='ac_ids']").hide()
    });
    $("#ac_black").click(function(){
        $("input[name='ac_ids']").show()
    });
    $("#ac_white").click(function(){
        $("input[name='ac_ids']").show()
    });
});
</script>


</body>
</html>

