{{$cAttrs := .Other.itemAttrsChinese }}
{{$sAttrs := .Other.slotAttrsChinese }}
{{$cDefault := .Other.itemsDefault }}
{{$sDefault := .Other.slotsDefault }}


<form class="form" action="slot" method=post>
<input type=hidden name="action" value="insert" />
<input type=hidden name="site_id"   value="{{index .ARGS.site_id 0}}" />
<input type=hidden name="site_md5"  value="{{index .ARGS.site_md5 0}}" />
<input type=hidden name="site_name" value="{{index .ARGS.site_name 0}}" />
<input type=hidden name="site_type" value="{{index .ARGS.site_type 0}}" />

<div class="form-group row">
    <label for="inputSlotName" class="col-sm-3 col-form-label text-right">广告位名称：</label>
    <div class="col-sm-3">
        <input type=text class="form-control" name="slot_name" placeholder="名称" />
    </div>
    <label for="inputSizeID" class="col-sm-2 col-form-label text-right">尺寸：</label>
    <div class="col-sm-2">
        <input type=text class="form-control" name="w" value="64" />
	</div>
    <div class="col-sm-2">
        <input type=text class="form-control" name="h" value="64" />
	</div>
</div>

<div class="card mb-3"><div class="card-header">广告位分类与质量</div><div class="card-body">
<div class="form-group row">
  <label class="col-sm-2 col-form-label text-right">媒体形式：</label><div class="col-sm-4"><select class="form-control" name="media_intent"><option value="Unknown">待确认</option><option value="Banner">展示广告</option><option value="Video">视频</option><option value="Native">原生</option><option value="Audio">音频</option><option value="Multi">多格式</option></select></div>
  <label class="col-sm-2 col-form-label text-right">展示位置：</label><div class="col-sm-4"><select class="form-control" name="placement"><option value="Unknown">待确认</option><option value="AboveFold">首屏</option><option value="InFeed">信息流</option><option value="Interstitial">插屏</option><option value="Rewarded">激励式</option><option value="Sticky">悬停</option><option value="Popup">弹窗</option><option value="Other">其他</option></select></div>
</div>
<div class="form-group row">
  <label class="col-sm-2 col-form-label text-right">呈现场景：</label><div class="col-sm-4"><select class="form-control" name="render_context"><option value="Unknown">待确认</option><option value="WebPage">网页</option><option value="InApp">App 内</option><option value="Player">播放器</option><option value="Fullscreen">全屏</option><option value="Other">其他</option></select></div>
  <label class="col-sm-2 col-form-label text-right">刷新：</label><div class="col-sm-2"><select class="form-control" name="refresh_mode"><option value="Unknown">待确认</option><option value="None">不刷新</option><option value="Timed">定时</option><option value="Event">事件触发</option></select></div><div class="col-sm-2"><input class="form-control" type="number" name="refresh_seconds" value="0" min="0" max="3600" aria-label="刷新秒数" /></div>
</div>
<div class="form-group row">
  <label class="col-sm-2 col-form-label text-right">广告密度：</label><div class="col-sm-2"><select class="form-control" name="ad_density"><option value="Unknown">待确认</option><option value="Low">低</option><option value="Standard">标准</option><option value="High">高</option></select></div>
  <label class="col-sm-2 col-form-label text-right">流量质量：</label><div class="col-sm-2"><select class="form-control" name="traffic_quality"><option value="Unknown">待确认</option><option value="Reviewed">人工审核</option><option value="Sampled">抽样审核</option><option value="Suspicious">可疑</option><option value="Blocked">停用</option></select></div>
  <label class="col-sm-2 col-form-label text-right">流量来源：</label><div class="col-sm-2"><select class="form-control" name="source_quality"><option value="Unknown">待确认</option><option value="OwnedOperated">自有自营</option><option value="Partner">合作方</option><option value="Network">媒体网络</option><option value="Resale">转售</option></select></div>
</div>
<div class="form-group row mb-0"><label class="col-sm-2 col-form-label text-right">管理责任：</label><div class="col-sm-4"><select class="form-control" name="management_control"><option value="Unknown">待确认</option><option value="Publisher">流量方管理</option><option value="Operator">平台管理</option><option value="Partner">合作方管理</option></select></div><div class="col-sm-6 text-muted">定时刷新需填写 15–3600 秒；这些字段用于透明度和报表，不改变结算归属。</div></div>
</div></div>

<div class="form-group row">
    <label for="inputBidFloor" class="col-sm-3 col-form-label text-right">最低竞价（USD CPM）：</label>
    <div class="col-sm-3">
        <input id="inputBidFloor" type=number class="form-control" name="bidfloor" value="0.000000" min="0" step="0.000001" />
    </div>
    <div class="col-sm-6 col-form-label">系统始终采用配置底价与请求底价中的较高值；客户端不能降低此底价。</div>
</div>

<div class="form-group row">
    <label for="inputPlatform" class="col-sm-3 col-form-label text-right">广告语言：</label>
    <div class="col-sm-9 col-form-label">选择该广告位可接受的广告语言。</div>
    <label class="col-sm-3 col-form-label text-right"></label>
    <div class="col-sm-9 col-form-label">{{ range $item := .Other.qa_language }}
      <div class="form-check form-check-inline mr-1">
        <input class="form-check-input" type="radio" id="qa_{{$item.which}}" value="{{$item.which}}" name="qa_language" {{if eq $item.which "EN"}}checked{{end}}>
        <label class="form-check-label" for="inline-radio1">{{$item.label_chinese}}</label>
      </div>{{end}}
    </div>
