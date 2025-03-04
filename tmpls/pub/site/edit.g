

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

<div class="form-group row">
    <div class="col-sm-2">
	</div>
    <div class="col-sm-10">
<button type="submit" class="btn btn-primary">保存并更新</button>
    </div>
</div>

</form>
