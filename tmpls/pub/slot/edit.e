{{ template "header" .}}
{{ template "slotheader" .}}

{{$attach := print "site_id=" (index .ARGS.site_id 0) "&site_md5=" (index .ARGS.site_md5 0) "&site_name=" (index .ARGS.site_name 0 | urlquery)}}
{{$item := index .Lists 0}}
{{$first := print "slot_id=" $item.slot_id "&slot_md5=" $item.slot_md5 "&slot_name=" ($item.slot_name | urlquery)}}

          <div class="card">
            <div class="card-header">
              Edit Slot of <em>{{(index .ARGS.site_name 0)}}</em>
            </div>
            <div class="card-body">

<form class="form" action="slot" method=post>
<input type=hidden name="action" value="update" />
<input type=hidden name="slot_id"   value="{{$item.slot_id}}" />
<input type=hidden name="site_id"   value="{{index .ARGS.site_id 0}}" />
<input type=hidden name="site_md5"  value="{{index .ARGS.site_md5 0}}" />
<input type=hidden name="site_name" value="{{index .ARGS.site_name 0}}" />

<div class="form-group row">
    <label for="inputSlotName" class="col-sm-2 col-form-label text-right">Slot Name:</label>
    <div class="col-sm-4">
        <input type=text class="form-control" name="slot_name" value="{{$item.slot_name}}" />
    </div>
    <label for="inputSizeID" class="col-sm-2 col-form-label text-right">Size:</label>
    <div class="col-sm-2">
        <input type=text class="form-control" name="w" value="{{$item.w}}" />
    </div>
    <div class="col-sm-2">
        <input type=text class="form-control" name="h" value="{{$item.w}}" />
    </div>
</div>

<div class="form-group row">
    <label for="inputType" class="col-sm-2 col-form-label text-right">Mime Accepted:</label>
    <div class="col-sm-10 col-form-label">{{ range $one := .Other.fl_mime }}
      <div class="form-check form-check-inline mr-1">
        <input class="form-check-input" type="checkbox" value="{{$one.which}}" name="fl_mime" {{if $one.selected}}checked{{end}}>
        <label class="form-check-label" for="inline-radio1">{{$one.label}}</label>
      </div>{{end}}
    </div>
</div>

<div class="form-group row">
    <label for="inputPlatform" class="col-sm-2 col-form-label text-right">Platform:</label>
    <div class="col-sm-10 col-form-label">{{ range $one := .Other.qa_platform }}
      <div class="form-check form-check-inline mr-1">
        <input class="form-check-input" type="radio" id="qa_{{$one.which}}" value="{{$one.which}}" name="qa_platform" {{if $one.selected}}checked{{end}}>
        <label class="form-check-label" for="inline-radio1">{{$one.label}}</label>
      </div>{{end}}
    </div>
</div>

<div class="form-group row">
    <label for="inputPageLevel" class="col-sm-2 col-form-label text-right">Page Level:</label>
    <div class="col-sm-10 col-form-label">{{ range $one := .Other.qa_pagelevel }}
		<div class="form-check form-check-inline mr-1">
           <input class="form-check-input" id="qa_{{$one.which}}" type=radio name=qa_pagelevel value="{{$one.which}}" {{if $one.selected }}checked{{end}} >
           <label class="form-check-label" for="inline-radio1">{{$one.label}}</label>
        </div>{{end}}
    </div>
</div>

<div class="form-group row">
    <label for="inputClock" class="col-sm-2 col-form-label text-right">Clock:</label>
    <div class="col-sm-10 col-form-label">{{ range $one := .Other.qa_clock }}
		<div class="form-check form-check-inline mr-1">
           <input class="form-check-input" id="qa_{{$one.which}}" type=radio name=qa_clock value="{{$one.which}}" {{if $one.selected }}checked{{end}} >
           <label class="form-check-label" for="inline-radio1">{{$one.label}}</label>
        </div>{{end}}
    </div>
</div>

<div class="form-group row">
    <label for="inputYaxis" class="col-sm-2 col-form-label text-right">Yaxis:</label>
    <div class="col-sm-10">{{ range $one := .Other.qa_yaxis }}
        <div class="form-check form-check-inline mr-1">
           <input class="form-check-input" id="qa_{{$one.which}}" type=radio name=qa_yaxis value="{{$one.which}}" {{if $one.selected }}checked{{end}} >
           <label>{{$one.label}}</label>
        </div>{{end}}
    </div>
</div>

<div class="form-group row">
    <label for="checkChannels" class="col-sm-2 col-form-label text-right">Channels:</label>
    <div class="col-sm-10">
<table class="table table-sm table-condensed table-bordered">
<tr>
<th></th>
<th>My Channel<br />
<input type=radio id="ch_inherit" name=mychannel {{if eq $item.mychannel "Inherit"}}checked{{end}}  value="Inherit" />Inherit
<input type=radio id="ch_own"     name=mychannel {{if eq $item.mychannel "Own"}}checked{{end}} value="Own" />Own</th>
<th>Access Control<br>
<input type=radio id="ac_inherit" name=channel_order {{if eq $item.channel_order "Inherit"}}checked{{end}} value="Inherit" />Inherit
<input type=radio id="ac_black" name=channel_order {{if eq $item.channel_order "Black"}}checked{{end}} value="Black" />Black
<input type=radio id="ac_white" name=channel_order {{if eq $item.channel_order "White"}}checked{{end}} value="White" />White
</th>
</tr>
<tbody>{{ with $item.chac_topics }}{{ range . }}
<tr><td>{{.channel_name}}</td>
<td class="text-center"><input name=belong_ids {{if .chbelong_id}}checked{{end}} type=checkbox value="{{.channel_id}}" /></td>
<td class="text-center"><input name=ac_ids {{if .chac_id}}checked{{end}} type=checkbox value="{{.channel_id}}" /></td>
</tr>{{end}}{{end}}
</tobdy>
</table>
    </div>
</div>


<div class="form-group row">
    <div class="col-sm-2">
	</div>
    <div class="col-sm-10">
<button type="submit" class="btn btn-primary">Save and Update</button>
    </div>
</div>

</form>

        </div>
      </div>

{{ template "footer" .}}
<script>
$(document).ready(function(){
    {{if eq $item.mychannel "Inherit"}}$("input[name='belong_ids']").hide(){{end}}
    {{if eq $item.channel_order "Inherit"}}$("input[name='ac_ids']").hide(){{end}}
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

