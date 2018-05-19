{{ template "header" .}}
{{ template "acheader" .}}

<div class="container">
        <div class="row">
            <div class="col-lg-11">
                <div class="panel panel-primary">
                    <div class="panel-heading">
                      

<form name=f1 class="form" method=post action="ac">
<input type=hidden name=action value="updateOrder" />
{{if eq "41" (index .ARGS.entitytype_id 0)}}
<input type=hidden name=campaign_id value="{{index .ARGS.campaign_id 0}}" />
<input type=hidden name=campaign_md5 value="{{index .ARGS.campaign_md5 0}}" />
<input type=hidden name=campaign_name value="{{index .ARGS.campaign_name 0}}" />
<input type=hidden name=entitytype_id value="41" />
<h3>{{index .ARGS.campaign_name 0}}</h3>{{else}}
<input type=hidden name=entitytype_id value="4" />
<font size = 4 >{{index .ARGS.a_company 0}}</font>{{end}}

                    </div>
                    <div class="panel-body">

 <div style= 'font-size: 17px;'>
黑白名单设置: <input type=radio name=access_order value="Black" {{if eq `Black` (index .ARGS.access_order 0)}}checked{{end}} />黑名单
<input type=radio name=access_order value="White" {{if eq `White` (index .ARGS.access_order 0)}}checked{{end}} />白名单
{{if eq `41` (index .ARGS.entitytype_id 0)}}<input type=radio name=access_order value="Inherit" {{if eq `Inherit` (index .ARGS.access_order 0)}}checked{{end}} />系统默认{{end}}
<input onClick="return (confirm('这将删除所有现有的访问列表和重置逻辑。您确定要>继续吗？')) ? true : false;" type=submit value=" 保存 " />
</form>

{{if ne `Inherit` (index .ARGS.access_order 0)}}


<div class="table-responsive">
<table class="table table-striped table-sm">
              <thead>
                <tr>
                  <th>网站名</th>
                  <th>URL链接</th>
                  <th></th>
                </tr>
              </thead>
              <tbody>{{range $item := .Lists }}
<tr><td>{{$item.site_name}}</td>
<td>{{$item.site_url}}</td>
<td><a href="ac?action=delete&ac_id={{.ac_id}}&{{if eq "41" (index $.ARGS.entitytype_id 0)}}campaign_id={{index $.ARGS.campaign_id 0}}&campaign_md5={{index $.ARGS.campaign_md5 0}}&campaign_name={{index $.ARGS.campaign_name 0 | urlquery}}&entitytype_id=41{{else}}entitytype_id=4{{end}}">删除</a></td>
</tr>{{end}}
</tobdy>
</table>
</div>

<form name=f2 class="form" method=post action="ac">
<input type=hidden name=action value="insert" />
<input type=hidden name=othertype_id value="31" />
{{if eq "41" (index .ARGS.entitytype_id 0)}}
<input type=hidden name=campaign_id value="{{index .ARGS.campaign_id 0}}" />
<input type=hidden name=campaign_md5 value="{{index .ARGS.campaign_md5 0}}" />
<input type=hidden name=campaign_name value="{{index .ARGS.campaign_name 0}}" />
<input type=hidden name=entitytype_id value="41" />{{else}}
<input type=hidden name=entitytype_id value="4" />{{end}}
新增网站ID: <input type=text name=other_id size=12 />
<input type=submit value=" 确定 " />
</form>
 </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>

{{end}}

{{ template "footer" }}
