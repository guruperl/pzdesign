{{ template "header" .}}
{{ template "attrnameheader" .}}


<div class="row">
         <div class="col-lg-12">
                <div class="panel panel-primary">
                    <div class="panel-heading">
                      自定义标签列表
                    </div>
                    <div class="panel-body">


<div class="table-responsive">
<table class="table table-striped table-sm">
              <thead>
                <tr>
<th>标签名</th>
<th>标签对应值</th>
<th></th>
</tr>
</thead>
<tbody>{{with .Lists}}{{range .}}
<tr>
<td>{{.attrname}}</td>
<td>{{.value}}</td>
<td><a href="attrname?action=delete&attrname_id={{.attrname_id }}">删除</a></td>
</tr>
{{end}}{{end}}</tbody>
<tr>
<form class="form" method=post action=attrname>
<input type=hidden name=action value="insert" />
<td><input type=text name=attrname size=10 maxlength=10 /></td>
<td><input type=text name=value /> 标签值请用英文逗号(,)隔开</td>
<td><button type=submit class="btn btn-primary btn-sm">添加标签</button></td>
</form>
</tr>
</table>
</div>
                </div>
            </div>
        </div>
    </div>

{{template "footer"}}
