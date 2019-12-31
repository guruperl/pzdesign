{{ template "header" .}}
{{ template "slotheader" .}}

          <div class="card">
            <div class="card-header">
              Create New Slot
            </div>
            <div class="card-body">

<form class="form" action="slot" method=post>
<input type=hidden name="action" value="insert" />
<input type=hidden name="site_id"   value="{{index .ARGS.site_id 0}}" />
<input type=hidden name="site_md5"  value="{{index .ARGS.site_md5 0}}" />
<input type=hidden name="site_name" value="{{index .ARGS.site_name 0}}" />

<div class="form-group row">
    <label for="inputSlotName" class="col-sm-2 col-form-label text-right">Slot Name:</label>
    <div class="col-sm-4">
        <input type=text class="form-control" name="slot_name" placeholder="Name of Slot" />
    </div>
    <label for="inputSizeID" class="col-sm-2 col-form-label text-right">Size:</label>
    <div class="col-sm-2">
        <input type=text class="form-control" name="w" placeholder="width" />
    </div>
    <div class="col-sm-2">
        <input type=text class="form-control" name="h" placeholder="height" />
    </div>
</div>

<div class="form-group row">
    <label for="inputType" class="col-sm-2 col-form-label text-right">Mime Accepted:</label>
    <div class="col-sm-10 col-form-label">{{ range $item := .Other.fl_mime }}
		<div class="form-check form-check-inline mr-1">
        <input type=checkbox class="form-check-input" name="fl_mime" value="{{$item.which}}" {{if $item.default}}checked{{end}}>
		<label class="form-check-label" for="inline-radio1">{{$item.label}}</label>
		</div>{{end}}
    </div>
</div>

<input type=hidden name="qa_language" value="Chinese" />

<div class="form-group row">
    <label for="inputPlatform" class="col-sm-2 col-form-label text-right">Platform:</label>
    <div class="col-sm-10 col-form-label">{{ range $item := .Other.qa_device }}
      <div class="form-check form-check-inline mr-1">
        <input class="form-check-input" type="radio" id="qa_{{$item.which}}" value="{{$item.which}}" name="qa_device" {{if $item.default}}checked{{end}}>
        <label class="form-check-label" for="inline-radio1">{{$item.label}}</label>
      </div>{{end}}
    </div>
</div>

<div class="form-group row">
    <label for="inputPageLevel" class="col-sm-2 col-form-label text-right">Page Level:</label>
    <div class="col-sm-10 col-form-label">{{ range $item := .Other.qa_position }}
		<div class="form-check form-check-inline mr-1">
           <input class="form-check-input" id="qa_{{$item.which}}" type=radio name=qa_position value="{{$item.which}}" {{if $item.default}}checked{{end}} >
           <label class="form-check-label" for="inline-radio1">{{$item.label}}</label>
        </div>{{end}}
    </div>
</div>

<div class="form-group row">
    <label for="inputClock" class="col-sm-2 col-form-label text-right">Clock:</label>
    <div class="col-sm-10 col-form-label">{{ range $item := .Other.qa_content }}
		<div class="form-check form-check-inline mr-1">
           <input class="form-check-input" id="qa_{{$item.which}}" type=radio name=qa_content value="{{$item.which}}" {{if $item.default}}checked{{end}} >
           <label class="form-check-label" for="inline-radio1">{{$item.label}}</label>
        </div>{{end}}
    </div>
</div>

<div class="form-group row">
    <label for="inputYaxis" class="col-sm-2 col-form-label text-right">Yaxis:</label>
    <div class="col-sm-10">{{ range $item := .Other.qa_creative }}
        <div class="form-check form-check-inline mr-1">
           <input class="form-check-input" id="qa_{{$item.which}}" type=radio name=qa_creative value="{{$item.which}}" {{if $item.default}}checked{{end}} >
           <label>{{$item.label}}</label>
        </div>{{end}}
    </div>
</div>

<div class="form-group row">
    <div class="col-sm-2">
	</div>
    <div class="col-sm-10">
<button type="submit" class="btn btn-primary">Create Slot!</button>
    </div>
</div>

</form>

        </div>
      </div>

{{ template "footer" .}}


</body>
</html>

