
{{$cAttrs := .Other.itemAttrs }}
{{$sAttrs := .Other.slotAttrs }}

{{$item := index .Lists 0}}

<form class="form" action="slot" method=post>
<input type=hidden name="action" value="update" />
<input type=hidden name="slot_id"   value="{{$item.slot_id}}" />
<input type=hidden name="site_id"   value="{{index .ARGS.site_id 0}}" />
<input type=hidden name="site_md5"  value="{{index .ARGS.site_md5 0}}" />
<input type=hidden name="site_name" value="{{index .ARGS.site_name 0}}" />
<input type=hidden name="site_type" value="{{index .ARGS.site_type 0}}" />

<div class="form-group row">
    <label for="inputSlotName" class="col-sm-3 col-form-label text-right">Ad Slot Name:</label>
    <div class="col-sm-3">
        <input type=text class="form-control" name="slot_name" value="{{$item.slot_name}}" />
    </div>
    <label for="inputSizeID" class="col-sm-2 col-form-label text-right">Size:</label>
    <div class="col-sm-2">
        <input type=text class="form-control" name="w" value="{{$item.w}}" />
    </div>
    <div class="col-sm-2">
        <input type=text class="form-control" name="h" value="{{$item.h}}" />
    </div>
</div>

<div class="card mb-3"><div class="card-header">Ad Slot Classification and Quality</div><div class="card-body">
<div class="form-group row">
  <label class="col-sm-2 col-form-label text-right">Media Format:</label><div class="col-sm-4"><select class="form-control" name="media_intent">{{$v := $item.media_intent}}<option value="Unknown" {{if eq $v "Unknown"}}selected{{end}}>Pending Classification</option><option value="Banner" {{if eq $v "Banner"}}selected{{end}}>Display</option><option value="Video" {{if eq $v "Video"}}selected{{end}}>Video</option><option value="Native" {{if eq $v "Native"}}selected{{end}}>Native</option><option value="Audio" {{if eq $v "Audio"}}selected{{end}}>Audio</option><option value="Multi" {{if eq $v "Multi"}}selected{{end}}>Multi-format</option></select></div>
  <label class="col-sm-2 col-form-label text-right">Placement:</label><div class="col-sm-4"><select class="form-control" name="placement">{{$v = $item.placement}}<option value="Unknown" {{if eq $v "Unknown"}}selected{{end}}>Pending Classification</option><option value="AboveFold" {{if eq $v "AboveFold"}}selected{{end}}>Above the Fold</option><option value="InFeed" {{if eq $v "InFeed"}}selected{{end}}>In-feed</option><option value="Interstitial" {{if eq $v "Interstitial"}}selected{{end}}>Interstitial</option><option value="Rewarded" {{if eq $v "Rewarded"}}selected{{end}}>Rewarded</option><option value="Sticky" {{if eq $v "Sticky"}}selected{{end}}>Sticky</option><option value="Popup" {{if eq $v "Popup"}}selected{{end}}>Popup</option><option value="Other" {{if eq $v "Other"}}selected{{end}}>Other</option></select></div>
</div>
<div class="form-group row">
  <label class="col-sm-2 col-form-label text-right">Render Context:</label><div class="col-sm-4"><select class="form-control" name="render_context">{{$v = $item.render_context}}<option value="Unknown" {{if eq $v "Unknown"}}selected{{end}}>Pending Classification</option><option value="WebPage" {{if eq $v "WebPage"}}selected{{end}}>Web Page</option><option value="InApp" {{if eq $v "InApp"}}selected{{end}}>In App</option><option value="Player" {{if eq $v "Player"}}selected{{end}}>Player</option><option value="Fullscreen" {{if eq $v "Fullscreen"}}selected{{end}}>Full Screen</option><option value="Other" {{if eq $v "Other"}}selected{{end}}>Other</option></select></div>
  <label class="col-sm-2 col-form-label text-right">Refresh:</label><div class="col-sm-2"><select class="form-control" name="refresh_mode">{{$v = $item.refresh_mode}}<option value="Unknown" {{if eq $v "Unknown"}}selected{{end}}>Pending Classification</option><option value="None" {{if eq $v "None"}}selected{{end}}>No Refresh</option><option value="Timed" {{if eq $v "Timed"}}selected{{end}}>Timed</option><option value="Event" {{if eq $v "Event"}}selected{{end}}>Event-triggered</option></select></div><div class="col-sm-2"><input class="form-control" type="number" name="refresh_seconds" value="{{$item.refresh_seconds}}" min="0" max="3600" aria-label="Refresh interval in seconds" /></div>