</div>

<div class="form-group row">
    <label for="inputPlatform" class="col-sm-3 col-form-label text-right">设备平台：</label>
    <div class="col-sm-9 col-form-label">选择该广告位所在的设备类型。</div>
    <label class="col-sm-3 col-form-label text-right"></label>
    <div class="col-sm-9 col-form-label">{{ range $item := .Other.qa_device }}
      <div class="form-check form-check-inline mr-1">
        <input class="form-check-input" type="radio" id="qa_{{$item.which}}" value="{{$item.which}}" name="qa_device" {{if eq $item.which "0"}}checked{{end}}>
        <label class="form-check-label" for="inline-radio1">{{$item.label_chinese}}</label>
      </div>{{end}}
    </div>
</div>

<div class="form-group row">
    <label for="inputPageLevel" class="col-sm-3 col-form-label text-right">广告位位置：</label>
    <div class="col-sm-9 col-form-label">选择该广告位在页面或屏幕中的位置。</div>
    <label class="col-sm-3 col-form-label text-right"></label>
    <div class="col-sm-9 col-form-label">{{ range $item := .Other.qa_position }}
		<div class="form-check form-check-inline mr-1">
           <input class="form-check-input" id="qa_{{$item.which}}" type=radio name=qa_position value="{{$item.which}}" {{if eq $item.which "0"}}checked{{end}} >
           <label class="form-check-label" for="inline-radio1">{{$item.label_chinese}}</label>
        </div>{{end}}
    </div>
</div>

<div class="form-group row">
    <label for="inputType" class="col-sm-3 col-form-label text-right">可接受的广告 MIME 类型：</label>
    <div class="col-sm-9 col-form-label">可多选。</div>
    <label class="col-sm-3 col-form-label text-right"></label>
    <div class="col-sm-9 col-form-label">{{ range $item := .Other.fl_mime }}
        <div class="form-check form-check-inline mr-1">
        <input type=checkbox class="form-check-input" name="fl_mime" value="{{$item.which}}" {{if $item.default}}checked{{end}}>
        <label class="form-check-label" for="inline-radio1">{{$item.label_chinese}}</label>
        </div>{{end}}
    </div>
</div>

<div class="form-group row">
    <label for="inputYaxis" class="col-sm-3 col-form-label text-right">可接受的广告特征：</label>
    <div class="col-sm-9">可多选。</div>
    <label class="col-sm-3 col-form-label text-right"></label>
    <div class="col-sm-9">{{ range $item := .Other.fl_creative }}
        <div class="form-check form-check-inline mr-1">
           <input class="form-check-input" id="creative_{{$item.which}}" type=checkbox name=fl_creative value="{{$item.which}}" {{if $item.default}}checked{{end}} >
           <label>{{$item.label_chinese}}</label>
        </div>{{end}}
    </div>
</div>


<div class="form-group row">
    <label for="inputClock" class="col-sm-3 col-form-label text-right">可接受的广告展开方式：</label>
    <div class="col-sm-9 col-form-label">可多选。</div>
    <label class="col-sm-3 col-form-label text-right"></label>
    <div class="col-sm-9 col-form-label">{{ range $item := .Other.fl_expnd }}
		<div class="form-check form-check-inline mr-1">
           <input class="form-check-input" id="expnd_{{$item.which}}" type=checkbox name=fl_expnd value="{{$item.which}}" {{if $item.default}}checked{{end}} >
           <label class="form-check-label" for="inline-radio1">{{$item.label_chinese}}</label>
        </div>{{end}}
    </div>
</div>

<div class="form-group row">
    <label for="selectSiteQuality" class="col-sm-2 col-form-label text-right">质量控制：</label>
    <div class="col-sm-5">
        <div class="card">
			<div class="card-header">
				本站质量
			</div>
            <div class="card-body">
<div class="table-responsive">
<table class="table table-striped table-sm table-condensed">{{range $key, $val := .Other.slotsChinese }}{{$default := index $sDefault $key}}
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
				要求广告活动质量
			</div>
            <div class="card-body">
<div class="table-responsive">
<table class="table table-striped table-sm table-condensed">{{range $key, $val := .Other.itemsChinese }}{{$default := index $cDefault $key}}
<tr><td>{{index $cAttrs $key}}:</td><td><select size=1 name={{$key}}>{{range $k, $v := $val}}
<option {{if eq $k $default}}selected{{end}} value="{{$k}}">{{$v}}</option>{{end}}</td></tr>{{end}}
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
<table class="table table-sm table-striped table-condensed">
<thead>
<tr>
<th>行业名</th>
<th>本属行业</th>
<th>要求广告活动行业：
<input class="form-control-inline" type=radio name=channel_order value="Black" checked>黑名单
<input class="form-control-inline" type=radio name=channel_order value="White">白名单
</th>
</tr>
</thead>
<tbody>{{ with .Other.channel_topics }}{{ range . }}
<tr><td>{{.channel_name_g}}</td>
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
<button type="submit" class="btn btn-primary">添加广告位</button>
    </div>
</div>

</form>
