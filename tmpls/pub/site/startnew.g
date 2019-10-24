{{ template "header" .}}
{{ template "siteheader" .}}

{{$cAttrs := .Other.campaignAttrsChinese }}
{{$sAttrs := .Other.siteAttrsChinese }}
{{$cDefault := .Other.campaignsDefault }}
{{$sDefault := .Other.sitesDefault }}

          <div class="card">
            <div class="card-header">
              添加媒体（广告位组）
            </div>
            <div class="card-body">

<form class="form" action="site" method=post>
<input type=hidden name="action" value="insert">

<div class="form-group row">
	<label for="inputSiteName" class="col-sm-2 col-form-label text-right">媒体名称:</label>
	<div class="col-sm-4">
		<input type=text class="form-control" name=site_name placeholder="媒体名称" />
	</div>
	<label for="inputSiteURL" class="col-sm-2 col-form-label text-right"> 介绍网址:</label>
	<div class="col-sm-4">
		<input type=text class="form-control" name=site_url placeholder="网站URL" />
	</div>
</div>

<div class="form-group row">
    <label for="selectSiteQuality" class="col-sm-2 col-form-label text-right">网站质量:</label>
    <div class="col-sm-10">
        <div class="card">
            <div class="card-body">
<table>{{range $key, $val := .Other.sitesChinese }}{{$default := index $sDefault $key}}
<tr><td>{{index $sAttrs $key}}:</td><td><select size=1 name={{$key}}>{{range $k, $v := $val}}
<option {{if eq $k $default}}selected{{end}} value="{{$k}}">{{$v}}</option>{{end}}</td></tr>{{end}}
</table>
            </div>
        </div>
    </div>
</div>

<div class="form-group row">
    <label for="selectCampaignQuality" class="col-sm-2 col-form-label text-right">可接受广告活动:</label>
    <div class="col-sm-10">
        <div class="card">
            <div class="card-body">
<table>{{range $key, $val := .Other.campaignsChinese }}{{$default := index $cDefault $key}}
<tr><td>{{index $cAttrs $key}}:</td><td><select size=1 name={{$key}}>{{range $k, $v := $val}}
<option {{if eq $k $default}}selected{{end}} value="{{$k}}">{{$v}}</option>{{end}}</td></tr>{{end}}
</table>
            </div>
        </div>
    </div>
</div>


<div class="form-group row">
    <label for="checkChannels" class="col-sm-2 col-form-label text-right">行业分类:</label>
    <div class="col-sm-10">
        <div class="card">
            <div class="card-body">
<table class="table table-sm table-condensed table-bordered">
<tr>
<th>行业名</th>
<th>本属行业&nbsp;</th>
<th>&nbsp;
<input type=radio name=channel_order value="Black" />行业黑名单
<input type=radio name=channel_order value="White" />白名单
</th>
</tr>
<tbody>{{ with .Other.channel_topics }}{{ range . }}
<tr><td>{{.channel_name_g}}</td>
<td class="text-center"><input name=belong_ids type=checkbox value="{{.channel_id}}" /></td>
<td class="text-center"><input name=ac_ids type=checkbox value="{{.channel_id}}" /></td>
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
<button type="submit" class="btn btn-primary">提交广告组!</button>
    </div>
</div>

</form>


        </div>
      </div>
{{ template "footer" .}}

<script>
$(document).ready(function(){
    $("#ao_inherit").click(function(){
        $("#myP").addClass('invisible');
    });
    $("#ao_black").click(function(){
        $("#myP").removeClass('invisible');
    });
    $("#ao_white").click(function(){
        $("#myP").removeClass('invisible');
    });
});
</script>

</body>
</html>

