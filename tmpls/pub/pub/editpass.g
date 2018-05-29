{{ template "header" .}}
{{ template "pubheader" .}}

          <div class="card">
            <div class="card-header">
              Change Password
            </div>
            <div class="card-body">

<form class="form" action="pub" method=post>
<input type=hidden name=action value="updatepass" />

<div class="form-group row">
    <label for="inputCurrentPass" class="col-sm-3 col-form-label">Current Password:</label>
    <div class="col-sm-8">
        <input type=password class="form-control" name=passwd_old placeholder="Old password" />
    </div>
</div>

<div class="form-group row">
    <label for="inputNewPass" class="col-sm-3 col-form-label">New Password:</label>
    <div class="col-sm-8">
        <input type=password class="form-control" name=passwd placeholder="New password" />
    </div>
</div>

<div class="form-group row">
    <label for="inputConfirm" class="col-sm-3 col-form-label">Confirm Password:</label>
    <div class="col-sm-8">
        <input type=password class="form-control" name=confirm placeholder="New password Again" />
    </div>
</div>

<div class="form-group row">
    <label for="inputNewPass" class="col-sm-3 col-form-label"> </label>
    <div class="col-sm-8">
        <button type=submit class="btn btn-primary">Save and Update</button>
    </div>
</div>

</form>
</div>
</div>

{{ template "footer" }}

</body>
</html>

