{{ template "header" .}}
{{ template "acheader" .}}

{{$args := .ARGS}}

          <div class="card">
            <div class="card-header">
              Order of <em>{{if eq "31" (index .ARGS.entitytype_id 0)}}{{index .ARGS.site_name 0}}{{else}}{{index .ARGS.p_company 0}}{{end}}</em>
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

Access logic: <input type=radio name=access_order value="Black" {{if eq `Black` (index .ARGS.access_order 0)}}checked{{end}} />Black
<input type=radio name=access_order value="White" {{if eq `White` (index .ARGS.access_order 0)}}checked{{end}} />White
{{if eq `31` (index .ARGS.entitytype_id 0)}}<input type=radio name=access_order value="Inherit" {{if eq `Inherit` (index .ARGS.access_order 0)}}checked{{end}} />Inherit{{end}}
<button class="btn btn-sm btn-primary" type=submit onClick="return (confirm('This will delete all existing access list and reset logic. Do you want to continue?')) ? true : false;">Update</button>
</form>
            </div>
          </div>



{{if ne `Inherit` (index .ARGS.access_order 0)}}


{{if .Lists}}
          <div class="card">
            <div class="card-header">
              Current Access-Control List of <em>{{if eq "31" (index .ARGS.entitytype_id 0)}}{{index .ARGS.site_name 0}}{{else}}{{index .ARGS.p_company 0}}{{end}}</em>
            </div>
            <div class="card-body">

<div class="table-responsive">
<table class="table table-striped table-sm">
              <thead>
                <tr>
                  <th>Name</th>
                  <th>URL</th>
                  <th></th>
                </tr>
              </thead>
              <tbody>{{ with .Lists }}{{ range . }}
<tr><td>{{.company}}</td>
<td>{{.url}}</td>
<td><a href="ac?action=delete&ac_id={{.ac_id}}&{{if eq (index $args.entitytype_id 0) "3"}}entitytype_id=3{{else}}{{ print `entytitype_id=31&site_id=` (index $args.site_id 0) `&site_md5=` (index $args.site_md5 0) `&site_name=` (index $args.site_name 0 | urlquery) }}{{end}}">Del</a></td>
</tr>{{end}}{{end}}
</tobdy>
</table>
</div>
            </div>
          </div>
{{end}}


          <div class="card">
            <div class="card-header">
              Add New Advertisers
            </div>
            <div class="card-body">
Please add black or white advertisers from the performance report pages.
<!--form name=f2 class="form" method=post action="ac">
<input type=hidden name=action value="insert" />
<input type=hidden name=othertype_id value="4" />
{{if eq "31" (index .ARGS.entitytype_id 0)}}
<input type=hidden name=site_id value="{{index .ARGS.site_id 0}}" />
<input type=hidden name=site_md5 value="{{index .ARGS.site_md5 0}}" />
<input type=hidden name=site_name value="{{index .ARGS.site_name 0}}" />
<input type=hidden name=entitytype_id value="31" />{{else}}
<input type=hidden name=entitytype_id value="3" />{{end}}
Advertiser ID: <input type=text name=other_id size=12 />
<button type=submit class="btn btn-sm btn-primary">Add Advertiser</button>
</form -->
            </div>
          </div>


{{end}}



{{ template "footer" }}
</body>
</html>

