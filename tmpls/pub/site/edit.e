{{ template "header" .}}
{{ template "siteheader" .}}

{{$item := index .Lists 0}}
{{$first := print "site_id=" $item.site_id "&site_md5=" $item.site_md5 "&site_name=" ($item.site_name | urlquery)}}

          <div class="card">
            <div class="card-header">
              Edit <em>{{$item.site_name}}</em>
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
            <div class="card-body">{{$s_attrs := .Other.siteAttrs}}
<table>{{range $key, $val := .Other.sites }}{{$obs := index $item $key}}
<tr><td>{{index $s_attrs $key}}:</td><td><select size=1 name={{$key}}>{{range $k, $v := $val}}
<option {{if eq $k $obs}}selected{{end}} value="{{$k}}">{{$v}}</option>{{end}}</td></tr>{{end}}
</table>
            </div>
        </div>
    </div>
</div>

<div class="form-group row">
    <label for="selectCampaignQuality" class="col-sm-3 col-form-label">Accept Campaign:</label>
    <div class="col-sm-9">
        <div class="card">
            <div class="card-body">{{$c_attrs := .Other.campaignAttrs}}
<table>{{range $key, $val := .Other.campaigns }}{{$obs := index $item $key}}
<tr><td>{{index $c_attrs $key}}:</td><td><select size=1 name={{$key}}>{{range $k, $v := $val}}
<option {{if eq $k $obs}}selected{{end}} value="{{$k}}">{{$v}}</option>{{end}}</td></tr>{{end}}
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
<th>&nbsp;
<input type=radio name=channel_order value="Black" {{if eq "Black" $item.channel_order}}checked{{end}} />Black
<input type=radio name=channel_order value="White" {{if eq "White" $item.channel_order}}checked{{end}} />White
</th>
</tr>
<tbody>{{ with $item.chac_topics }}{{ range . }}
<tr><td>{{.channel_name}}</td>
<td class="text-center"><input name=belong_ids {{if .chbelong_id}}checked{{end}} type=checkbox value="{{.channel_id}}" /></td>
<td class="text-center"><input name=ac_ids {{if .chac_id}}checked{{end}} type=checkbox value="{{.channel_id}}" /></td>
</tr>{{end}}{{end}}
</tobdy>
</table>
            </div>
        </div>
    </div>
</div>


<div class="form-group row">
    <div class="col-sm-9">
<button type="submit" class="btn btn-primary">Save and Update!</button>
    </div>
</div>

</form>


        </div>
      </div>
{{ template "footer" .}}

</body>
</html>

