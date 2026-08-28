{{ template "header" .}}
{{ template "attrnameheader" .}}

<div class="row">
         <div class="col-lg-12">
                <div class="panel panel-primary">
                    <div class="panel-heading">
                      Upload Identifiers
                    </div>
                    <div class="panel-body">

<form name=form1 class="form" method=post action=attrname enctype="multipart/form-data">
<input type=hidden name=action value="upload" />
<div class="form-group row">
    <label for="inputContent" class="col-sm-12 col-form-label">
    Put one identifier on each line of the upload file, with no more than 10 million lines.</label>
</div>
<div class="form-group row">
    <label for="inputContent" class="col-sm-1 col-form-label">Identifier Type</label>
    <div class="col-sm-2">
        <select class="form-control" size=1 name=marker>
            <option value="buyeruid">Buyer UID</option>
            <option value="userid">User ID</option>
            <option value="ip">IP</option>
            <option value="did">Device ID</option>
            <option value="dpid">Device Platform ID</option>
            <option value="mac">MAC</option>
        </select>
    </div>
    <div class="col-sm-3">
        <input type=file class="form-control" name="media_1" />
    </div>
    <div class="col-sm-2">
        <button class="btn btn-primary btn-sm btn-block" type=submit>Upload</button>
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
                      Custom Attributes
                    </div>
                    <div class="panel-body">


<div class="table-responsive">
<table class="table table-striped table-sm">
              <thead>
                <tr>
<th>Attribute Name</th>
<th>Attribute Values</th>
<th></th>
</tr>
</thead>
<tbody>{{with .Lists}}{{range .}}
<tr>
<td>{{.attrname}}</td>
<td>{{.value}}</td>
<td><a onClick="return (confirm('Delete this attribute?')) ? true : false;" href="attrname?action=delete&attrname_id={{.attrname_id }}">Delete</a></td>
</tr>
{{end}}{{end}}</tbody>
<tr>
<form name=name2 class="form" method=post action=attrname>
<input type=hidden name=action value="insert" />
<td><input type=text name=attrname size=10 maxlength=10 /></td>
<td><input type=text name=value size=30 /> Separate multiple values with commas (,)</td>
<td><button type=submit class="btn btn-primary btn-sm">Add Attribute</button></td>
</form>
</tr>
</table>
</div>
                </div>
            </div>
        </div>
    </div>

{{template "footer"}}
