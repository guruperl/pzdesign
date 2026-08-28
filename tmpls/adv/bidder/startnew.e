{{ template "header" .}}
{{ template "bidderheader" .}}

<div class="row">
  <div class="col-lg-8">
    <div class="panel panel-primary">
      <div class="panel-heading">Create Bid Endpoint</div>
      <div class="panel-body">
        <form role="form" method="post" action="bidder?action=insert">
          <div class="form-group">
            <label>Name</label>
            <input class="form-control" name="bidder_name" required>
          </div>
          <div class="form-group">
            <label>Endpoint URL</label>
            <input class="form-control" type="url" name="endpoint_url" required>
          </div>
          <div class="form-group">
            <label>OpenRTB Version</label>
            <input class="form-control" name="openrtb_version" value="2.5" readonly>
            <p class="help-block">The current partner contract is fixed at OpenRTB 2.5.</p>
          </div>
          <div class="form-group">
            <label>Buyer Seat (Optional)</label>
            <input class="form-control" name="seat">
          </div>
          <div class="form-group">
            <label>Request Timeout (Milliseconds)</label>
            <input class="form-control" type="number" min="1" max="5000" name="timeout_ms" value="100">
          </div>
          <button type="submit" class="btn btn-primary">Create</button>
          <a class="btn btn-default" href="bidder?action=topics">Cancel</a>
        </form>
      </div>
    </div>
  </div>
</div>

{{ template "footer" .}}
