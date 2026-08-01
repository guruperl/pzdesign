

{{$item := index .Lists 0}}

<form method=post action=site>
<input type=hidden name="action" value="update" />
<input type=hidden name="site_id" value="{{$item.site_id}}" />

<div class="form-group row">
	<label for="inputSiteName" class="col-sm-2 col-form-label text-right">流量源名称：</label>
	<div class="col-sm-4">
		<input type=text class="form-control" name=site_name value="{{$item.site_name}}" />
	</div>
        <label for="inputSiteType" class="col-sm-2 col-form-label text-right"> 类别：</label>
        <div class="col-sm-1">
                <input type=radio class="form-control" name=site_type value="App" {{if eq $item.site_type "App"}}checked{{end}} />
        </div>
        <label for="inputSiteTypeApp" class="col-sm-1 col-form-label text-right">App</label>
        <div class="col-sm-1">
                <input type=radio class="form-control" name=site_type value="Web" {{if eq $item.site_type "App"}}checked{{end}} />
        </div>
        <label for="inputSiteTypeWeb" class="col-sm-1 col-form-label text-right">Web</label>
</div>

(Bundle: For mobile apps in
Google Play Store, these should be bundle or package names
e.g. com.foo.mygame. For apps in Apple App Store, these should be a numeric ID.
For web, this should be site's domain name.)
<div class="form-group row">
        <label for="inputForeignID" class="col-sm-2 col-form-label text-right">Bundle/Domain：</label>
        <div class="col-sm-4">
                <input type=text class="form-control" name=foreign_id placeholder="com.foo.mygame" value="{{$item.foreign_id}}" />
        </div>
        <label for="inputSiteURL" class="col-sm-2 col-form-label text-right"> 介绍网址：</label>
        <div class="col-sm-4">
                <input type=text class="form-control" name=site_url placeholder="网站URL" value="{{$item.site_url}}" />
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
