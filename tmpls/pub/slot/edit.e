{{ template "header" .}}
{{ template "slotheader" .}}

{{$attach := print "site_id=" (index .ARGS.site_id 0) "&site_md5=" (index .ARGS.site_md5 0) "&site_name=" (index .ARGS.site_name 0 | urlquery)}}
{{$item := index .Lists 0}}
{{$first := print "slot_id=" $item.slot_id "&slot_md5=" $item.slot_md5 "&slot_name=" ($item.slot_name | urlquery)}}

          <div class="card">
            <div class="card-header">
              Edit Slot of <em>{{(index .ARGS.site_name 0 | urlquery)}}</em>
            </div>
            <div class="card-body">

<form class="form" action="slot" method=post>
<input type=hidden name="action" value="update" />
<input type=hidden name="slot_id"   value="{{$item.slot_id}}" />
<input type=hidden name="site_id"   value="{{index .ARGS.site_id 0}}" />
<input type=hidden name="site_md5"  value="{{index .ARGS.site_md5 0}}" />
<input type=hidden name="site_name" value="{{index .ARGS.site_name 0}}" />

<div class="form-group row">
    <label for="inputSlotName" class="col-sm-3 col-form-label">Slot Name:</label>
    <div class="col-sm-9">
        <input type=text class="form-control" name="slot_name" value="{{$item.slot_name}}" />
    </div>
</div>

<div class="form-group row">
    <label for="inputSizeID" class="col-sm-3 col-form-label">Size:</label>
    <div class="col-sm-4">
        <select class="form-control" name="size_id">
<option value=""></option>
<option {{if eq $item.size_id 1}}selected{{end}} value=1>Half Banner 234x60</option>
<option {{if eq $item.size_id 2}}selected{{end}} value=2>Banner 468x60</option>
<option {{if eq $item.size_id 3}}selected{{end}} value=3>Leaderboard 728x90</option>
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
    <label for="inputEndx" class="col-sm-1 col-form-label">Type:</label>
    <div class="col-sm-4">
        <select class="form-control" name="fl_mime">
<option {{if eq $item.fl_mime "js"}}selected{{end}} value="js">Javascript</option>
<option {{if eq $item.fl_mime "html"}}selected{{end}} value="html">html</option>
<option {{if eq $item.fl_mime "json"}}selected{{end}} value="json">json</option>
<option {{if eq $item.fl_mime "jpg"}}selected{{end}} value="jpg">jpg</option>
<option {{if eq $item.fl_mime "git"}}selected{{end}} value="gif">gif</option>
<option {{if eq $item.fl_mime "png"}}selected{{end}} value="png">png</option>
<option {{if eq $item.fl_mime "mp4"}}selected{{end}} value="mp4">mp4</option>
<option {{if eq $item.fl_mime "swf"}}selected{{end}} value="swf">swf</option>
<option {{if eq $item.fl_mime "wmv"}}selected{{end}} value="wmv">wmv</option>
<option {{if eq $item.fl_mime "flv"}}selected{{end}} value="flv">flv</option></select>
    </div>
</div>

<div class="form-group row">
    <label for="inputCost" class="col-sm-12 col-form-label">Slot Properties</label>
</div>

<div class="panel panel-primary">
    <div class="panel-body">

<div class="form-group row">
    <label for="inputPlatform" class="col-sm-3 col-form-label">Platform:</label>
    <div class="col-sm-9 col-form-label">{{ range $one := .Other.qa_platform }}
      <div class="form-check form-check-inline mr-1">
        <input class="form-check-input" type="radio" id="qa_{{$one.which}}" value="{{$one.which}}" name="qa_platform" {{if $one.selected}}checked{{end}}>
        <label class="form-check-label" for="inline-radio1">{{$one.label}}</label>
      </div>{{end}}
    </div>
</div>

<div class="form-group row">
    <label for="inputPageLevel" class="col-sm-3 col-form-label">Page Level:</label>
    <div class="col-sm-9 col-form-label">{{ range $one := .Other.qa_pagelevel }}
		<div class="form-check form-check-inline mr-1">
           <input class="form-check-input" id="qa_{{$one.which}}" type=radio name=qa_pagelevel value="{{$one.which}}" {{if $one.selected }}checked{{end}} >
           <label class="form-check-label" for="inline-radio1">{{$one.label}}</label>
        </div>{{end}}
    </div>
</div>

<div class="form-group row">
    <label for="inputClock" class="col-sm-3 col-form-label">Clock:</label>
    <div class="col-sm-9 col-form-label">{{ range $one := .Other.qa_clock }}
		<div class="form-check form-check-inline mr-1">
           <input class="form-check-input" id="qa_{{$one.which}}" type=radio name=qa_clock value="{{$one.which}}" {{if $one.selected }}checked{{end}} >
           <label class="form-check-label" for="inline-radio1">{{$one.label}}</label>
        </div>{{end}}
    </div>
</div>

<div class="form-group row">
    <label for="inputYaxis" class="col-sm-3 col-form-label">Yaxis:</label>
    <div class="col-sm-9">{{ range $one := .Other.qa_yaxis }}
        <div class="form-check form-check-inline mr-1">
           <input class="form-check-input" id="qa_{{$one.which}}" type=radio name=qa_yaxis value="{{$one.which}}" {{if $one.selected }}checked{{end}} >
           <label>{{$one.label}}</label>
        </div>{{end}}
    </div>
</div>

<div class="form-group row">
    <label for="checkChannels" class="col-sm-3 col-form-label">Channels:</label>
    <div class="col-sm-9">
<table class="table table-sm table-bordered">
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


    </div>
</div>

<div class="form-group row">
    <div class="col-sm-9">
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

