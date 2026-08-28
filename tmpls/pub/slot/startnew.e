{{$cAttrs := .Other.itemAttrs }}
{{$sAttrs := .Other.slotAttrs }}
{{$cDefault := .Other.itemsDefault }}
{{$sDefault := .Other.slotsDefault }}


<form class="form" action="slot" method=post>
<input type=hidden name="action" value="insert" />
<input type=hidden name="site_id"   value="{{index .ARGS.site_id 0}}" />
<input type=hidden name="site_md5"  value="{{index .ARGS.site_md5 0}}" />
<input type=hidden name="site_name" value="{{index .ARGS.site_name 0}}" />
<input type=hidden name="site_type" value="{{index .ARGS.site_type 0}}" />

<div class="form-group row">
    <label for="inputSlotName" class="col-sm-3 col-form-label text-right">Ad Slot Name:</label>
    <div class="col-sm-3">
        <input type=text class="form-control" name="slot_name" placeholder="Name" />
    </div>
    <label for="inputSizeID" class="col-sm-2 col-form-label text-right">Size:</label>
    <div class="col-sm-2">
        <input type=text class="form-control" name="w" value="64" />
    </div>
    <div class="col-sm-2">
        <input type=text class="form-control" name="h" value="64" />
    </div>
</div>

<div class="card mb-3"><div class="card-header">Ad Slot Classification and Quality</div><div class="card-body">
<div class="form-group row">
  <label class="col-sm-2 col-form-label text-right">Media Format:</label><div class="col-sm-4"><select class="form-control" name="media_intent"><option value="Unknown">Pending Classification</option><option value="Banner">Display</option><option value="Video">Video</option><option value="Native">Native</option><option value="Audio">Audio</option><option value="Multi">Multi-format</option></select></div>
  <label class="col-sm-2 col-form-label text-right">Placement:</label><div class="col-sm-4"><select class="form-control" name="placement"><option value="Unknown">Pending Classification</option><option value="AboveFold">Above the Fold</option><option value="InFeed">In-feed</option><option value="Interstitial">Interstitial</option><option value="Rewarded">Rewarded</option><option value="Sticky">Sticky</option><option value="Popup">Popup</option><option value="Other">Other</option></select></div>
</div>
<div class="form-group row">
  <label class="col-sm-2 col-form-label text-right">Render Context:</label><div class="col-sm-4"><select class="form-control" name="render_context"><option value="Unknown">Pending Classification</option><option value="WebPage">Web Page</option><option value="InApp">In App</option><option value="Player">Player</option><option value="Fullscreen">Full Screen</option><option value="Other">Other</option></select></div>
  <label class="col-sm-2 col-form-label text-right">Refresh:</label><div class="col-sm-2"><select class="form-control" name="refresh_mode"><option value="Unknown">Pending Classification</option><option value="None">No Refresh</option><option value="Timed">Timed</option><option value="Event">Event-triggered</option></select></div><div class="col-sm-2"><input class="form-control" type="number" name="refresh_seconds" value="0" min="0" max="3600" aria-label="Refresh interval in seconds" /></div>
</div>
<div class="form-group row">
  <label class="col-sm-2 col-form-label text-right">Ad Density:</label><div class="col-sm-2"><select class="form-control" name="ad_density"><option value="Unknown">Pending Classification</option><option value="Low">Low</option><option value="Standard">Standard</option><option value="High">High</option></select></div>
  <label class="col-sm-2 col-form-label text-right">Traffic Quality:</label><div class="col-sm-2"><select class="form-control" name="traffic_quality"><option value="Unknown">Pending Classification</option><option value="Reviewed">Manually Reviewed</option><option value="Sampled">Sampled</option><option value="Suspicious">Suspicious</option><option value="Blocked">Blocked</option></select></div>
  <label class="col-sm-2 col-form-label text-right">Traffic Source Quality:</label><div class="col-sm-2"><select class="form-control" name="source_quality"><option value="Unknown">Pending Classification</option><option value="OwnedOperated">Owned and Operated</option><option value="Partner">Partner</option><option value="Network">Publisher Network</option><option value="Resale">Resale</option></select></div>
