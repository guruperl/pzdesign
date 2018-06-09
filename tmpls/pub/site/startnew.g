{{ template "header" .}}
{{ template "siteheader" .}}

{{$cAttrs := .Other.campaignAttrsChinese }}
{{$sAttrs := .Other.siteAttrsChinese }}

          <div class="card">
            <div class="card-header">
              添加广告位组（网站或移动应用）
            </div>
            <div class="card-body">

<form class="form" action="site" method=post>
<input type=hidden name="action" value="insert">

<div class="form-group row">
	<label for="inputSiteName" class="col-sm-2 col-form-label text-right">组名称:</label>
	<div class="col-sm-4">
		<input type=text class="form-control" name=site_name placeholder="网站名称" />
	</div>
	<label for="inputSiteURL" class="col-sm-2 col-form-label text-right">网址:</label>
	<div class="col-sm-4">
		<input type=text class="form-control" name=site_url placeholder="网站URL" />
	</div>
</div>

<div class="form-group row">
    <label for="inputAccessOrder" class="col-sm-2 col-form-label text-right">黑白名单:</label>
    <div class="col-sm-4">
        <div class="form-check form-check-inline">
            <input class="form-check-input" type="radio" name="access_order" id="ao_black" value="Black">
            <label class="form-check-label" for="ao_black">黑名单</label>
            <input class="form-check-input" type="radio" name="access_order" id="ao_white" value="White">
            <label class="form-check-label" for="ao_white">白名单</label>
            <input class="form-check-input" type="radio" name="access_order" id="ao_inherit" checked value="Inherit">
            <label class="form-check-label" for="ao_inherit">默认</label>
        </div>
	</div>
    <label for="inputAdvID" class="col-sm-2 col-form-label text-right">广告商代码:</label>
	<div class="col-sm-4">
        <span id="myP" class="invisible">
            <input class="form-control" name="other_ids" placeholder="输入广告商代码，用英文逗号分开" />
        </span>
    </div>
</div>

<div class="form-group row">
    <label for="selectSiteQuality" class="col-sm-2 col-form-label text-right">网站质量:</label>
    <div class="col-sm-10">
        <div class="card">
            <div class="card-body">
<table>{{range $key, $val := .Other.sites }}
<tr><td>{{index $sAttrs $key}}:</td><td><select size=1 name={{$key}}>{{range $k, $v := $val}}
<option value="{{$k}}">{{$v}}</option>{{end}}</td></tr>{{end}}
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
<table>{{range $key, $val := .Other.campaigns }}
<tr><td>{{index $cAttrs $key}}:</td><td><select size=1 name={{$key}}>{{range $k, $v := $val}}
<option value="{{$k}}">{{$v}}</option>{{end}}</td></tr>{{end}}
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
<table class="table-condensed">
<tr>
<th>行业名</th>
<th>本属行业&nbsp;</th>
<th>&nbsp;
<input type=radio name=channel_order value="Black" />行业黑名单
<input type=radio name=channel_order value="White" />白名单
</th>
</tr>
<tbody>{{ with .Other.channel_topics }}{{ range . }}
<tr><td>{{.channel_name}}</td>
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