</div>
<div class="form-group row">
  <label class="col-sm-2 col-form-label text-right">Ad Density:</label><div class="col-sm-2"><select class="form-control" name="ad_density">{{$v = $item.ad_density}}<option value="Unknown" {{if eq $v "Unknown"}}selected{{end}}>Pending Classification</option><option value="Low" {{if eq $v "Low"}}selected{{end}}>Low</option><option value="Standard" {{if eq $v "Standard"}}selected{{end}}>Standard</option><option value="High" {{if eq $v "High"}}selected{{end}}>High</option></select></div>
  <label class="col-sm-2 col-form-label text-right">Traffic Quality:</label><div class="col-sm-2"><select class="form-control" name="traffic_quality">{{$v = $item.traffic_quality}}<option value="Unknown" {{if eq $v "Unknown"}}selected{{end}}>Pending Classification</option><option value="Reviewed" {{if eq $v "Reviewed"}}selected{{end}}>Manually Reviewed</option><option value="Sampled" {{if eq $v "Sampled"}}selected{{end}}>Sampled</option><option value="Suspicious" {{if eq $v "Suspicious"}}selected{{end}}>Suspicious</option><option value="Blocked" {{if eq $v "Blocked"}}selected{{end}}>Blocked</option></select></div>
  <label class="col-sm-2 col-form-label text-right">Traffic Source Quality:</label><div class="col-sm-2"><select class="form-control" name="source_quality">{{$v = $item.source_quality}}<option value="Unknown" {{if eq $v "Unknown"}}selected{{end}}>Pending Classification</option><option value="OwnedOperated" {{if eq $v "OwnedOperated"}}selected{{end}}>Owned and Operated</option><option value="Partner" {{if eq $v "Partner"}}selected{{end}}>Partner</option><option value="Network" {{if eq $v "Network"}}selected{{end}}>Publisher Network</option><option value="Resale" {{if eq $v "Resale"}}selected{{end}}>Resale</option></select></div>
</div>
<div class="form-group row mb-0"><label class="col-sm-2 col-form-label text-right">Management Responsibility:</label><div class="col-sm-4"><select class="form-control" name="management_control">{{$v = $item.management_control}}<option value="Unknown" {{if eq $v "Unknown"}}selected{{end}}>Pending Classification</option><option value="Publisher" {{if eq $v "Publisher"}}selected{{end}}>Publisher-managed</option><option value="Operator" {{if eq $v "Operator"}}selected{{end}}>Platform-managed</option><option value="Partner" {{if eq $v "Partner"}}selected{{end}}>Partner-managed</option></select></div><div class="col-sm-6 text-muted">Timed refresh requires 15–3600 seconds. These fields support transparency and reporting and do not change settlement ownership.</div></div>
</div></div>

<div class="form-group row">
    <label for="inputBidFloor" class="col-sm-3 col-form-label text-right">Minimum Bid (USD CPM):</label>
    <div class="col-sm-3">
        <input id="inputBidFloor" type=number class="form-control" name="bidfloor" value="{{$item.bidfloor}}" min="0" step="0.000001" />
    </div>
    <div class="col-sm-6 col-form-label">The system always uses the higher of the configured floor and the request floor; clients cannot lower this floor.</div>
</div>

<div class="form-group row">
    <label for="inputPlatform" class="col-sm-3 col-form-label text-right">Ad Language:</label>
    <div class="col-sm-9 col-form-label">Select the language used by this ad slot.</div>
    <label class="col-sm-3 col-form-label text-right"></label>
    <div class="col-sm-9 col-form-label">{{ range $one := .Other.qa_language }}
      <div class="form-check form-check-inline mr-1">
        <input class="form-check-input" type="radio" id="qa_{{$one.which}}" value="{{$one.which}}" name="qa_language" {{if $one.selected}}checked{{end}}>
        <label class="form-check-label" for="inline-radio1">{{$one.label}}</label>
      </div>{{end}}
    </div>
</div>


<div class="form-group row">
    <label for="inputPlatform" class="col-sm-3 col-form-label text-right">Device Platform:</label>
    <div class="col-sm-9 col-form-label">{{ range $one := .Other.qa_device }}
      <div class="form-check form-check-inline mr-1">
        <input class="form-check-input" type="radio" id="qa_{{$one.which}}" value="{{$one.which}}" name="qa_device" {{if $one.selected}}checked{{end}}>
        <label class="form-check-label" for="inline-radio1">{{$one.label}}</label>
      </div>{{end}}
    </div>
