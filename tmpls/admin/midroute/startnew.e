{{ template "header" .}}
{{ template "midrouteheader" .}}
{{$item := index .Lists 0}}

<form method="post" action="midroute?action=insert">
  <div class="form-group">
    <label>Name</label>
    <input class="form-control" name="group_name" required>
  </div>
  <div class="form-row">
    <div class="form-group col-md-4">
      <label>Trigger Mode</label>
      <select class="form-control" name="trigger_mode">
        <option value="Fallback"{{if eq $item.trigger_mode "Fallback"}} selected{{end}}>Fallback (when local demand does not fill)</option>
        <option value="Always"{{if eq $item.trigger_mode "Always"}} selected{{end}}>Always (always participate in bidding)</option>
      </select>
    </div>
    <div class="form-group col-md-4">
      <label>Total Timeout (Milliseconds)</label>
      <input class="form-control" type="number" min="1" max="5000" name="total_timeout_ms" value="{{$item.total_timeout_ms}}">
    </div>
    <div class="form-group col-md-4">
      <label>Enabled</label>
      <select class="form-control" name="active">
        <option value="Yes"{{if eq $item.active "Yes"}} selected{{end}}>Enabled</option>
        <option value="No"{{if eq $item.active "No"}} selected{{end}}>Disabled</option>
      </select>
    </div>
  </div>
  <div class="form-row">
    <div class="form-group col-md-6">
      <label>Markup Ratio</label>
      <input class="form-control" type="number" min="0" max="1" step="0.0001" name="margin_pct" value="{{$item.margin_pct}}">
    </div>
    <div class="form-group col-md-6">
      <label>Minimum Markup CPM</label>
      <input class="form-control" type="number" min="0" step="0.0001" name="min_margin_cpm" value="{{$item.min_margin_cpm}}">
    </div>
  </div>
  <button type="submit" class="btn btn-primary">Save</button>
  <a class="btn btn-secondary" href="midroute?action=topics">Cancel</a>
</form>

{{ template "footer" .}}
