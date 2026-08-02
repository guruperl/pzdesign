

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

<div class="card mt-3">
<div class="card-header">流量分类</div>
<div class="card-body">
<div class="form-group row">
  <label class="col-sm-2 col-form-label text-right">流量环境：</label>
  <div class="col-sm-4"><select class="form-control" name="inventory_environment">
    <option value="Unknown">待确认</option><option value="Web">网站</option><option value="App">移动 App</option>
    <option value="CTV">联网电视（CTV）</option><option value="DOOH">数字户外（DOOH）</option><option value="Other">其他</option>
  </select></div>
  <label class="col-sm-2 col-form-label text-right">接入方式：</label>
  <div class="col-sm-4"><select class="form-control" name="integration_mode">
    <option value="Unknown">待确认</option><option value="ADX">ADX / OpenRTB</option><option value="BrowserTag">网页广告代码</option>
    <option value="SDK">App SDK / API</option><option value="ServerAPI">服务端 API</option>
  </select></div>
</div>
<div class="form-group row">
  <label class="col-sm-2 col-form-label text-right">规范标识：</label>
  <div class="col-sm-4"><input class="form-control" name="canonical_identity" maxlength="255" placeholder="网站域名或 App Bundle" /></div>
  <label class="col-sm-2 col-form-label text-right">公开审核网址：</label>
  <div class="col-sm-4"><input class="form-control" name="store_url" maxlength="1024" placeholder="https://..." /></div>
</div>
<p class="mb-0 text-muted">规范标识用于服务端校验和透明度披露；留空时沿用 Bundle/Domain。接入方式仅描述流量来源，不授予额外权限。</p>
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