</div>

<div class="form-group row">
    <label for="inputPageLevel" class="col-sm-3 col-form-label text-right">Ad Slot Position:</label>
    <div class="col-sm-9 col-form-label">{{ range $one := .Other.qa_position }}
        <div class="form-check form-check-inline mr-1">
           <input class="form-check-input" id="qa_{{$one.which}}" type=radio name=qa_position value="{{$one.which}}" {{if $one.selected }}checked{{end}} >
           <label class="form-check-label" for="inline-radio1">{{$one.label}}</label>
        </div>{{end}}
    </div>
</div>

<div class="form-group row">
    <label for="inputType" class="col-sm-3 col-form-label text-right">Accepted Ad MIME Types
MIME:</label>
    <div class="col-sm-9 col-form-label">{{ range $one := .Other.fl_mime }}
      <div class="form-check form-check-inline mr-1">
        <input class="form-check-input" type="checkbox" value="{{$one.which}}" name="fl_mime" {{if $one.selected}}checked{{end}}>
        <label class="form-check-label" for="inline-radio1">{{$one.label}}</label>
      </div>{{end}}
    </div>
</div>

<div class="form-group row">
    <label for="inputYaxis" class="col-sm-3 col-form-label text-right">Accepted Creative Features:</label>
    <div class="col-sm-9">{{ range $one := .Other.fl_creative }}
        <div class="form-check form-check-inline mr-1">
           <input class="form-check-input" id="qa_{{$one.which}}" type=checkbox name=fl_creative value="{{$one.which}}" {{if $one.selected }}checked{{end}} >
           <label>{{$one.label}}</label>
        </div>{{end}}
    </div>
</div>

<div class="form-group row">
    <label for="inputClock" class="col-sm-3 col-form-label text-right">Accepted Expansion Modes:</label>
    <div class="col-sm-9 col-form-label">Select all expansion modes this ad slot accepts.</div>
    <label class="col-sm-3 col-form-label text-right"></label>
    <div class="col-sm-9 col-form-label">{{ range $one := .Other.fl_expnd }}
        <div class="form-check form-check-inline mr-1">
           <input class="form-check-input" id="expnd_{{$one.which}}" type=checkbox name=fl_expnd value="{{$one.which}}" {{if $one.selected}}checked{{end}} >
           <label class="form-check-label" for="inline-radio1">{{$one.label}}</label>
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
<table class="table table-striped table-sm table-condensed">
{{range $key, $val := .Other.slots }}{{$obs := index $item $key}}
<tr><td>{{index $sAttrs $key}}:</td><td><select size=1 name={{$key}}>{{range $k, $v := $val}}
<option {{if eq $k $obs}}selected{{end}} value="{{$k}}">{{$v}}</option>{{end}}</td></tr>{{end}}
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
<table class="table table-striped table-sm table-condensed">
{{range $key, $val := .Other.items }}{{$obs := index $item $key}}
<tr><td>{{index $cAttrs $key}}:</td><td><select size=1 name={{$key}}>{{range $k, $v := $val}}
<option {{if eq $k $obs}}selected{{end}} value="{{$k}}">{{$v}}</option>{{end}}</td></tr>{{end}}
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
<table class="table table-sm table-condensed table-striped">
<thead>
<tr>
<th>Industry</th>
<th>Traffic Source Industry</th>
<th>Required Campaign Industries:
<input class="form-control-inline" type=radio name=channel_order value="Black" {{if eq "Black" $item.channel_order}}checked{{end}} />Blocklist
<input type=radio name=channel_order value="White" {{if eq "White" $item.channel_order}}checked{{end}} />Allowlist
</th>
</tr>
</thead>
<tbody>{{ with $item.chac_topics }}{{ range . }}
<tr><td>{{.channel_name}}</td>
<td class="text-center"><input class="form-control-inline" name=belong_ids {{if .chbelong_id}}checked{{end}} type=checkbox value="{{.channel_id}}" /></td>
<td class="text-center"><input class="form-control-inline" name=ac_ids {{if .chac_id}}checked{{end}} type=checkbox value="{{.channel_id}}" /></td>
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
<button type="submit" class="btn btn-primary">Save and Update</button>
    </div>
</div>

</form>
