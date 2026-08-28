                <div class="panel panel-primary">
                    <div class="panel-heading">
                        Budget
                    </div>
                    <div class="panel-body">
                        <p class="text-muted">Spend, impression, and click caps are hard delivery limits. Zero or blank means no limit for that field. If a cap is reduced to no more than the amount already consumed, subsequent bidding stops within the cache-propagation window.</p>

<form name=total class="form" method=post action="balance">
{{if .ARGS.total_balance_id}}<input type=hidden name=action value="update" />
{{else}}<input type=hidden name=action value="insert">
<input type=hidden name=which value="total_balance_id">{{end}}
<input type=hidden name=entitytype_id value="{{ index .ARGS.entitytype_id 0}}" />
<input type=hidden name=campaign_id value="{{index .ARGS.campaign_id 0}}" />
<input type=hidden name=campaign_md5 value="{{index .ARGS.campaign_md5 0}}" />
<input type=hidden name=campaign_name value="{{index .ARGS.campaign_name 0}}" />{{ if eq "42" (index .ARGS.entitytype_id 0)}}
<input type=hidden name=item_id value="{{index .ARGS.item_id 0}}" />
<input type=hidden name=item_md5 value="{{index .ARGS.item_md5 0}}" />
<input type=hidden name=item_name value="{{index .ARGS.item_name 0}}" />{{end}}

{{if .ARGS.total_balance_id}}
<div class="table-responsive">{{ with .Lists }}{{ range . }}{{if eq "total_balance_id" .which}}
<table class="table table-sm">
<thead> <tr> <th>Total Budget</th> <th>Spend Cap</th> <th>Impression Cap</th> <th>Click Cap</th> <th> </th> </tr> </thead>
<tbody> <tr>
<td>Delivery Cap: </td>
<td><input type=text size=8 name=limit_spend value="{{if .limit_spend}}{{ .limit_spend}}{{end}}" /></td>
<td><input type=text size=8 name=limit_imp value="{{if .limit_imp}}{{ .limit_imp}}{{end}}" /></td>
<td><input type=text size=8 name=limit_cli value="{{if .limit_cli}}{{ .limit_cli}}{{end}}" /></td>
<td><input type=hidden name=balance_id value={{.balance_id}} /><input class="btn btn-sm btn-primary" type=submit value="Save" /></td>
</tr> <tr>
<td>Consumed to Date: </td>
<td>{{ .current_spend}}</td>
<td>{{ .current_imp}}</td>
<td>{{ .current_cli}}</td>
<td></td>
</tr> </tobdy>
</table>{{end}}{{end}}{{end}}
</div>

{{else}}

<div class="table-responsive">
<table class="table table-sm">
<thead> <tr> <th>Total Budget</th> <th>Spend Cap</th> <th>Impression Cap</th> <th>Click Cap</th> <th> </th> </tr> </thead>
<tbody> <tr>
<td> </td>
<td><input type=text size=8 name=limit_spend /></td>
<td><input type=text size=8 name=limit_imp /></td>
<td><input type=text size=8 name=limit_cli /></td>
<td><button type=submit class="btn btn-primary btn-sm">Add</button></td>
</tr> </tobdy>
</table>
</div>
{{end}}

</form>

<form name=daily class="form" method=post action="balance">
{{if .ARGS.daily_balance_id}}<input type=hidden name=action value="update" />
{{else}}<input type=hidden name=action value="insert" />
<input type=hidden name=which value="daily_balance_id" />{{end}}
<input type=hidden name=entitytype_id value="{{ index .ARGS.entitytype_id 0}}" />
<input type=hidden name=campaign_id value="{{index .ARGS.campaign_id 0}}" />
<input type=hidden name=campaign_md5 value="{{index .ARGS.campaign_md5 0}}" />
<input type=hidden name=campaign_name value="{{index .ARGS.campaign_name 0 | urlquery}}" />{{if eq "42" (index .ARGS.entitytype_id 0) }}
<input type=hidden name=item_id value="{{index .ARGS.item_id 0}}" />
<input type=hidden name=item_md5 value="{{index .ARGS.item_md5 0}}" />
<input type=hidden name=item_name value="{{index .ARGS.item_name 0}}" />{{end}}

{{if .ARGS.daily_balance_id}}

<div class="table-responsive">{{ with .Lists }}{{ range . }}{{if eq "daily_balance_id" .which}}
<table class="table table-striped table-sm">
<thead> <tr><th>Daily Budget</th> <th>Spend Cap</th> <th>Impression Cap</th> <th>Click Cap</th><th> </th> </tr> </thead>
<tbody> <tr>
<td>Daily Cap</td>
<td><input type=text size=8 name=limit_spend value="{{if .limit_spend}}{{ .limit_spend}}{{end}}"></td>
<td><input type=text size=8 name=limit_imp value="{{if .limit_imp}}{{ .limit_imp}}{{end}}"></td>
<td><input type=text size=8 name=limit_cli value="{{if .limit_cli}}{{ .limit_cli}}{{end}}"></td>
<td><input type=hidden name=balance_id value={{.balance_id}}><input class="btn btn-sm btn-primary" type=submit value="Save"></td>
</tr> <tr>
<td>Consumed Today{{if .current_day}} (UTC {{.current_day}}){{end}}:</td>
<td>{{ .current_spend}}</td>
<td>{{ .current_imp}}</td>
<td>{{ .current_cli}}</td>
<td> </td>
</tr> </tobdy>
</table>{{end}}{{end}}{{end}}
</div>

{{else}}

<div class="table-responsive">
<table class="table table-striped table-sm">
<thead> <tr> <th>Daily Budget</th> <th>Spend Cap</th> <th>Impression Cap</th> <th>Click Cap</th> <th> </th> </tr> </thead>
<tbody> <tr>
<td> </td>
<td><input type=text size=8 name=limit_spend></td>
<td><input type=text size=8 name=limit_imp></td>
<td><input type=text size=8 name=limit_cli></td>
<td><button type=submit class="btn btn-primary btn-sm">Add</button></td>
</tr> </tobdy>
</table>
</div>

{{end}}

</form>
            </div>
        </div>
