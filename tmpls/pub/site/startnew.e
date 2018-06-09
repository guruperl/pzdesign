{{ template "header" .}}
{{ template "siteheader" .}}

          <div class="card">
            <div class="card-header">
              Create New Site
            </div>
            <div class="card-body">

<form class="form" action="site" method=post>
<input type=hidden name="action" value="insert">

<div class="form-group row">
	<label for="inputSiteName" class="col-sm-2 col-form-label">Site Name:</label>
	<div class="col-sm-4">
		<input type=text class="form-control" name=site_name placeholder="Site Name" />
	</div>
	<label for="inputSiteURL" class="col-sm-2 col-form-label">Site URL:</label>
	<div class="col-sm-4">
		<input type=text class="form-control" name=site_url placeholder="Site URL" />
	</div>
</div>

<div class="form-group row">
    <label for="inputAccessOrder" class="col-sm-2 col-form-label">Access Order:</label>
    <div class="col-sm-4">
        <div class="form-check form-check-inline">
            <input class="form-check-input" type="radio" name="access_order" id="ao_black" value="Black">
            <label class="form-check-label" for="ao_black">Black</label>
            <input class="form-check-input" type="radio" name="access_order" id="ao_white" value="White">
            <label class="form-check-label" for="ao_white">White</label>
            <input class="form-check-input" type="radio" name="access_order" id="ao_inherit" checked value="Inherit">
            <label class="form-check-label" for="ao_inherit">Inherit</label>
        </div>
	</div>
	<label class="col-sm-2 col-form-label">Advertiser IDs:</label>
	<div class="col-sm-4">
        <span id="myP" class="invisible">
            <input class="form-control" name="other_ids" placeholder="advertiser IDs separated by comma" />
        </span>
    </div>
</div>

<div class="form-group row">
    <label for="selectSiteQuality" class="col-sm-2 col-form-label">Quality:</label>
    <div class="col-sm-10">
        <div class="card">
            <div class="card-body">{{$s_attrs := .Other.siteAttrs}}
<table>{{range $key, $val := .Other.sites }}
<tr><td>{{index $s_attrs $key}}:</td><td><select size=1 name={{$key}}>{{range $k, $v := $val}}
<option value="{{$k}}">{{$v}}</option>{{end}}</td></tr>{{end}}
</table>
            </div>
        </div>
    </div>
</div>

<div class="form-group row">
    <label for="selectCampaignQuality" class="col-sm-2 col-form-label">Accept Campaign:</label>
    <div class="col-sm-10">
        <div class="card">
            <div class="card-body">{{$c_attrs := .Other.campaignAttrs}}
<table>{{range $key, $val := .Other.campaigns }}
<tr><td>{{index $c_attrs $key}}:</td><td><select size=1 name={{$key}}>{{range $k, $v := $val}}
<option value="{{$k}}">{{$v}}</option>{{end}}</td></tr>{{end}}
</table>
            </div>
        </div>
    </div>
</div>


<div class="form-group row">
    <label for="checkChannels" class="col-sm-2 col-form-label">Channels:</label>
    <div class="col-sm-10">
        <div class="card">
            <div class="card-body">
<table class="table table-sm table-condensed table-bordered">
<tr>
<th>Name</th>
<th>Belong&nbsp; </th>
<th>&nbsp;
<input type=radio name=channel_order value="Black" />Black
<input type=radio name=channel_order value="White" />White
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
<button type="submit" class="btn btn-primary">Create Now !</button>
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

