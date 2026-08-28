{{ template "header" .}}
{{ template "acheader" .}}

{{$args := .ARGS}}

          <div class="card">
            <div class="card-header">
                Traffic Scope Settings for <em>{{if eq "31" (index .ARGS.entitytype_id 0)}}Traffic Source “{{index .ARGS.site_name 0}}”{{else}}Publisher Account “{{index .ARGS.p_company 0}}”{{end}}</em>
            </div>
            <div class="card-body">
<form name=f1 class="form" method=post action="ac">
<input type=hidden name=action value="updateOrder" />
{{if eq "31" (index .ARGS.entitytype_id 0)}}
<input type=hidden name=site_id value="{{index .ARGS.site_id 0}}" />
<input type=hidden name=site_md5 value="{{index .ARGS.site_md5 0}}" />
<input type=hidden name=site_name value="{{index .ARGS.site_name 0}}" />
<input type=hidden name=entitytype_id value="31" />{{else}}
<input type=hidden name=entitytype_id value="3" />{{end}}

<div class=row>
    <div class="col-12">
<input type=radio name=access_order value="Black" {{if eq `Black` (index .ARGS.access_order 0)}}checked{{end}} />Blocklist (reject listed advertisers and campaigns; accept all others)
<input type=radio name=access_order value="White" {{if eq `White` (index .ARGS.access_order 0)}}checked{{end}} />Allowlist (accept only listed advertisers and campaigns)
{{if eq `31` (index .ARGS.entitytype_id 0)}}<input type=radio name=access_order value="Inherit" {{if eq `Inherit` (index .ARGS.access_order 0)}}checked{{end}} />Default{{end}}
    </div>
</div>
<div class=row>
    <div class="col-12">
        <button class="btn btn-primary" type=submit onClick="return (confirm('Change the traffic scope rule? This clears the existing rules.')) ? true : false;">Update Traffic Scope Rule</button>
        <a class="btn btn-success" href="ac?action=startnew&entitytype_id={{index .ARGS.entitytype_id 0}}">View All Campaigns</a>
    </div>
</div>
</form>
            </div>
          </div>


          <div class="card">
{{if .Lists}}
            <div class="card-header">
              Current Allowlist/Blocklist for <em>{{if eq "31" (index .ARGS.entitytype_id 0)}}Traffic Source “{{index .ARGS.site_name 0}}”{{else}}Publisher Account “{{index .ARGS.p_company 0}}”{{end}}</em>
            </div>
            <div class="card-body">

<div class="table-responsive">
<table class="table table-striped table-sm">
              <thead>
                <tr>
                  <th>Advertiser Company</th>
                  <th>Company URL</th>
                  <th>Campaign Name</th>
                  <th></th>
                </tr>
              </thead>
              <tbody>{{ with .Lists }}{{ range . }}
<tr><td>{{.company}}</td>
<td>{{.url}}</td>
<td>{{.campaign_name}}</td>
<td><a onClick="return (confirm('Delete this traffic-scope entry?')) ? true : false;" class="btn btn-sm btn-danger" href="ac?action=delete&ac_id={{.ac_id}}&{{if eq (index $args.entitytype_id 0) "3"}}entitytype_id=3{{else}}entitytype_id=31&site_id={{index $args.site_id 0}}&site_md5={{index $args.site_md5 0}}&site_name={{index $args.site_name 0 | urlquery}}{{end}}">Delete</a></td>
</tr>{{end}}{{end}}
</tobdy>
</table>
</div>
            </div>
{{end}}


            <div class="card-body">
<form name=f2 class="form-inline" method=post action="ac">
<input type=hidden name=action value="insert" />
{{if eq "31" (index .ARGS.entitytype_id 0)}}
<input type=hidden name=site_id value="{{index .ARGS.site_id 0}}" />
<input type=hidden name=site_md5 value="{{index .ARGS.site_md5 0}}" />
<input type=hidden name=site_name value="{{index .ARGS.site_name 0}}" />
<input type=hidden name=entitytype_id value="31" />{{else}}
<input type=hidden name=entitytype_id value="3" />{{end}}
Add directly to traffic scope: <input class="form-inline" type=radio name=othertype_id value="4" />Advertiser <input type=radio name=othertype_id value="41" />Campaign
Object ID: <input class="form-inline" type=text name=other_id size=12 />
<button type=submit class="btn btn-sm btn-primary">Add</button>
</form>
            </div>
          </div>

{{ template "footer" }}
</body>
</html>
