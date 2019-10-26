{{ template "header" .}}
{{ template "slotheader" .}}

{{$attach := print "site_id=" (index .ARGS.site_id 0) "&site_md5=" (index .ARGS.site_md5 0) "&site_name=" (index .ARGS.site_name 0 | urlquery)}}
{{$item := index .Lists 0}}
{{$first := print "slot_id=" $item.slot_id "&slot_md5=" $item.slot_md5 "&slot_name=" ($item.slot_name | urlquery)}}

          <div class="card">
            <div class="card-header">
              编辑修改此广告位 <em>{{(index .ARGS.slot_name 0)}}</em>
            </div>
            <div class="card-body">

<form class="form" action="slot" method=post>
<input type=hidden name="action" value="update" />
<input type=hidden name="slot_id"   value="{{$item.slot_id}}" />
<input type=hidden name="site_id"   value="{{index .ARGS.site_id 0}}" />
<input type=hidden name="site_md5"  value="{{index .ARGS.site_md5 0}}" />
<input type=hidden name="site_name" value="{{index .ARGS.site_name 0}}" />

<div class="form-group row">
    <label for="inputSlotName" class="col-sm-2 col-form-label text-right">广告位名称:</label>
    <div class="col-sm-4">
        <input type=text class="form-control" name="slot_name" value="{{$item.slot_name}}" />
    </div>
    <label for="inputSizeID" class="col-sm-2 col-form-label text-right">尺寸:</label>
    <div class="col-sm-2">
        <input type=text class="form-control" name="w" value="{{$item.w}}" />
    </div>
    <div class="col-sm-2">
        <input type=text class="form-control" name="h" value="{{$item.h}}" />
    </div>
</div>

<div class="form-group row">
    <label for="inputPlatform" class="col-sm-2 col-form-label text-right">所在平台:</label>
    <div class="col-sm-10 col-form-label">{{ range $one := .Other.qa_platform }}
      <div class="form-check form-check-inline mr-1">
        <input class="form-check-input" type="radio" id="qa_{{$one.which}}" value="{{$one.which}}" name="qa_platform" {{if $one.selected}}checked{{end}}>
        <label class="form-check-label" for="inline-radio1">{{$one.label_chinese}}</label>
      </div>{{end}}
    </div>
</div>

<div class="form-group row">
    <label for="inputType" class="col-sm-2 col-form-label text-right">可投放类:</label>
    <div class="col-sm-10 col-form-label">{{ range $one := .Other.fl_mime }}
      <div class="form-check form-check-inline mr-1">
        <input class="form-check-input" type="checkbox" value="{{$one.which}}" name="fl_mime" {{if $one.selected}}checked{{end}}>
        <label class="form-check-label" for="inline-radio1">{{$one.label_chinese}}</label>
      </div>{{end}}
    </div>
</div>

<div class="form-group row">
    <label for="inputPageLevel" class="col-sm-2 col-form-label text-right">前后级别:</label>
    <div class="col-sm-10 col-form-label">{{ range $one := .Other.qa_pagelevel }}
		<div class="form-check form-check-inline mr-1">
           <input class="form-check-input" id="qa_{{$one.which}}" type=radio name=qa_pagelevel value="{{$one.which}}" {{if $one.selected }}checked{{end}} >
           <label class="form-check-label" for="inline-radio1">{{$one.label_chinese}}</label>
        </div>{{end}}
    </div>
</div>

<div class="form-group row">
    <label for="inputClock" class="col-sm-2 col-form-label text-right">时钟位置:</label>
    <div class="col-sm-10 col-form-label">{{ range $one := .Other.qa_clock }}
		<div class="form-check form-check-inline mr-1">
           <input class="form-check-input" id="qa_{{$one.which}}" type=radio name=qa_clock value="{{$one.which}}" {{if $one.selected }}checked{{end}} >
           <label class="form-check-label" for="inline-radio1">{{$one.label_chinese}}</label>
        </div>{{end}}
    </div>
</div>

<div class="form-group row">
    <label for="inputYaxis" class="col-sm-2 col-form-label text-right">上下位置:</label>
    <div class="col-sm-10">{{ range $one := .Other.qa_yaxis }}
        <div class="form-check form-check-inline mr-1">
           <input class="form-check-input" id="qa_{{$one.which}}" type=radio name=qa_yaxis value="{{$one.which}}" {{if $one.selected }}checked{{end}} >
           <label>{{$one.label_chinese}}</label>
        </div>{{end}}
    </div>
</div>

<div class="form-group row">
    <div class="col-sm-2">
	</div>
    <div class="col-sm-10">
<button type="submit" class="btn btn-primary">保存并更新</button>
    </div>
</div>

</form>

        </div>
      </div>

{{ template "footer" .}}


</body>
</html>

