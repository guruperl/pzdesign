{{ template "header" .}}
{{ template "bidderheader" .}}
{{$item := index .Lists 0}}

<div class="row">
  <div class="col-lg-8">
    <div class="panel panel-primary">
      <div class="panel-heading">Edit Bid Endpoint</div>
      <div class="panel-body">
        <form role="form" method="post" action="bidder?action=update">
          <input type="hidden" name="bidder_id" value="{{$item.bidder_id}}">
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
            <label>Credential Status</label>
            <p class="form-control-static">{{$item.credential_status}}</p>
          </div>
          <div class="form-group">
            <label>Enabled</label>
            <p class="form-control-static">{{$item.active}}</p>
          </div>
          <button type="submit" class="btn btn-primary">Save</button>
          <a class="btn btn-default" href="bidder?action=topics">Cancel</a>
        </form>
      </div>
    </div>
  </div>
</div>

{{ template "footer" .}}
