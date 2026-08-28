{{ template "header" .}}
{{ template "pubheader" .}}

{{$item := index .Lists 0}}

          <div class="card">
            <div class="card-header">
              Update Basic Account Information
            </div>
            <div class="card-body">

<form name=form1 class="form" action="pub" method=post>
<input type=hidden name=action value="update" />

<div class="form-group row">
    <label for="inputDomain" class="col-sm-3 col-form-label">Domain:</label>
    <div class="col-sm-8">
        <input type=text class="form-control" name=domain value="{{$item.domain}}" />
    </div>
</div>

<div class="card mb-3">
  <div class="card-header">Seller Transparency Information</div>
  <div class="card-body">
    <p>These fields support <code>sellers.json</code> / <code>source.schain</code> reconciliation and disclosure. They do not change the settlement owner of this publisher account. Changes require a new platform review.</p>
    <div class="form-group row">
      <label class="col-sm-3 col-form-label">Seller ID:</label><div class="col-sm-3"><input class="form-control" name="seller_id" maxlength="64" value="{{$item.seller_id}}" /></div>
      <label class="col-sm-2 col-form-label">Relationship:</label><div class="col-sm-4"><select class="form-control" name="seller_type"><option value="Publisher" {{if eq $item.seller_type "Publisher"}}selected{{end}}>Direct Publisher</option><option value="Intermediary" {{if eq $item.seller_type "Intermediary"}}selected{{end}}>Sales Agent / Reseller</option></select></div>
    </div>
    <div class="form-group row">
      <label class="col-sm-3 col-form-label">Advertising System Domain (ASI):</label><div class="col-sm-3"><input class="form-control" name="seller_asi" value="{{$item.seller_asi}}" placeholder="w8m.com" /></div>
      <label class="col-sm-2 col-form-label">Business Domain:</label><div class="col-sm-4"><input class="form-control" name="seller_domain" value="{{$item.seller_domain}}" /></div>
    </div>
    <div class="form-group row mb-0">
      <label class="col-sm-3 col-form-label">Public Business Name:</label><div class="col-sm-5"><input class="form-control" name="seller_name" maxlength="255" value="{{$item.seller_name}}" /></div>
      <div class="col-sm-4 col-form-label">Review status: {{if eq $item.seller_authorized "Yes"}}Reviewed{{else}}Pending review{{end}}</div>
    </div>
  </div>
</div>

<div class="form-group row">
    <label for="inputFirstName" class="col-sm-3 col-form-label">Name:</label>
    <div class="col-sm-2">
        <input type=text class="form-control" name=lastname value="{{$item.lastname}}" />
    </div>
    <div class="col-sm-6">
        <input type=text class="form-control" name=firstname value="{{$item.firstname}}" />
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
    <label for="inputStreet" class="col-sm-3 col-form-label">Street and Number:</label>
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
<option {{if $item.state_id}}{{if eq .state_id $item.state_id}}selected{{end}}{{end}} value={{.state_id}}>{{.state_name}}</option>
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
