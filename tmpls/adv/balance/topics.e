{{ template "header" .}}
{{ template "balanceheader" .}}

        <div class="row">
            <div class="col-lg-12">
                <div class="panel panel-primary">
                    <div class="panel-heading">
						Total Budget
                    </div>
                    <div class="panel-body">
						<p class="text-muted">Spend, impression, and click limits are hard delivery limits. Zero or blank means unlimited. Lowering a limit to the consumed value stops later auctions within the documented cache propagation window.</p>

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
<table class="table table-striped table-condensed">
<thead> <tr> <th> </th> <th>Budget</th> <th>Impressions</th> <th>Clicks</th> <th> </th> </tr> </thead>
<tbody> <tr>
<td>Limit: </td>
<td><input type=text size=8 name=limit_spend value="{{ .limit_spend}}" /></td>
<td><input type=text size=8 name=limit_imp value="{{ .limit_imp}}" /></td>
<td><input type=text size=8 name=limit_cli value="{{ .limit_cli}}" /></td>
<td><input type=hidden name=balance_id value={{.balance_id}} /><input class="btn btn-sm" type=submit value="Update" /></td>
</tr> <tr>
<td>Consumed: </td>
<td>{{ .current_spend}}</td>
<td>{{ .current_imp}}</td>
<td>{{ .current_cli}}</td>
<td></td>
</tr> </tobdy>
</table>{{end}}{{end}}{{end}}
</div>

{{else}}

<div class="table-responsive">
<table class="table table-striped table-condensed">
<thead> <tr> <th>Budget</th> <th>Impressions</th> <th>Clicks</th> <th> </th> </tr> </thead>
<tbody> <tr>
<td><input type=text size=8 name=limit_spend /></td>
<td><input type=text size=8 name=limit_imp /></td>
<td><input type=text size=8 name=limit_cli /></td>
<td><button type=submit class="btn btn-primary btn-sm">Add New</button></td>
</tr> </tobdy>
</table>
</div>
{{end}}

</form>
			</div>
		</div>
	</div>
</div>

        <div class="row">
            <div class="col-lg-12">
                <div class="panel panel-primary">
                    <div class="panel-heading">
						Daily Budget
                    </div>
                    <div class="panel-body">

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
<thead> <tr><th> </th> <th>Budget</th> <th>Impressions</th> <th>Clicks</th><th> </th> </tr> </thead>
<tbody> <tr>
<td>Daily limit</td>
<td><input type=text size=8 name=limit_spend value="{{ .limit_spend}}"></td>
<td><input type=text size=8 name=limit_imp value="{{ .limit_imp}}"></td>
<td><input type=text size=8 name=limit_cli value="{{ .limit_cli}}"></td>
<td><input type=hidden name=balance_id value={{.balance_id}}><input class="btn btn-sm" type=submit value="Update"></td>
</tr> <tr>
<td>Daily consumed{{if .current_day}} (UTC {{.current_day}}){{end}}:</td>
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
<thead> <tr> <th>Budget</th> <th>Impressions</th> <th>Clicks</th> <th> </th> </tr> </thead>
<tbody> <tr>
<td><input type=text size=8 name=limit_spend></td>
<td><input type=text size=8 name=limit_imp></td>
<td><input type=text size=8 name=limit_cli></td>
<td><button type=submit class="btn btn-primary btn-sm">Add New</button></td>
</tr> </tobdy>
</table>
</div>

{{end}}

</form>
			</div>
		</div>
	</div>
</div>

{{ template "footer" }}
