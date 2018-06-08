{{ template "header" .}}
{{ template "advheader" .}}

<form name=form2 class="form" action="adv" method=post>
<input type=hidden name=action value="updatepass" />

  <div class="row">
                <div class="col-lg-12">
                <div class="panel panel-primary">
                    <div class="panel-heading">
                       修改密码
                    </div>
                    <div class="panel-body">

<div class="table-responsive">
<table class="table table-striped table-sm">
	<tbody>
<tr>
<td>请输入当前密码:</td>
<td><input type=password name=passwd_old size=10 /></td>
</tr>
<tr><td>请输入新密码:</td>
<td><input type=password name=passwd size=10 /></td>
</tr>
<tr>
<td>确认新密码:</td>
<td><input type=password name=confirm size=10 /></td>
</tr>
<tr>
<td colspan=2><input  class="btn btn-primary" type=submit value="保存" /></td>
</tr>
	</tbody>
</table>
</div>

              </div>
            </div>
        </div>
    </div>

</form>

{{ template "footer" }}
