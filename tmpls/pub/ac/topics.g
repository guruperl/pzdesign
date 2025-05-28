{{ template "header" .}}
{{ template "acheader" .}}

{{$args := .ARGS}}

          <div class="card">
            <div class="card-header">
				<em>{{if eq "31" (index .ARGS.entitytype_id 0)}}广告位组{{index .ARGS.site_name 0}}{{else}}流量源{{index .ARGS.p_company 0}}{{end}}</em> 的审核逻辑设置
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
<input type=radio name=access_order value="Black" {{if eq `Black` (index .ARGS.access_order 0)}}checked{{end}} />黑名单（不接受黑名单上商家和活动，其余均接受）
<input type=radio name=access_order value="White" {{if eq `White` (index .ARGS.access_order 0)}}checked{{end}} />白名单（只接受白名单上的商家和活动）
{{if eq `31` (index .ARGS.entitytype_id 0)}}<input type=radio name=access_order value="Inherit" {{if eq `Inherit` (index .ARGS.access_order 0)}}checked{{end}} />默认{{end}}
	</div>
</div>
<div class=row>
	<div class="col-12">
		<button class="btn btn-primary" type=submit onClick="return (confirm('确信更改审核逻辑吗？本操作将删除所有已有逻辑。')) ? true : false;">更新逻辑次序</button>
		<a class="btn btn-success" href="ac?action=startnew&entitytype_id={{index .ARGS.entitytype_id 0}}">查看所有广告活动</a>
	</div>
</div>
</form>
            </div>
          </div>


          <div class="card">
{{if .Lists}}
            <div class="card-header">
              <em>{{if eq "31" (index .ARGS.entitytype_id 0)}}广告位组{{index .ARGS.site_name 0}}{{else}}商户{{index .ARGS.p_company 0}}{{end}}</em>目前的黑白名单
            </div>
            <div class="card-body">

<div class="table-responsive">
<table class="table table-striped table-sm">
              <thead>
                <tr>
                  <th>商家公司</th>
                  <th>公司网址URL</th>
                  <th>广告活动名称</th>
                  <th></th>
                </tr>
              </thead>
              <tbody>{{ with .Lists }}{{ range . }}
<tr><td>{{.company}}</td>
<td>{{.url}}</td>
<td>{{.campaign_name}}</td>
<td><a onClick="return (confirm('确认删除此栏目？')) ? true : false;" class="btn btn-sm btn-danger" href="ac?action=delete&ac_id={{.ac_id}}&{{if eq (index $args.entitytype_id 0) "3"}}entitytype_id=3{{else}}{{ print `entytitype_id=31&site_id=` (index $args.site_id 0) `&site_md5=` (index $args.site_md5 0) `&site_name=` (index $args.site_name 0 | urlquery) }}{{end}}">删除</a></td>
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
直接添加审核名单：<input class="form-inline" type=radio name=othertype_id value="4" />商家 <input type=radio name=othertype_id value="41" />广告活动
其代码: <input class="form-inline" type=text name=other_id size=12 />
<button type=submit class="btn btn-sm btn-primary">添加</button>
</form>
            </div>
          </div>

{{ template "footer" }}
</body>
</html>

