{{ template "header" .}}
{{ template "acheader" .}}

{{$args := .ARGS}}

          <div class="card">
            <div class="card-header">
              <em>{{if eq "31" (index .ARGS.entitytype_id 0)}}广告位组{{index .ARGS.site_name 0}}{{else}}媒体商户{{index .ARGS.p_company 0}}{{end}}</em>审核
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

黑白逻辑: <input type=radio name=access_order value="Black" {{if eq `Black` (index .ARGS.access_order 0)}}checked{{end}} />黑名单
<input type=radio name=access_order value="White" {{if eq `White` (index .ARGS.access_order 0)}}checked{{end}} />白名单
{{if eq `31` (index .ARGS.entitytype_id 0)}}<input type=radio name=access_order value="Inherit" {{if eq `Inherit` (index .ARGS.access_order 0)}}checked{{end}} />默认{{end}}
<button class="btn btn-sm btn-primary" type=submit onClick="return (confirm('This will delete all existing access list and reset logic. Do you want to continue?')) ? true : false;">更新逻辑次序</button>
</form>
            </div>
          </div>




{{if .Lists}}
          <div class="card">
            <div class="card-header">
              <em>{{if eq "31" (index .ARGS.entitytype_id 0)}}广告位组{{index .ARGS.site_name 0}}{{else}}商户{{index .ARGS.p_company 0}}{{end}}</em>目前的黑白名单
            </div>
            <div class="card-body">

<div class="table-responsive">
<table class="table table-striped table-sm">
              <thead>
                <tr>
                  <th>广告商公司</th>
                  <th>URL</th>
                  <th>广告活动</th>
                  <th></th>
                </tr>
              </thead>
              <tbody>{{ with .Lists }}{{ range . }}
<tr><td>{{.company}}</td>
<td>{{.url}}</td>
<td>{{.campaign_name}}</td>
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
              添加审核名单
            </div>
            <div class="card-body">
<form name=f2 class="form" method=post action="ac">
<input type=hidden name=action value="insert" />
{{if eq "31" (index .ARGS.entitytype_id 0)}}
<input type=hidden name=site_id value="{{index .ARGS.site_id 0}}" />
<input type=hidden name=site_md5 value="{{index .ARGS.site_md5 0}}" />
<input type=hidden name=site_name value="{{index .ARGS.site_name 0}}" />
<input type=hidden name=entitytype_id value="31" />{{else}}
<input type=hidden name=entitytype_id value="3" />{{end}}
选择：<input type=radio name=othertype_id value="4" />广告商 <input type=radio name=othertype_id value="41" />广告活动
其代码: <input type=text name=other_id size=12 />
<button type=submit class="btn btn-sm btn-primary">添加</button>
</form>
            </div>
          </div>

          <div class="card">
            <div class="card-header">
              <a class="btn btn-primary" href="ac?action=startnew&entitytype_id={{index .ARGS.entitytype_id 0}}">在线查看广告主</a>
            </div>
		  </div>


{{ template "footer" }}
</body>
</html>

