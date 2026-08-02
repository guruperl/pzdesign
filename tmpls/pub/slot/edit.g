
{{$cAttrs := .Other.itemAttrsChinese }}
{{$sAttrs := .Other.slotAttrsChinese }}

{{$item := index .Lists 0}}

<form class="form" action="slot" method=post>
<input type=hidden name="action" value="update" />
<input type=hidden name="slot_id"   value="{{$item.slot_id}}" />
<input type=hidden name="site_id"   value="{{index .ARGS.site_id 0}}" />
<input type=hidden name="site_md5"  value="{{index .ARGS.site_md5 0}}" />
<input type=hidden name="site_name" value="{{index .ARGS.site_name 0}}" />
<input type=hidden name="site_type" value="{{index .ARGS.site_type 0}}" />

<div class="form-group row">
    <label for="inputSlotName" class="col-sm-3 col-form-label text-right">广告位名称:</label>
    <div class="col-sm-3">
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

<div class="card mb-3"><div class="card-header">广告位分类与质量</div><div class="card-body">
<div class="form-group row">
  <label class="col-sm-2 col-form-label text-right">媒体形式：</label><div class="col-sm-4"><select class="form-control" name="media_intent">{{$v := $item.media_intent}}<option value="Unknown" {{if eq $v "Unknown"}}selected{{end}}>待确认</option><option value="Banner" {{if eq $v "Banner"}}selected{{end}}>展示广告</option><option value="Video" {{if eq $v "Video"}}selected{{end}}>视频</option><option value="Native" {{if eq $v "Native"}}selected{{end}}>原生</option><option value="Audio" {{if eq $v "Audio"}}selected{{end}}>音频</option><option value="Multi" {{if eq $v "Multi"}}selected{{end}}>多格式</option></select></div>
  <label class="col-sm-2 col-form-label text-right">展示位置：</label><div class="col-sm-4"><select class="form-control" name="placement">{{$v = $item.placement}}<option value="Unknown" {{if eq $v "Unknown"}}selected{{end}}>待确认</option><option value="AboveFold" {{if eq $v "AboveFold"}}selected{{end}}>首屏</option><option value="InFeed" {{if eq $v "InFeed"}}selected{{end}}>信息流</option><option value="Interstitial" {{if eq $v "Interstitial"}}selected{{end}}>插屏</option><option value="Rewarded" {{if eq $v "Rewarded"}}selected{{end}}>激励式</option><option value="Sticky" {{if eq $v "Sticky"}}selected{{end}}>悬停</option><option value="Popup" {{if eq $v "Popup"}}selected{{end}}>弹窗</option><option value="Other" {{if eq $v "Other"}}selected{{end}}>其他</option></select></div>
</div>
<div class="form-group row">
  <label class="col-sm-2 col-form-label text-right">呈现场景：</label><div class="col-sm-4"><select class="form-control" name="render_context">{{$v = $item.render_context}}<option value="Unknown" {{if eq $v "Unknown"}}selected{{end}}>待确认</option><option value="WebPage" {{if eq $v "WebPage"}}selected{{end}}>网页</option><option value="InApp" {{if eq $v "InApp"}}selected{{end}}>App 内</option><option value="Player" {{if eq $v "Player"}}selected{{end}}>播放器</option><option value="Fullscreen" {{if eq $v "Fullscreen"}}selected{{end}}>全屏</option><option value="Other" {{if eq $v "Other"}}selected{{end}}>其他</option></select></div>
  <label class="col-sm-2 col-form-label text-right">刷新：</label><div class="col-sm-2"><select class="form-control" name="refresh_mode">{{$v = $item.refresh_mode}}<option value="Unknown" {{if eq $v "Unknown"}}selected{{end}}>待确认</option><option value="None" {{if eq $v "None"}}selected{{end}}>不刷新</option><option value="Timed" {{if eq $v "Timed"}}selected{{end}}>定时</option><option value="Event" {{if eq $v "Event"}}selected{{end}}>事件触发</option></select></div><div class="col-sm-2"><input class="form-control" type="number" name="refresh_seconds" value="{{$item.refresh_seconds}}" min="0" max="3600" aria-label="刷新秒数" /></div>