</div>
<div class="form-group row mb-0"><label class="col-sm-2 col-form-label text-right">Management Responsibility:</label><div class="col-sm-4"><select class="form-control" name="management_control"><option value="Unknown">Pending Classification</option><option value="Publisher">Publisher-managed</option><option value="Operator">Platform-managed</option><option value="Partner">Partner-managed</option></select></div><div class="col-sm-6 text-muted">Timed refresh requires 15–3600 seconds. These fields support transparency and reporting and do not change settlement ownership.</div></div>
</div></div>

<div class="form-group row">
    <label for="inputBidFloor" class="col-sm-3 col-form-label text-right">Minimum Bid (USD CPM):</label>
    <div class="col-sm-3">
        <input id="inputBidFloor" type=number class="form-control" name="bidfloor" value="0.000000" min="0" step="0.000001" />
    </div>
    <div class="col-sm-6 col-form-label">The system always uses the higher of the configured floor and the request floor; clients cannot lower this floor.</div>
</div>

<div class="form-group row">
    <label for="inputPlatform" class="col-sm-3 col-form-label text-right">Ad Language:</label>
    <div class="col-sm-9 col-form-label">Select the advertising languages this ad slot accepts.</div>
    <label class="col-sm-3 col-form-label text-right"></label>
    <div class="col-sm-9 col-form-label">{{ range $item := .Other.qa_language }}
      <div class="form-check form-check-inline mr-1">
        <input class="form-check-input" type="radio" id="qa_{{$item.which}}" value="{{$item.which}}" name="qa_language" {{if eq $item.which "EN"}}checked{{end}}>
        <label class="form-check-label" for="inline-radio1">{{$item.label}}</label>
      </div>{{end}}
    </div>
</div>

<div class="form-group row">
    <label for="inputPlatform" class="col-sm-3 col-form-label text-right">Device Platform:</label>
    <div class="col-sm-9 col-form-label">Select the device type where this ad slot appears.</div>
    <label class="col-sm-3 col-form-label text-right"></label>
    <div class="col-sm-9 col-form-label">{{ range $item := .Other.qa_device }}
      <div class="form-check form-check-inline mr-1">
        <input class="form-check-input" type="radio" id="qa_{{$item.which}}" value="{{$item.which}}" name="qa_device" {{if eq $item.which "0"}}checked{{end}}>
        <label class="form-check-label" for="inline-radio1">{{$item.label}}</label>
      </div>{{end}}
    </div>
</div>

<div class="form-group row">
    <label for="inputPageLevel" class="col-sm-3 col-form-label text-right">Ad Slot Position:</label>
    <div class="col-sm-9 col-form-label">Select this ad slot’s position on the page or screen.</div>
    <label class="col-sm-3 col-form-label text-right"></label>
    <div class="col-sm-9 col-form-label">{{ range $item := .Other.qa_position }}
        <div class="form-check form-check-inline mr-1">
           <input class="form-check-input" id="qa_{{$item.which}}" type=radio name=qa_position value="{{$item.which}}" {{if eq $item.which "0"}}checked{{end}} >
           <label class="form-check-label" for="inline-radio1">{{$item.label}}</label>
        </div>{{end}}
    </div>
</div>

<div class="form-group row">
    <label for="inputType" class="col-sm-3 col-form-label text-right">Accepted Ad MIME Types:</label>
    <div class="col-sm-9 col-form-label">Select all that apply.</div>
    <label class="col-sm-3 col-form-label text-right"></label>
    <div class="col-sm-9 col-form-label">{{ range $item := .Other.fl_mime }}
        <div class="form-check form-check-inline mr-1">
        <input type=checkbox class="form-check-input" name="fl_mime" value="{{$item.which}}" {{if $item.default}}checked{{end}}>
        <label class="form-check-label" for="inline-radio1">{{$item.label}}</label>
        </div>{{end}}
    </div>
</div>

