{{ template "header" .}}
{{ template "pubheader" .}}

{{$item := index .Lists 0}}

          <div class="card">
            <div class="card-header">
              基本信息修改和跟新
            </div>
            <div class="card-body">

<form name=form1 class="form" action="pub" method=post>
<input type=hidden name=action value="update" />

<div class="form-group row">
    <label for="inputDomain" class="col-sm-3 col-form-label">域名:</label>
    <div class="col-sm-8">
        <input type=text class="form-control" name=domain value="{{$item.domain}}" />
    </div>
</div>

<div class="form-group row">
    <label for="inputFirstName" class="col-sm-3 col-form-label">姓名:</label>
    <div class="col-sm-2">
        <input type=text class="form-control" name=lastname value="{{$item.lastname}}" />
    </div>
    <div class="col-sm-6">
        <input type=text class="form-control" name=firstname value="{{$item.firstname}}" />
    </div>
</div>

<div class="form-group row">
    <label for="inputCompany" class="col-sm-3 col-form-label">公司名:</label>
    <div class="col-sm-8">
        <input type=text class="form-control" name=company value="{{$item.company}}" />
    </div>
</div>

<div class="form-group row">
    <label for="inputPhone" class="col-sm-3 col-form-label">电话号码:</label>
    <div class="col-sm-8">
        <input type=text class="form-control" name=phone value="{{$item.phone}}" />
    </div>
</div>

<div class="form-group row">
    <label for="inputStreet" class="col-sm-3 col-form-label">路牌和号码:</label>
    <div class="col-sm-8">
        <input type=text class="form-control" name=street value="{{$item.street}}" />
    </div>
</div>

<div class="form-group row">
    <label for="inputCity" class="col-sm-3 col-form-label">城市:</label>
    <div class="col-sm-6">
        <input type=text class="form-control" name=city value="{{$item.city}}" />
    </div>
    <div class="col-sm-2">
        <select class="form-control" name=state_id>
<option value=""></option>{{range .Other.address_states}}{{with .}}
<option {{if $item.state_id}}{{if eq .state_id $item.state_id}}selected{{end}}{{end}} value={{.state_id}}>{{.state_name}}</option>
{{end}}{{end}}</select>
    </div>
</div>

<div class="form-group row">
    <label for="inputState" class="col-sm-3 col-form-label"> </label>
    <div class="col-sm-8">
        <button type=submit class="btn btn-primary">保存并更新</button>
    </div>
</div>

</form>

</div>
</div>

{{ template "footer" }}

</body>
</html>
