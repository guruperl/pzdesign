

<form class=form class="form" action="site" method=post>
<input type=hidden name="action" value="insert">

<div class="form-group row">
    <label for="inputSiteName" class="col-sm-2 col-form-label text-right">Website or App Name:</label>
    <div class="col-sm-4">
        <input type=text class="form-control" name=site_name placeholder="Name" />
    </div>
    <label for="inputSiteType" class="col-sm-2 col-form-label text-right">Type:</label>
    <div class="col-sm-1">
        <input type=radio class="form-control" name=site_type value="App" />
    </div>
    <label for="inputSiteTypeApp" class="col-sm-1 col-form-label text-right">App</label>
    <div class="col-sm-1">
        <input type=radio class="form-control" name=site_type value="Web" />
    </div>
    <label for="inputSiteTypeWeb" class="col-sm-1 col-form-label text-right">Web</label>
</div>

<p>Bundle/Domain: for an Android app, enter its package name (for example, <code>com.foo.mygame</code>); for an iOS app, enter its numeric App Store ID; for a website, enter its domain.</p>
<div class="form-group row">
    <label for="inputForeignID" class="col-sm-2 col-form-label text-right">Bundle/Domain：</label>
    <div class="col-sm-4">
        <input type=text class="form-control" name=foreign_id placeholder="com.foo.mygame" />
    </div>
    <label for="inputSiteURL" class="col-sm-2 col-form-label text-right">Information URL:</label>
    <div class="col-sm-4">
        <input type=text class="form-control" name=site_url placeholder="Website URL" />
    </div>
</div>

<div class="card mt-3">
<div class="card-header">Traffic Classification</div>
<div class="card-body">
<div class="form-group row">
  <label class="col-sm-2 col-form-label text-right">Traffic Environment:</label>
  <div class="col-sm-4"><select class="form-control" name="inventory_environment">
    <option value="Unknown">Pending Classification</option><option value="Web">Website</option><option value="App">Mobile App</option>
    <option value="CTV">Connected TV (CTV)</option><option value="DOOH">Digital Out-of-Home (DOOH)</option><option value="Other">Other</option>
  </select></div>
  <label class="col-sm-2 col-form-label text-right">Integration Mode:</label>
  <div class="col-sm-4"><select class="form-control" name="integration_mode">
    <option value="Unknown">Pending Classification</option><option value="ADX">ADX / OpenRTB</option><option value="BrowserTag">Browser Ad Tag</option>
    <option value="SDK">App SDK / API</option><option value="ServerAPI">Server API</option>
  </select></div>
</div>
<div class="form-group row">
  <label class="col-sm-2 col-form-label text-right">Canonical Identifier:</label>
  <div class="col-sm-4"><input class="form-control" name="canonical_identity" maxlength="255" placeholder="Website domain or app bundle" /></div>
  <label class="col-sm-2 col-form-label text-right">Public Review URL:</label>
  <div class="col-sm-4"><input class="form-control" name="store_url" maxlength="1024" placeholder="https://..." /></div>
</div>
<p class="mb-0 text-muted">The canonical identifier supports server-side validation and transparency disclosures; when blank, Bundle/Domain is used. The integration mode describes only the traffic source and grants no additional permissions.</p>
</div>
</div>

<div class="form-group row">
    <div class="col-sm-2">
    </div>
    <div class="col-sm-10">
<button type="submit" class="btn btn-primary">Add Traffic Source</button>
    </div>
</div>

</form>
