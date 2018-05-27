{{ template "header" .}}
{{ template "siteheader" .}}

{{$item := index .Lists 0}}
{{$first := print "site_id=" $item.site_id "&site_md5=" $item.site_md5 "&site_name=" ($item.site_name | urlquery)}}

          <div class="card">
            <div class="card-header">
              Create New
              <div class="card-actions">
                <a href="site?action=info">
                  <small class="text-muted">docs</small>
                </a>
              </div>
            </div>
            <div class="card-body">

<form method=post action=site>
<input type=hidden name="action" value="update" />
<input type=hidden name="site_id" value="{{$item.site_id}}" />

<div class="form-group row">
	<label for="inputSiteName" class="col-sm-3 col-form-label">Site Name:</label>
	<div class="col-sm-9">
		<input type=text class="form-control" name=site_name placeholder="Site Name" value="{{$item.site_name}}" />
	</div>
</div>

<div class="form-group row">
	<label for="inputSiteURL" class="col-sm-3 col-form-label">Site URL:</label>
	<div class="col-sm-9">
		<input type=text class="form-control" name=site_url placeholder="Site URL" value="{{$item.site_url}}" />
	</div>
</div>

<div class="form-group row">
    <label for="inputAccessOrder" class="col-sm-3 col-form-label">Access Order:</label>
    <div class="col-sm-9">
        <div class="form-check form-check-inline">
			{{$item.access_order}}
            <a class="btn btn-xs btn-warning" href="ac?action=topics&entitytype_id=31&{{$first}}">Check</a>
        </div>
    </div>
</div>

<div class="form-group row">
    <label for="selectSiteQuality" class="col-sm-3 col-form-label">Quality:</label>
    <div class="col-sm-9">
        <div class="card">
            <div class="card-body">
<table>
<tr><th>s_age</th><td>{{$item.s_age}}</td></tr>
<tr><th>s_control</th><td>{{$item.s_control}}</td></tr>
<tr><th>s_crowd</th><td>{{$item.s_crowd}}</td></tr>
<tr><th>s_domain</th><td>{{$item.s_domain}}</td></tr>
<tr><th>s_internet</th><td>{{$item.s_internet}}</td></tr>
<tr><th>s_local</th><td>{{$item.s_local}}</td></tr>
<tr><th>s_popup</th><td>{{$item.s_popup}}</td></tr>
<tr><th>s_source</th><td>{{$item.s_source}}</td></tr>
<tr><th>s_traffic</th><td>{{$item.s_traffic}}</td></tr>
<tr><th>s_visual</th><td>{{$item.s_visual}}</td></tr>
<tr><th>s_world</th><td>{{$item.s_world}}</td></tr>
</table>
            </div>
        </div>
    </div>
</div>

<div class="form-group row">
    <label for="selectCampaignQuality" class="col-sm-3 col-form-label">Accept Campaign:</label>
    <div class="col-sm-9">
        <div class="card">
            <div class="card-body">
<table>
<tr><th>c_act:</th><td>{{$item.c_act}}</td></tr>
<tr><th>c_content:</th><td>{{$item.c_content}}</td></tr>
<tr><th>c_download:</th><td>{{$item.c_download}}</td></tr>
<tr><th>c_postclick:</th><td>{{$item.c_postclick}}</td></tr>
<tr><th>c_speed:</th><td>{{$item.c_speed}}</td></tr>
<tr><th>c_visual:</th><td>{{$item.c_visual}}</td></tr>
</table>
            </div>
        </div>
    </div>
</div>


<div class="form-group row">
    <label for="checkChannels" class="col-sm-3 col-form-label">Channels:</label>
    <div class="col-sm-9">
        <div class="card">
            <div class="card-body">
<table>
<tr>
<th>Name</th>
<th>Belong&nbsp; </th>
<th>{{$item.channel_order}}
</th>
</tr>
<tbody>{{ with $item.chac_topics }}{{ range . }}{{if or .chac_id .chbelong_id}}
<tr><td>{{.channel_name}}</td>
<td>{{if .chac_id}}Selected{{end}}</td>
<td>{{if .chbelong_id}}Selected{{end}}</td>
</tr>{{end}}{{end}}{{end}}
</tobdy>
</table>
            <a class="btn btn-xs btn-warning" href="chac?action=topics&entitytype_id=41&{{$first}}">Check</a>
            </div>
        </div>
    </div>
</div>

<div class="form-group row">
    <div class="col-sm-9">
<button type="submit" class="btn btn-primary">Create Now !</button>
    </div>
</div>

</form>


        </div>
      </div>
{{ template "footer" .}}

</body>
</html>

