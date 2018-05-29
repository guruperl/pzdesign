{{ template "header" .}}
{{ template "pubheader" .}}

{{$item := index .Lists 0}}

          <div class="card">
            <div class="card-header">
              Edit Basic Information
            </div>
            <div class="card-body">

<form name=form1 class="form" action="pub" method=post>
<input type=hidden name=action value="update" />


<div class="form-group row">
    <label for="inputFirstName" class="col-sm-3 col-form-label">First Name:</label>
    <div class="col-sm-8">
        <input type=text class="form-control" name=firstname value="{{$item.firstname}}" />
    </div>
</div>

<div class="form-group row">
    <label for="inputLastName" class="col-sm-3 col-form-label">Last Name:</label>
    <div class="col-sm-8">
        <input type=text class="form-control" name=lastname value="{{$item.lastname}}" />
    </div>
</div>

<div class="form-group row">
    <label for="inputCompany" class="col-sm-3 col-form-label">Company:</label>
    <div class="col-sm-8">
        <input type=text class="form-control" name=company value="{{$item.company}}" />
    </div>
</div>

<div class="form-group row">
    <label for="inputPhone" class="col-sm-3 col-form-label">Phone Number:</label>
    <div class="col-sm-8">
        <input type=text class="form-control" name=phone value="{{$item.phone}}" />
    </div>
</div>

<div class="form-group row">
    <label for="inputStreet" class="col-sm-3 col-form-label">Street:</label>
    <div class="col-sm-8">
        <input type=text class="form-control" name=street value="{{$item.street}}" />
    </div>
</div>

<div class="form-group row">
    <label for="inputCity" class="col-sm-3 col-form-label">City:</label>
    <div class="col-sm-6">
        <input type=text class="form-control" name=city value="{{$item.city}}" />
    </div>
    <div class="col-sm-2">
        <select class="form-control" name=state_id>
<option value=""></option>{{range .Other.address_states}}{{with .}}
<option {{if eq .state_id $item.state_id}}selected{{end}} value={{.state_id}}>{{.state_name}}</option>
{{end}}{{end}}</select>
    </div>
</div>

<div class="form-group row">
    <label for="inputState" class="col-sm-3 col-form-label"> </label>
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
