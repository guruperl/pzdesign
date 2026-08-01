{{ template "header" .}}
{{ template "advheader" .}}

{{range $item := .Lists}}

<form name=form1 class="form" action="adv" method=post>
<input type=hidden name=action value="update" />

		<div class="row">
			<div class="col-lg-12">
				<div class="panel panel-primary">
                    <div class="panel-heading">
                        Change Personal Profile
                    </div>
                    <div class="panel-body">

<div class="table-responsive">
<table class="table table-striped table-sm">
    <tbody>
<tr>
<td>Firstname Lastname :</td>
<td><input type=text name=firstname value="{{if $item.firstname}}{{$item.firstname}}{{end}}" size=10 />
<input type=text name=lastname value="{{if $item.lastname}}{{$item.lastname}}{{end}}" size=10 /></td>
</tr>
<tr>
<td>Company:</td>
<td><input type=text name=company value="{{if $item.company}}{{$item.company}}{{end}}" size=10 /></td>
</tr>
<tr>
<td>Phone:</td>
<td><input type=text name=phone value="{{if $item.phone}}{{$item.phone}}{{end}}" size=10 /></td>
</tr>
<tr>
<td>Street, City, State:</td>
<td><input type=text name=street value="{{if $item.street}}{{$item.street}}{{end}}" size=10 />
<input type=text name=city value="{{if $item.city}}{{$item.city}}{{end}}" size=10 />
<input type=text name=state_id value="{{if $item.state_id}}{{$item.state_id}}{{end}}" size=10 /></td>
</tr>
<tr>
<td colspan=2><input  class="btn btn-primary" type=submit value="Update" /></td>
</tr>
    </tbody>
</table>
</div>
                
            		</div>
        		</div>
    		</div>
 		</div>


</form>
{{end}}

{{ template "footer" }}
