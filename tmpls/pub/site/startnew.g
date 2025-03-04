

<form class=form class="form" action="site" method=post>
<input type=hidden name="action" value="insert">

<div class="form-group row">
	<label for="inputSiteName" class="col-sm-2 col-form-label text-right">App或网站名：</label>
	<div class="col-sm-4">
		<input type=text class="form-control" name=site_name placeholder="名称" />
	</div>
	<label for="inputSiteURL" class="col-sm-2 col-form-label text-right"> 介绍网址：</label>
	<div class="col-sm-4">
		<input type=text class="form-control" name=site_url placeholder="网站URL" />
	</div>
</div>

<div class="form-group row">
    <div class="col-sm-2">
	</div>
    <div class="col-sm-10">
<button type="submit" class="btn btn-primary">提交新站</button>
    </div>
</div>

</form>
