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
    <label for="inputSlotName" class="col-sm-2 col-form-label text-right">广告位名称:</label>
    <div class="col-sm-4">
        <input type=text class="form-control" name="slot_name" placeholder="名称" />
    </div>
    <label for="inputSizeID" class="col-sm-2 col-form-label text-right">尺寸:</label>
    <div class="col-sm-2">
        <input type=text class="form-control" name="w" placeholder="宽" />
	</div>
    <div class="col-sm-2">
        <input type=text class="form-control" name="h" placeholder="高" />
	</div>
</div>
<div class="form-group row">
    <label for="inputType" class="col-sm-2 col-form-label text-right">发布形式:</label>
    <div class="col-sm-10  col-form-label">
		<div class="form-check form-check-inline mr-1">
        <input type=checkbox checked class="form-check-input" name="fl_mime" value="js">Javascript
		</div>
		<div class="form-check form-check-inline mr-1">
        <input type=checkbox         class="form-check-input" name="fl_mime" value="html">页面
		</div>
		<div class="form-check form-check-inline mr-1">
        <input type=checkbox checked class="form-check-input" name="fl_mime" value="image">图片
		</div>
		<div class="form-check form-check-inline mr-1">
        <input type=checkbox         class="form-check-input" name="fl_mime" value="video">视频
		</div>
    </div>
</div>

<input type=hidden name="qa_language" value="Chinese" />


<div class="form-group row">
    <label for="inputPlatform" class="col-sm-2 col-form-label text-right">所在媒体平台:</label>
    <div class="col-sm-10 col-form-label">{{ range $item := .Other.qa_platform }}
      <div class="form-check form-check-inline mr-1">
        <input class="form-check-input" type="radio" id="qa_{{$item.which}}" value="{{$item.which}}" name="qa_platform" {{if eq "Web" $item.which}}checked{{end}}>
        <label class="form-check-label" for="inline-radio1">{{$item.label}}</label>
      </div>{{end}}
    </div>
</div>

<div class="form-group row">
    <label for="inputPageLevel" class="col-sm-2 col-form-label text-right">页面等级:</label>
    <div class="col-sm-10 col-form-label">{{ range $item := .Other.qa_pagelevel }}
		<div class="form-check form-check-inline mr-1">
           <input class="form-check-input" id="qa_{{$item.which}}" type=radio name=qa_pagelevel value="{{$item.which}}" {{if $item.default}}checked{{end}} >
           <label class="form-check-label" for="inline-radio1">{{$item.label}}</label>
        </div>{{end}}
    </div>
</div>

<div class="form-group row">
    <label for="inputClock" class="col-sm-2 col-form-label text-right">时钟位置:</label>
    <div class="col-sm-10 col-form-label">{{ range $item := .Other.qa_clock }}
		<div class="form-check form-check-inline mr-1">
           <input class="form-check-input" id="qa_{{$item.which}}" type=radio name=qa_clock value="{{$item.which}}" {{if $item.default}}checked{{end}} >
           <label class="form-check-label" for="inline-radio1">{{$item.label}}</label>
        </div>{{end}}
    </div>
</div>

<div class="form-group row">
    <label for="inputYaxis" class="col-sm-2 col-form-label text-right">上下位置:</label>
    <div class="col-sm-10">{{ range $item := .Other.qa_yaxis }}
        <div class="form-check form-check-inline mr-1">
           <input class="form-check-input" id="qa_{{$item.which}}" type=radio name=qa_yaxis value="{{$item.which}}" {{if $item.default}}checked{{end}} >
           <label>{{$item.label}}</label>
        </div>{{end}}
    </div>
</div>

<div class="form-group row">
    <label for="checkChannels" class="col-sm-2 col-form-label text-right">行业类别:</label>
    <div class="col-sm-10">
<table class="table table-sm table-condensed table-bordered">
<tr>
<th></th>
<th>本属<br />
<input type=radio id="ch_inherit" name=mychannel checked value="Inherit" />默认
<input type=radio id="ch_own"     name=mychannel value="Own" />自定义</th>
<th>接受行业<br>
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


<div class="form-group row">
    <div class="col-sm-2">
	</div>
    <div class="col-sm-10">
<button type="submit" class="btn btn-primary">填增广告位!</button>
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