<div class="form-group row">
    <label for="inputYaxis" class="col-sm-3 col-form-label text-right">Accepted Creative Features:</label>
    <div class="col-sm-9">Select all that apply.</div>
    <label class="col-sm-3 col-form-label text-right"></label>
    <div class="col-sm-9">{{ range $item := .Other.fl_creative }}
        <div class="form-check form-check-inline mr-1">
           <input class="form-check-input" id="creative_{{$item.which}}" type=checkbox name=fl_creative value="{{$item.which}}" {{if $item.default}}checked{{end}} >
           <label>{{$item.label}}</label>
        </div>{{end}}
    </div>
</div>


<div class="form-group row">
    <label for="inputClock" class="col-sm-3 col-form-label text-right">Accepted Expansion Modes:</label>
    <div class="col-sm-9 col-form-label">Select all that apply.</div>
    <label class="col-sm-3 col-form-label text-right"></label>
    <div class="col-sm-9 col-form-label">{{ range $item := .Other.fl_expnd }}
        <div class="form-check form-check-inline mr-1">
           <input class="form-check-input" id="expnd_{{$item.which}}" type=checkbox name=fl_expnd value="{{$item.which}}" {{if $item.default}}checked{{end}} >
           <label class="form-check-label" for="inline-radio1">{{$item.label}}</label>
        </div>{{end}}
    </div>
</div>

<div class="form-group row">
    <label for="selectSiteQuality" class="col-sm-2 col-form-label text-right">Quality Controls:</label>
    <div class="col-sm-5">
        <div class="card">
            <div class="card-header">
                This Traffic Source’s Quality
            </div>
            <div class="card-body">
<div class="table-responsive">
<table class="table table-striped table-sm table-condensed">{{range $key, $val := .Other.slots }}{{$default := index $sDefault $key}}
<tr><td>{{index $sAttrs $key}}:</td><td><select name={{$key}}>{{range $k, $v := $val}}
<option {{if eq $k $default}}selected{{end}} value="{{$k}}">{{$v}}</option>{{end}}</td></tr>{{end}}
</table>
</div>
            </div>
        </div>
    </div>
    <div class="col-sm-5">
        <div class="card">
            <div class="card-header">
                Required Campaign Quality
            </div>
            <div class="card-body">
<div class="table-responsive">
<table class="table table-striped table-sm table-condensed">{{range $key, $val := .Other.items }}{{$default := index $cDefault $key}}
<tr><td>{{index $cAttrs $key}}:</td><td><select size=1 name={{$key}}>{{range $k, $v := $val}}
<option {{if eq $k $default}}selected{{end}} value="{{$k}}">{{$v}}</option>{{end}}</td></tr>{{end}}
</table>
</div>
            </div>
        </div>
    </div>
</div>

<div class="form-group row">
    <label for="checkChannels" class="col-sm-2 col-form-label text-right">Industry Matching:</label>
    <div class="col-sm-10">
        <div class="card">
            <div class="card-body">
<div class="table-responsive">
<table class="table table-sm table-striped table-condensed">
<thead>
<tr>
<th>Industry</th>
<th>Traffic Source Industry</th>
<th>Required Campaign Industries:
<input class="form-control-inline" type=radio name=channel_order value="Black" checked>Blocklist
<input class="form-control-inline" type=radio name=channel_order value="White">Allowlist
</th>
</tr>
</thead>
<tbody>{{ with .Other.channel_topics }}{{ range . }}
<tr><td>{{.channel_name}}</td>
<td class="text-center"><input class="form-control-inline" name=belong_ids type=checkbox value="{{.channel_id}}" /></td>
<td class="text-center"><input class="form-control-inline" name=ac_ids type=checkbox value="{{.channel_id}}" /></td>
</tr>{{end}}{{end}}
</tobdy>
</table>
</div>
            </div>
        </div>
    </div>
</div>


<div class="form-group row">
    <div class="col-sm-3">
    </div>
    <div class="col-sm-9">
<button type="submit" class="btn btn-primary">Add Ad Slot</button>
    </div>
</div>

</form>
