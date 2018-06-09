{{ template "header" .}}
{{ template "siteheader" .}}

{{$cAttrs := .Other.campaignAttrsChinese }}
{{$sAttrs := .Other.siteAttrsChinese }}

{{$item := index .Lists 0}}
{{$first := print "site_id=" $item.site_id "&site_md5=" $item.site_md5 "&site_name=" ($item.site_name | urlquery)}}

          <div class="card">
            <div class="card-header">
              编辑修改 <em>{{$item.site_name}}</em>
            </div>
            <div class="card-body">

<form method=post action=site>
<input type=hidden name="action" value="update" />
<input type=hidden name="site_id" value="{{$item.site_id}}" />

<div class="form-group row">
	<label for="inputSiteName" class="col-sm-2 col-form-label text-right">广告组名:</label>
	<div class="col-sm-4">
		<input type=text class="form-control" name=site_name value="{{$item.site_name}}" />
	</div>
	<label for="inputSiteURL" class="col-sm-2 col-form-label text-right">网址URL:</label>
	<div class="col-sm-4">
		<input type=text class="form-control" name=site_url placeholder="网站 URL" value="{{$item.site_url}}" />
	</div>
</div>

<div class="form-group row">
    <label for="inputAccessOrder" class="col-sm-2 col-form-label text-right">黑白名单设置:</label>
    <div class="col-sm-10">
        <div class="form-check form-check-inline">
			{{$item.access_order}}
            <a class="btn btn-xs btn-warning" href="ac?action=topics&entitytype_id=31&{{$first}}">查看</a>
        </div>
    </div>
</div>

<div class="form-group row">
    <label for="selectSiteQuality" class="col-sm-2 col-form-label text-right">本组质量:</label>
    <div class="col-sm-10">
        <div class="card">
            <div class="card-body">
<table>{{range $key, $val := .Other.sites }}{{$obs := index $item $key}}
<tr><td>{{index $sAttrs $key}}:</td><td><select size=1 name={{$key}}>{{range $k, $v := $val}}
<option {{if eq $k $obs}}selected{{end}} value="{{$k}}">{{$v}}</option>{{end}}</td></tr>{{end}}
</table>
            </div>
        </div>
    </div>
</div>

<div class="form-group row">
    <label for="selectCampaignQuality" class="col-sm-2 col-form-label text-right">可接受活动:</label>
    <div class="col-sm-10">
        <div class="card">
            <div class="card-body">
<table>{{range $key, $val := .Other.campaigns }}{{$obs := index $item $key}}
<tr><td>{{index $cAttrs $key}}:</td><td><select size=1 name={{$key}}>{{range $k, $v := $val}}
<option {{if eq $k $obs}}selected{{end}} value="{{$k}}">{{$v}}</option>{{end}}</td></tr>{{end}}
</table>
            </div>
        </div>
    </div>
</div>

<div class="form-group row">
    <label for="checkChannels" class="col-sm-2 col-form-label" text-right>行业分类:</label>
    <div class="col-sm-10">
        <div class="card">
            <div class="card-body">
<table class="table table-sm table-condensed table-bordered">
<tr>
<th>行业名</th>
<th>本属于&nbsp; </th>
<th>&nbsp;
<input type=radio name=channel_order value="Black" {{if eq "Black" $item.channel_order}}checked{{end}} />黑名单
<input type=radio name=channel_order value="White" {{if eq "White" $item.channel_order}}checked{{end}} />白名单
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

