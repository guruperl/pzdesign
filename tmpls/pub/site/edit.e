

{{$item := index .Lists 0}}

<form method=post action=site>
<input type=hidden name="action" value="update" />
<input type=hidden name="site_id" value="{{$item.site_id}}" />

<div class="form-group row">
    <label for="inputSiteName" class="col-sm-2 col-form-label text-right">Traffic Source Name:</label>
    <div class="col-sm-4">
        <input type=text class="form-control" name=site_name value="{{$item.site_name}}" />
    </div>
        <label for="inputSiteType" class="col-sm-2 col-form-label text-right"> Type:</label>
        <div class="col-sm-1">
                <input type=radio class="form-control" name=site_type value="App" {{if eq $item.site_type "App"}}checked{{end}} />
        </div>
        <label for="inputSiteTypeApp" class="col-sm-1 col-form-label text-right">App</label>
        <div class="col-sm-1">
                <input type=radio class="form-control" name=site_type value="Web" {{if eq $item.site_type "Web"}}checked{{end}} />
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
        <label for="inputSiteURL" class="col-sm-2 col-form-label text-right"> Information URL:</label>
        <div class="col-sm-4">
                <input type=text class="form-control" name=site_url placeholder="Website URL" value="{{$item.site_url}}" />
        </div>
</div>

<div class="card mt-3">
<div class="card-header">Traffic Classification</div>
<div class="card-body">
<div class="form-group row">
  <label class="col-sm-2 col-form-label text-right">Traffic Environment:</label>
  <div class="col-sm-4"><select class="form-control" name="inventory_environment">
    {{$environment := $item.inventory_environment}}
    <option value="Unknown" {{if eq $environment "Unknown"}}selected{{end}}>Pending Classification</option><option value="Web" {{if eq $environment "Web"}}selected{{end}}>Website</option>
    <option value="App" {{if eq $environment "App"}}selected{{end}}>Mobile App</option><option value="CTV" {{if eq $environment "CTV"}}selected{{end}}>Connected TV (CTV)</option>
    <option value="DOOH" {{if eq $environment "DOOH"}}selected{{end}}>Digital Out-of-Home (DOOH)</option><option value="Other" {{if eq $environment "Other"}}selected{{end}}>Other</option>
  </select></div>
  <label class="col-sm-2 col-form-label text-right">Integration Mode:</label>
  <div class="col-sm-4"><select class="form-control" name="integration_mode">
    {{$integration := $item.integration_mode}}
    <option value="Unknown" {{if eq $integration "Unknown"}}selected{{end}}>Pending Classification</option><option value="ADX" {{if eq $integration "ADX"}}selected{{end}}>ADX / OpenRTB</option>
    <option value="BrowserTag" {{if eq $integration "BrowserTag"}}selected{{end}}>Browser Ad Tag</option><option value="SDK" {{if eq $integration "SDK"}}selected{{end}}>App SDK / API</option>
    <option value="ServerAPI" {{if eq $integration "ServerAPI"}}selected{{end}}>Server API</option>
  </select></div>
</div>
<div class="form-group row">
  <label class="col-sm-2 col-form-label text-right">Canonical Identifier:</label>
  <div class="col-sm-4"><input class="form-control" name="canonical_identity" maxlength="255" value="{{$item.canonical_identity}}" /></div>
  <label class="col-sm-2 col-form-label text-right">Public Review URL:</label>
  <div class="col-sm-4"><input class="form-control" name="store_url" maxlength="1024" value="{{$item.store_url}}" /></div>
</div>
<p class="mb-0 text-muted">The canonical identifier supports server-side validation and transparency disclosures. The integration mode describes only the traffic source and grants no additional permissions.</p>
</div>
</div>

<div class="form-group row">
    <div class="col-sm-2">
    </div>
    <div class="col-sm-10">
<button type="submit" class="btn btn-primary">Save and Update</button>
    </div>
</div>

</form>
