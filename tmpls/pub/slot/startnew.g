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
<input type=hidden name="qa_language" value="Chinese" />

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
    <label for="inputPlatform" class="col-sm-2 col-form-label text-right">所在平台:</label>
    <div class="col-sm-10 col-form-label">{{ range $item := .Other.qa_platform }}
      <div class="form-check form-check-inline mr-1">
        <input class="form-check-input" type="radio" id="qa_{{$item.which}}" value="{{$item.which}}" name="qa_platform" {{if eq "Web" $item.which}}checked{{end}}>
        <label class="form-check-label" for="inline-radio1">{{$item.label_chinese}}</label>
      </div>{{end}}
    </div>
</div>

<div class="form-group row">
    <label for="inputType" class="col-sm-2 col-form-label text-right">可投放类:</label>
    <div class="col-sm-10 col-form-label">{{ range $item := .Other.fl_mime }}
        <div class="form-check form-check-inline mr-1">
        <input type=checkbox class="form-check-input" name="fl_mime" value="{{$item.which}}" {{if $item.default}}checked{{end}}>
        <label class="form-check-label" for="inline-radio1">{{$item.label_chinese}}</label>
        </div>{{end}}
    </div>
</div>

<div class="form-group row">
    <label for="inputPageLevel" class="col-sm-2 col-form-label text-right">前后等级:</label>
    <div class="col-sm-10 col-form-label">{{ range $item := .Other.qa_pagelevel }}
		<div class="form-check form-check-inline mr-1">
           <input class="form-check-input" id="qa_{{$item.which}}" type=radio name=qa_pagelevel value="{{$item.which}}" {{if $item.default}}checked{{end}} >
           <label class="form-check-label" for="inline-radio1">{{$item.label_chinese}}</label>
        </div>{{end}}
    </div>
</div>

<div class="form-group row">
    <label for="inputClock" class="col-sm-2 col-form-label text-right">时钟位置:</label>
    <div class="col-sm-10 col-form-label">{{ range $item := .Other.qa_clock }}
		<div class="form-check form-check-inline mr-1">
           <input class="form-check-input" id="qa_{{$item.which}}" type=radio name=qa_clock value="{{$item.which}}" {{if $item.default}}checked{{end}} >
           <label class="form-check-label" for="inline-radio1">{{$item.label_chinese}}</label>
        </div>{{end}}
    </div>
</div>

<div class="form-group row">
    <label for="inputYaxis" class="col-sm-2 col-form-label text-right">上下位置:</label>
    <div class="col-sm-10">{{ range $item := .Other.qa_yaxis }}
        <div class="form-check form-check-inline mr-1">
           <input class="form-check-input" id="qa_{{$item.which}}" type=radio name=qa_yaxis value="{{$item.which}}" {{if $item.default}}checked{{end}} >
           <label>{{$item.label_chinese}}</label>
        </div>{{end}}
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


</body>
</html>

