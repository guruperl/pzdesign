

<form class=form class="form" action="site" method=post>
<input type=hidden name="action" value="insert">

<div class="form-group row">
	<label for="inputSiteName" class="col-sm-2 col-form-label text-right">网站或 App 名称：</label>
	<div class="col-sm-4">
		<input type=text class="form-control" name=site_name placeholder="名称" />
	</div>
	<label for="inputSiteType" class="col-sm-2 col-form-label text-right">类型：</label>
	<div class="col-sm-1">
		<input type=radio class="form-control" name=site_type value="App" />
	</div>
	<label for="inputSiteTypeApp" class="col-sm-1 col-form-label text-right">App</label>
	<div class="col-sm-1">
		<input type=radio class="form-control" name=site_type value="Web" />
	</div>
	<label for="inputSiteTypeWeb" class="col-sm-1 col-form-label text-right">Web</label>
</div>

<p>Bundle/Domain：Android App 填写包名（例如 <code>com.foo.mygame</code>）；iOS App 填写 App Store 数字 ID；网站填写域名。</p>
<div class="form-group row">
	<label for="inputForeignID" class="col-sm-2 col-form-label text-right">Bundle/Domain：</label>
	<div class="col-sm-4">
		<input type=text class="form-control" name=foreign_id placeholder="com.foo.mygame" />
	</div>
	<label for="inputSiteURL" class="col-sm-2 col-form-label text-right">介绍网址：</label>
	<div class="col-sm-4">
		<input type=text class="form-control" name=site_url placeholder="网站URL" />
	</div>
</div>

<div class="form-group row">
    <div class="col-sm-2">
	</div>
    <div class="col-sm-10">
<button type="submit" class="btn btn-primary">添加流量源</button>
    </div>
</div>

</form>