</div>
<div class="form-group row">
  <label class="col-sm-2 col-form-label text-right">广告密度：</label><div class="col-sm-2"><select class="form-control" name="ad_density">{{$v = $item.ad_density}}<option value="Unknown" {{if eq $v "Unknown"}}selected{{end}}>待确认</option><option value="Low" {{if eq $v "Low"}}selected{{end}}>低</option><option value="Standard" {{if eq $v "Standard"}}selected{{end}}>标准</option><option value="High" {{if eq $v "High"}}selected{{end}}>高</option></select></div>
  <label class="col-sm-2 col-form-label text-right">流量质量：</label><div class="col-sm-2"><select class="form-control" name="traffic_quality">{{$v = $item.traffic_quality}}<option value="Unknown" {{if eq $v "Unknown"}}selected{{end}}>待确认</option><option value="Reviewed" {{if eq $v "Reviewed"}}selected{{end}}>人工审核</option><option value="Sampled" {{if eq $v "Sampled"}}selected{{end}}>抽样审核</option><option value="Suspicious" {{if eq $v "Suspicious"}}selected{{end}}>可疑</option><option value="Blocked" {{if eq $v "Blocked"}}selected{{end}}>停用</option></select></div>
  <label class="col-sm-2 col-form-label text-right">流量来源：</label><div class="col-sm-2"><select class="form-control" name="source_quality">{{$v = $item.source_quality}}<option value="Unknown" {{if eq $v "Unknown"}}selected{{end}}>待确认</option><option value="OwnedOperated" {{if eq $v "OwnedOperated"}}selected{{end}}>自有自营</option><option value="Partner" {{if eq $v "Partner"}}selected{{end}}>合作方</option><option value="Network" {{if eq $v "Network"}}selected{{end}}>媒体网络</option><option value="Resale" {{if eq $v "Resale"}}selected{{end}}>转售</option></select></div>
</div>
<div class="form-group row mb-0"><label class="col-sm-2 col-form-label text-right">管理责任：</label><div class="col-sm-4"><select class="form-control" name="management_control">{{$v = $item.management_control}}<option value="Unknown" {{if eq $v "Unknown"}}selected{{end}}>待确认</option><option value="Publisher" {{if eq $v "Publisher"}}selected{{end}}>流量方管理</option><option value="Operator" {{if eq $v "Operator"}}selected{{end}}>平台管理</option><option value="Partner" {{if eq $v "Partner"}}selected{{end}}>合作方管理</option></select></div><div class="col-sm-6 text-muted">定时刷新需填写 15–3600 秒；这些字段用于透明度和报表，不改变结算归属。</div></div>
</div></div>

<div class="form-group row">
    <label for="inputBidFloor" class="col-sm-3 col-form-label text-right">最低竞价（USD CPM）：</label>
    <div class="col-sm-3">
        <input id="inputBidFloor" type=number class="form-control" name="bidfloor" value="{{$item.bidfloor}}" min="0" step="0.000001" />
    </div>
    <div class="col-sm-6 col-form-label">系统始终采用配置底价与请求底价中的较高值；客户端不能降低此底价。</div>
</div>

<div class="form-group row">
    <label for="inputPlatform" class="col-sm-3 col-form-label text-right">所用语言:</label>
    <div class="col-sm-9 col-form-label">本广告位所用语言</div>
    <label class="col-sm-3 col-form-label text-right"></label>
    <div class="col-sm-9 col-form-label">{{ range $one := .Other.qa_language }}
      <div class="form-check form-check-inline mr-1">
        <input class="form-check-input" type="radio" id="qa_{{$one.which}}" value="{{$one.which}}" name="qa_language" {{if $one.selected}}checked{{end}}>
        <label class="form-check-label" for="inline-radio1">{{$one.label_chinese}}</label>
      </div>{{end}}
    </div>
</div>


<div class="form-group row">
    <label for="inputPlatform" class="col-sm-3 col-form-label text-right">设备平台:</label>
    <div class="col-sm-9 col-form-label">{{ range $one := .Other.qa_device }}
      <div class="form-check form-check-inline mr-1">
        <input class="form-check-input" type="radio" id="qa_{{$one.which}}" value="{{$one.which}}" name="qa_device" {{if $one.selected}}checked{{end}}>
        <label class="form-check-label" for="inline-radio1">{{$one.label_chinese}}</label>
      </div>{{end}}
    </div>
</div>

