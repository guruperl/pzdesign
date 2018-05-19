{{ template "header" .}}
{{ template "attrnameheader" .}}



<div class="row">
                <div class="col-lg-12">
                <div class="panel panel-primary">
                    <div class="panel-heading">
                      <font size = 4 >自定义标签列表</font>
                    </div>
                    <div class="panel-body">
                    <div style= 'font-size: 17px;'>


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
<td><input type=text name=value /> 标签值请用“,”隔开</td>
<td><input type=submit value="新增标签" /></td>
</form>
</tr>
</table>

</div>
</div>
                   </div>
                </div>
            </div>
        </div>
    </div>

{{template "footer"}}
