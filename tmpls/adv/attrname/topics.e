{{ template "header" .}}
{{ template "attrnameheader" .}}

<div class="row">
                <div class="col-lg-12">
                <div class="panel panel-primary">
                    <div class="panel-heading">
                       <font size = 4 >Current List</font>
                    </div>
                    <div class="panel-body">

<div style= 'font-size: 17px;'>
<div class="table-responsive">
<table class="table table-striped table-sm">
              <thead>
                <tr>
<th>Attribute</th>
<th>Assigned Values</th>
<th></th>
</tr>
</thead>
<tbody>{{with .Lists}}{{range .}}
<tr>
<td>{{.attrname}}</td>
<td>{{.value}}</td>
<td><a href="attrname?action=delete&attrname_id={{.attrname_id }}">Del</a></td>
</tr>
{{end}}{{end}}</tbody>
<tr>
<form class="form" method=post action=attrname>
<input type=hidden name=action value="insert" />
<td><input type=text name=attrname size=10 maxlength=10 /></td>
<td><input type=text name=value /> separated by comma</td>
<td><input type=submit value="Add New" /></td>
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
