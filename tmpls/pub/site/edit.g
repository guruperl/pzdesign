{{$cAttrs := .Other.campaignAttrsChinese }}
{{$sAttrs := .Other.siteAttrsChinese }}

{{$item := index .Lists 0}}
{{$first := print "site_id=" $item.site_id "&site_md5=" $item.site_md5 "&site_name=" ($item.site_name | urlquery)}}

<form method=post action=site>
<input type=hidden name="action" value="update" />
<input type=hidden name="site_id" value="{{$item.site_id}}" />

<div class="form-group row">
	<label for="inputSiteName" class="col-sm-2 col-form-label text-right">媒体名称：</label>
	<div class="col-sm-4">
		<input type=text class="form-control" name=site_name value="{{$item.site_name}}" />
	</div>
	<label for="inputSiteURL" class="col-sm-2 col-form-label text-right">介绍网址：</label>
	<div class="col-sm-4">
		<input type=text class="form-control" name=site_url placeholder="网站 URL" value="{{$item.site_url}}" />
	</div>
</div>

<!-- div class="form-group row">
    <label for="selectSiteQuality" class="col-sm-2 col-form-label text-right">质量控制：</label>
    <div class="col-sm-5">
        <div class="card">
			<div class="card-header">
				本媒体质量
			</div>
            <div class="card-body">
<div class="table-responsive">
<table class="table table-striped table-sm table-condensed">
{{range $key, $val := .Other.sitesChinese }}{{$obs := index $item $key}}
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
{{range $key, $val := .Other.campaignsChinese }}{{$obs := index $item $key}}
<tr><td>{{index $cAttrs $key}}:</td><td><select size=1 name={{$key}}>{{range $k, $v := $val}}
<option {{if eq $k $obs}}selected{{end}} value="{{$k}}">{{$v}}</option>{{end}}</td></tr>{{end}}
</table>
</div>
            </div>
        </div>
    </div>
</div -->

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
    <div class="col-sm-2">
	</div>
    <div class="col-sm-10">
<button type="submit" class="btn btn-primary">保存并更新</button>
    </div>
</div>

</form>
