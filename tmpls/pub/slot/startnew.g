<form class="form" action="slot" method=post>
<input type=hidden name="action" value="insert" />
<input type=hidden name="site_id"   value="{{index .ARGS.site_id 0}}" />
<input type=hidden name="site_md5"  value="{{index .ARGS.site_md5 0}}" />
<input type=hidden name="site_name" value="{{index .ARGS.site_name 0}}" />
<input type=hidden name="qa_language" value="Chinese" />

<div class="form-group row">
    <label for="inputSlotName" class="col-sm-3 col-form-label text-right">广告位名称:</label>
    <div class="col-sm-3">
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
    <label for="inputPlatform" class="col-sm-3 col-form-label text-right">设备平台:</label>
    <div class="col-sm-9 col-form-label">广告位在何种硬件设备上？</div>
    <label class="col-sm-3 col-form-label text-right"></label>
    <div class="col-sm-9 col-form-label">{{ range $item := .Other.qa_device }}
      <div class="form-check form-check-inline mr-1">
        <input class="form-check-input" type="radio" id="qa_{{$item.which}}" value="{{$item.which}}" name="qa_device" {{if $item.default}}checked{{end}}>
        <label class="form-check-label" for="inline-radio1">{{$item.label_chinese}}</label>
      </div>{{end}}
    </div>
</div>

<div class="form-group row">
    <label for="inputPageLevel" class="col-sm-3 col-form-label text-right">广告位位置:</label>
    <div class="col-sm-9 col-form-label">广告位在屏幕上的位置？</div>
    <label class="col-sm-3 col-form-label text-right"></label>
    <div class="col-sm-9 col-form-label">{{ range $item := .Other.qa_position }}
		<div class="form-check form-check-inline mr-1">
           <input class="form-check-input" id="qa_{{$item.which}}" type=radio name=qa_position value="{{$item.which}}" {{if $item.default}}checked{{end}} >
           <label class="form-check-label" for="inline-radio1">{{$item.label_chinese}}</label>
        </div>{{end}}
    </div>
</div>

<div class="form-group row">
    <label for="inputClock" class="col-sm-3 col-form-label text-right">周边内容:</label>
    <div class="col-sm-9 col-form-label">所属内容，或者周边为何种环境？</div>
    <label class="col-sm-3 col-form-label text-right"></label>
    <div class="col-sm-9 col-form-label">{{ range $item := .Other.qa_content }}
		<div class="form-check form-check-inline mr-1">
           <input class="form-check-input" id="qa_{{$item.which}}" type=radio name=qa_content value="{{$item.which}}" {{if $item.default}}checked{{end}} >
           <label class="form-check-label" for="inline-radio1">{{$item.label_chinese}}</label>
        </div>{{end}}
    </div>
</div>

<div class="form-group row">
    <label for="inputType" class="col-sm-3 col-form-label text-right">可接受广告MIME:</label>
    <div class="col-sm-9 col-form-label">所能接受的各种广告MIME类。多选</div>
    <label class="col-sm-3 col-form-label text-right"></label>
    <div class="col-sm-9 col-form-label">{{ range $item := .Other.fl_mime }}
        <div class="form-check form-check-inline mr-1">
        <input type=checkbox class="form-check-input" name="fl_mime" value="{{$item.which}}" {{if $item.default}}checked{{end}}>
        <label class="form-check-label" for="inline-radio1">{{$item.label_chinese}}</label>
        </div>{{end}}
    </div>
</div>

<div class="form-group row">
    <label for="inputYaxis" class="col-sm-3 col-form-label text-right">可接受广告形式:</label>
    <div class="col-sm-9">所能接受的各种广告形式。多选。如果不接受特殊形式，选普通类即可</div>
    <label class="col-sm-3 col-form-label text-right"></label>
    <div class="col-sm-9">{{ range $item := .Other.fl_creative }}
        <div class="form-check form-check-inline mr-1">
           <input class="form-check-input" id="fl_{{$item.which}}" type=checkbox name=fl_creative value="{{$item.which}}" {{if $item.default}}checked{{end}} >
           <label>{{$item.label_chinese}}</label>
        </div>{{end}}
    </div>
</div>

<div class="form-group row">
    <div class="col-sm-3">
	</div>
    <div class="col-sm-9">
<button type="submit" class="btn btn-primary">填增广告位!</button>
    </div>
</div>

</form>
