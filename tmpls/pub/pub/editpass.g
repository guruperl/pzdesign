{{ template "header" .}}
{{ template "pubheader" .}}

          <div class="card">
            <div class="card-header">
              修改密码
            </div>
            <div class="card-body">

<form class="form" action="pub" method=post>
<input type=hidden name=action value="updatepass" />

<div class="form-group row">
    <label for="inputCurrentPass" class="col-sm-3 col-form-label">当前密码：</label>
    <div class="col-sm-8">
        <input type=password class="form-control" name=passwd_old placeholder="输入当前密码" />
    </div>
</div>

<div class="form-group row">
    <label for="inputNewPass" class="col-sm-3 col-form-label">新密码：</label>
    <div class="col-sm-8">
        <input type=password class="form-control" name=passwd placeholder="输入新密码" />
    </div>
</div>

<div class="form-group row">
    <label for="inputConfirm" class="col-sm-3 col-form-label">确认新密码：</label>
    <div class="col-sm-8">
        <input type=password class="form-control" name=confirm placeholder="再次输入新密码" />
    </div>
</div>

<div class="form-group row">
    <label for="inputNewPass" class="col-sm-3 col-form-label"> </label>
    <div class="col-sm-8">
        <button type=submit class="btn btn-primary">保存新密码</button>
    </div>
</div>

</form>
</div>
</div>

{{ template "footer" }}

</body>
</html>
