{{ template "header" .}}
{{ template "chacheader" .}}

        <div class="row">
            <div class="col-lg-12">
                <div class="panel panel-primary">
                    <div class="panel-heading">
                        {{index .ARGS.campaign_name 0}}
                    </div>
                    <div class="panel-body">

<form class="form" method=post action="chac">
<input type=hidden name=campaign_id value="{{index .ARGS.campaign_id 0}}" />
<input type=hidden name=campaign_md5 value="{{index .ARGS.campaign_md5 0}}" />
<input type=hidden name=campaign_name value="{{index .ARGS.campaign_name 0}}" />
<input type=hidden name=entitytype_id value="41" />
<input type=hidden name=action value="update" />

<div class="table-responsive">
<table class="table table-striped table-sm">
              <thead>
                <tr>
                  <th>行业名</th>
                  <th>活动所属行业</th>
                  <th>黑白名单设置<br />
<input type=radio name=channel_order value="Black" {{if eq "Black" (index .ARGS.channel_order 0)}}checked{{end}} />黑名单
<input type=radio name=channel_order value="White" {{if eq "White" (index .ARGS.channel_order 0)}}checked{{end}} />白名单
</th>
                </tr>
              </thead>
              <tbody>{{ with .Lists }}{{ range . }}
<tr><td>{{.channel_name_g}}</td>
<td><input name=belong_ids type=checkbox {{if .chbelong_id}}checked{{end}} value="{{.channel_id}}" /></td>
<td><input name=ac_ids type=checkbox {{if .chac_id}}checked{{end}} value="{{.channel_id}}" /></td>
</tr>{{end}}{{end}}
</tobdy>
</table>
</div>
<input class="btn btn-primary" type=submit value=" 保存并更新 " />
</form>

</div>
</div>
</div>
</div>

{{ template "footer" }}
