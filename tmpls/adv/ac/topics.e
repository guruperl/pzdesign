{{ template "header" .}}
{{ template "acheader" .}}

        <div class="row">
            <div class="col-lg-12">
                <div class="panel panel-primary">
                    <div class="panel-heading">


{{if eq "41" (index .ARGS.entitytype_id 0)}}
{{index .ARGS.campaign_name 0}}{{else}}
{{index .ARGS.a_company 0}}{{end}}

                    </div>
                    <div class="panel-body">

<form name=f1 class="form" method=post action="ac">
<input type=hidden name=action value="updateOrder" />
{{if eq "41" (index .ARGS.entitytype_id 0)}}
<input type=hidden name=campaign_id value="{{index .ARGS.campaign_id 0}}" />
<input type=hidden name=campaign_md5 value="{{index .ARGS.campaign_md5 0}}" />
<input type=hidden name=campaign_name value="{{index .ARGS.campaign_name 0}}" />
<input type=hidden name=entitytype_id value="41" />
{{else}}
<input type=hidden name=entitytype_id value="4" />
{{end}}

<div class="form-group row">
    <label for="inputAccessOrder" class="col-sm-3 col-form-label text-right">Allowlist/Blocklist Setting:</label>
    <div class="col-sm-9">
        <div class="form-check form-check-inline">
<input class="form-check-input" type=radio name=access_order value="Black" {{if eq `Black` (index .ARGS.access_order 0)}}checked{{end}} />
<label class="form-check-label">Blocklist</label>
<input class="form-check-input" type=radio name=access_order value="White" {{if eq `White` (index .ARGS.access_order 0)}}checked{{end}} />
<label class="form-check-label">Allowlist</label>
{{if eq `41` (index .ARGS.entitytype_id 0)}}
<input class="form-check-input" type=radio name=access_order value="Inherit" {{if eq `Inherit` (index .ARGS.access_order 0)}}checked{{end}} />
<label class="form-check-label">System Default</label>{{end}}
<button class="form-check-input btn btn-sm btn-primary" onClick="return (confirm('This deletes all existing access-list entries and resets the rule. Continue?')) ? true : false;" type=submit>Change</button>
        </div>
    </div>
</div>
</form>

{{if ne `Inherit` (index .ARGS.access_order 0)}}


<div class="table-responsive">
<table class="table table-condensed">
              <thead>
                <tr>
                  <th>Website</th>
                  <th>URL</th>
                  <th></th>
                </tr>
              </thead>
              <tbody>{{range $item := .Lists }}
<tr><td>{{$item.site_name}}</td>
<td>{{$item.site_url}}</td>
<td><a onClick="return (confirm('Delete this entry?')) ? true : false;" href="ac?action=delete&ac_id={{.ac_id}}&{{if eq "41" (index $.ARGS.entitytype_id 0)}}campaign_id={{index $.ARGS.campaign_id 0}}&campaign_md5={{index $.ARGS.campaign_md5 0}}&campaign_name={{index $.ARGS.campaign_name 0 | urlquery}}&entitytype_id=41{{else}}entitytype_id=4{{end}}">Delete</a></td>
</tr>{{end}}
</tobdy>
</table>
</div>

<h5>Add a traffic source or website from the performance report.</h5>
<!--
<form name=f2 class="form" method=post action="ac">
<input type=hidden name=action value="insert" />
{{if eq "41" (index .ARGS.entitytype_id 0)}}
<input type=hidden name=campaign_id value="{{index .ARGS.campaign_id 0}}" />
<input type=hidden name=campaign_md5 value="{{index .ARGS.campaign_md5 0}}" />
<input type=hidden name=campaign_name value="{{index .ARGS.campaign_name 0}}" />
<input type=hidden name=entitytype_id value="41" />{{else}}
<input type=hidden name=entitytype_id value="4" />{{end}}
Choose: <input type=radio name=othertype_id value=3>Traffic Source <input type=radio name=othertype_id value=31>Website
ID: <input type=text name=other_id size=12 />
<input type=submit value=" Confirm " />
</form>
-->
{{end}}
                </div>
            </div>
        </div>
    </div>

{{ template "footer" }}
