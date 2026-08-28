{{ template "header" .}}
{{ template "bidderheader" .}}
{{$item := index .Lists 0}}

<form method="post" action="bidder?action=update">
  <input type="hidden" name="bidder_id" value="{{$item.bidder_id}}">
  <div class="form-group">
    <label>Advertiser</label>
    <p class="form-control-static">{{$item.adv_id}} {{$item.adv_email}}</p>
  </div>
  <div class="form-group">
    <label>Name</label>
    <input class="form-control" name="bidder_name" value="{{$item.bidder_name}}" required>
  </div>
  <div class="form-group">
    <label>Endpoint URL</label>
    <input class="form-control" type="url" name="endpoint_url" value="{{$item.endpoint_url}}" required>
  </div>
  <div class="form-group">
    <label>OpenRTB Version</label>
    <input class="form-control" name="openrtb_version" value="{{$item.openrtb_version}}" readonly>
    <p class="help-block">The current partner contract is fixed at OpenRTB 2.5.</p>
  </div>
  <div class="form-group">
    <label>Buyer Seat (Optional)</label>
    <input class="form-control" name="seat" value="{{$item.seat}}">
  </div>
  <div class="form-group">
    <label>Request Timeout (Milliseconds)</label>
    <input class="form-control" type="number" min="1" max="5000" name="timeout_ms" value="{{$item.timeout_ms}}">
  </div>
  <div class="form-group">
    <label>Credential Environment-Variable Name</label>
    <input class="form-control" name="credential_ref" value="{{$item.credential_ref}}">
    <p class="help-block">Enter only the variable name, such as BIDDER_HEADERS; credential values must not be written to the database.</p>
  </div>
  <div class="form-group">
    <label>Credential Status</label>
    <select class="form-control" name="credential_status">
      <option value="Missing"{{if eq $item.credential_status "Missing"}} selected{{end}}>Missing</option>
      <option value="Pending"{{if eq $item.credential_status "Pending"}} selected{{end}}>Pending Approval</option>
      <option value="Active"{{if eq $item.credential_status "Active"}} selected{{end}}>Active</option>
      <option value="Disabled"{{if eq $item.credential_status "Disabled"}} selected{{end}}>Disabled</option>
    </select>
  </div>
  <div class="form-group">
    <label>Enabled</label>
    <select class="form-control" name="active">
      <option value="No"{{if eq $item.active "No"}} selected{{end}}>Disabled</option>
      <option value="Yes"{{if eq $item.active "Yes"}} selected{{end}}>Enabled</option>
    </select>
  </div>
  <div class="form-row">
    <div class="form-group col-md-4">
      <label>Synthetic Campaign</label>
      <p class="form-control-static">{{$item.synthetic_campaign_id}}</p>
    </div>
    <div class="form-group col-md-4">
      <label>Synthetic Ad Group</label>
      <p class="form-control-static">{{$item.synthetic_item_id}}</p>
    </div>
    <div class="form-group col-md-4">
      <label>Synthetic Creative</label>
      <p class="form-control-static">{{$item.synthetic_creative_id}}</p>
    </div>
  </div>
  <button type="submit" class="btn btn-primary">Save</button>
  <a class="btn btn-secondary" href="bidder?action=topics">Cancel</a>
</form>

<hr>
<form method="post" action="bidder?action=approve">
  <input type="hidden" name="bidder_id" value="{{$item.bidder_id}}">
  <div class="form-group">
    <label>Approved Credential Environment-Variable Name</label>
    <input class="form-control" name="credential_ref" value="{{$item.credential_ref}}" required>
    <p class="help-block">Approval stores only the variable name. First inject the corresponding JSON request headers securely into the canary service environment.</p>
  </div>
  <button type="submit" class="btn btn-success">Approve and Enable</button>
</form>

{{ template "footer" .}}