<div class="form-group row">
    <label for="inputPageLevel" class="col-sm-3 col-form-label text-right">广告位位置:</label>
    <div class="col-sm-9 col-form-label">{{ range $one := .Other.qa_position }}
		<div class="form-check form-check-inline mr-1">
           <input class="form-check-input" id="qa_{{$one.which}}" type=radio name=qa_position value="{{$one.which}}" {{if $one.selected }}checked{{end}} >
           <label class="form-check-label" for="inline-radio1">{{$one.label_chinese}}</label>
        </div>{{end}}
    </div>
</div>

<div class="form-group row">
    <label for="inputType" class="col-sm-3 col-form-label text-right">可接受广告
MIME:</label>
    <div class="col-sm-9 col-form-label">{{ range $one := .Other.fl_mime }}
      <div class="form-check form-check-inline mr-1">
        <input class="form-check-input" type="checkbox" value="{{$one.which}}" name="fl_mime" {{if $one.selected}}checked{{end}}>
        <label class="form-check-label" for="inline-radio1">{{$one.label_chinese}}</label>
      </div>{{end}}
    </div>
</div>

<div class="form-group row">
    <label for="inputYaxis" class="col-sm-3 col-form-label text-right">可接受广告特点:</label>
    <div class="col-sm-9">{{ range $one := .Other.fl_creative }}
        <div class="form-check form-check-inline mr-1">
           <input class="form-check-input" id="qa_{{$one.which}}" type=checkbox name=fl_creative value="{{$one.which}}" {{if $one.selected }}checked{{end}} >
           <label>{{$one.label_chinese}}</label>
        </div>{{end}}
    </div>
</div>

<div class="form-group row">
    <label for="inputClock" class="col-sm-3 col-form-label text-right">展开:</label>
    <div class="col-sm-9 col-form-label">能接受的广告展开？多选。</div>
    <label class="col-sm-3 col-form-label text-right"></label>
    <div class="col-sm-9 col-form-label">{{ range $one := .Other.fl_expnd }}
		<div class="form-check form-check-inline mr-1">
           <input class="form-check-input" id="expnd_{{$one.which}}" type=checkbox name=fl_expnd value="{{$one.which}}" {{if $one.selected}}checked{{end}} >
           <label class="form-check-label" for="inline-radio1">{{$one.label_chinese}}</label>
        </div>{{end}}
    </div>
</div>

<div class="form-group row">
    <label for="selectSiteQuality" class="col-sm-2 col-form-label text-right">质量控制：</label>
    <div class="col-sm-5">
        <div class="card">
			<div class="card-header">
				本流量源质量
			</div>
            <div class="card-body">
<div class="table-responsive">
<table class="table table-striped table-sm table-condensed">
{{range $key, $val := .Other.slotsChinese }}{{$obs := index $item $key}}
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
				要求广告活动质量达到
			</div>
            <div class="card-body">
<div class="table-responsive">
<table class="table table-striped table-sm table-condensed">
{{range $key, $val := .Other.itemsChinese }}{{$obs := index $item $key}}
<tr><td>{{index $cAttrs $key}}:</td><td><select size=1 name={{$key}}>{{range $k, $v := $val}}
<option {{if eq $k $obs}}selected{{end}} value="{{$k}}">{{$v}}</option>{{end}}</td></tr>{{end}}
</table>
</div>
            </div>
        </div>
    </div>
</div>

<div class="form-group row">
    <label for="checkChannels" class="col-sm-2 col-form-label text-right">行业匹配：</label>
    <div class="col-sm-10">
        <div class="card">
            <div class="card-body">
<div class="table-responsive">
<table class="table table-sm table-condensed table-striped">
<thead>
<tr>
<th>行业名</th>
<th>本属行业</th>
<th>要求广告活动行业： 
<input class="form-control-inline" type=radio name=channel_order value="Black" {{if eq "Black" $item.channel_order}}checked{{end}} />黑名单
<input type=radio name=channel_order value="White" {{if eq "White" $item.channel_order}}checked{{end}} />白名单
</th>
</tr>
</thead>
<tbody>{{ with $item.chac_topics }}{{ range . }}
<tr><td>{{.channel_name_g}}</td>
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
<button type="submit" class="btn btn-primary">保存并更新</button>
    </div>
</div>

</form>
