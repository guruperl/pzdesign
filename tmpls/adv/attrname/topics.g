{{ template "header" .}}
{{ template "attrnameheader" .}}

<div class="row">
         <div class="col-lg-12">
                <div class="panel panel-primary">
                    <div class="panel-heading">
                      上传标签
                    </div>
                    <div class="panel-body">

<form name=form1 class="form" method=post action=attrname enctype="multipart/form-data">
<input type=hidden name=action value="upload" />
<div class="form-group row">
    <label for="inputContent" class="col-sm-12 col-form-label">
    上传文件每行一条，不要超过1000万条。</label>
</div>
<div class="form-group row">
    <label for="inputContent" class="col-sm-1 col-form-label">文件类别</label>  
    <div class="col-sm-2">
        <select class=form-control" size=1 name=marker>
            <option value="buyerid">Buyer ID</option>
            <option value="userid">User ID</option>
            <option value="ip">IP</option>
            <option value="did">设备 ID</option>
            <option value="dpid">设备平台 ID</option>
            <option value="mac">MAC</option>
        </select>
    </div>
    <div class="col-sm-3">
        <input type=file class="form-control" name="media_1" />
    </div>
    <div class="col-sm-2">
        <button class="btn btn-primary btn-sm btn-block" type=submit>上传</button>
    </div>
    <div class="col-sm-4">
    </div>
</div>
</form>
                    </div>
                </div>
        </div>
</div>


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
<td><a onClick="return (confirm('确认删除此标签？')) ? true : false;" href="attrname?action=delete&attrname_id={{.attrname_id }}">删除</a></td>
</tr>
{{end}}{{end}}</tbody>
<tr>
<form name=name2 class="form" method=post action=attrname>
<input type=hidden name=action value="insert" />
<td><input type=text name=attrname size=10 maxlength=10 /></td>
<td><input type=text name=value size=30 /> 多值用英文逗号(,)隔开</td>
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
