{{ template "header" .}}
{{ template "advheader" .}}

{{range $item := .Lists}}

<form name=form1 class="form" action="adv" method=post>
<input type=hidden name=action value="update" />

<div class="row">
                <div class="col-lg-12">
                <div class="panel panel-primary">
                    <div class="panel-heading">
                        <h3>修改个人信息</h3>
                    </div>
                    <div class="panel-body">

<div style= 'font-size: 17px;'>
<div class="table-responsive">
<table class="table table-striped table-sm">
    <tbody>
<tr>
<td>姓名 :</td>
<td><input type=text name=firstname value="{{if $item.firstname}}{{$item.firstname}}{{end}}" size=10 />
<input type=text name=lastname value="{{if $item.lastname}}{{$item.lastname}}{{end}}" size=10 /></td>
</tr>
<tr>
<td>公司名称:</td>
<td><input type=text name=company value="{{if $item.company}}{{$item.company}}{{end}}" size=10 /></td>
</tr>
<tr>
<td>手机号:</td>
<td><input type=text name=phone value="{{if $item.phone}}{{$item.phone}}{{end}}" size=10 /></td>
</tr>
<tr>
<td>联系地址:</td>
<td><input type=text name=street value="{{if $item.street}}{{$item.street}}{{end}}" size=10 />
<input type=text name=city value="{{if $item.city}}{{$item.city}}{{end}}" size=10 />
<input type=text name=state_id "{{if $item.state_id}}{{$item.state_id}}{{end}}" size=10 /></td>
</tr>
<tr>
<td colspan=2><input type=submit value="保存" /></td>
</tr>
    </tbody>
</table>
</div>
                
                </div>
            </div>
        </div>
    </div>
 </div>


</form>
{{end}}

{{ template "footer" }}
