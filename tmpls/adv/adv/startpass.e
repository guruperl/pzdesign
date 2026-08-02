{{ template "header" .}}
{{ template "advheader" .}}

<form name=form2 class="form" action="adv" method=post>
<input type=hidden name=action value="updatepass" />

  <div class="row">
                <div class="col-lg-12">
                <div class="panel panel-primary">
                    <div class="panel-heading">
                       Change Password
                    </div>
                    <div class="panel-body">

<div class="table-responsive">
<table class="table table-striped table-sm">
	<tbody>
<tr>
<td>Current Password:</td>
<td><input type=password name=passwd_old size=24 autocomplete="current-password" required /></td>
</tr>
<tr><td>New Password (at least 12 characters):</td>
<td><input type=password name=passwd size=24 autocomplete="new-password" minlength=12 required /></td>
</tr>
<tr>
<td>Confirm New:</td>
<td><input type=password name=confirm size=24 autocomplete="new-password" minlength=12 required /></td>
</tr>
<tr>
<td colspan=2><input  class="btn btn-primary" type=submit value="Change Now" /></td>
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
