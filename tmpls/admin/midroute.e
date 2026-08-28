{{ define "midrouteheader" }}
<div class="d-flex justify-content-between flex-wrap flex-md-nowrap align-items-center pb-2 mb-3 border-bottom">
  <h1 class="h2">External DSP / ADX Demand Routing</h1>
</div>
{{ end }}

{{ define "midroute_bidder_form" }}
{{$item := index .Lists 0}}
<div class="form-group">
  <label>Bid Endpoint</label>
  <select class="form-control" name="bidder_id" required>
    {{ range $bidder := index .Other "midroute_bidders" }}
      <option value="{{$bidder.bidder_id}}"{{if eq $bidder.bidder_id $item.bidder_id}} selected{{end}}>{{$bidder.bidder_id}} {{$bidder.bidder_name}} - {{$bidder.adv_email}} - {{$bidder.credential_status}}/{{$bidder.active}}</option>
    {{ end }}
  </select>
</div>
<div class="form-row">
  <div class="form-group col-md-3">
    <label>Priority</label>
    <input class="form-control" type="number" min="1" max="65535" name="priority" value="{{$item.priority}}">
  </div>
  <div class="form-group col-md-3">
    <label>Timeout (Milliseconds)</label>
    <input class="form-control" type="number" min="1" max="5000" name="timeout_ms" value="{{$item.timeout_ms}}">
  </div>
  <div class="form-group col-md-3">
    <label>Markup Ratio</label>
    <input class="form-control" type="number" min="0" max="1" step="0.0001" name="margin_pct" value="{{$item.margin_pct}}">
  </div>
  <div class="form-group col-md-3">
    <label>Minimum Markup CPM</label>
    <input class="form-control" type="number" min="0" step="0.0001" name="min_margin_cpm" value="{{$item.min_margin_cpm}}">
  </div>
</div>
<div class="form-group">
  <label>Enabled</label>
  <select class="form-control" name="active">
    <option value="Yes"{{if eq $item.active "Yes"}} selected{{end}}>Enabled</option>
    <option value="No"{{if eq $item.active "No"}} selected{{end}}>Disabled</option>
  </select>
</div>
{{ end }}

{{ define "midroute_target_form" }}
{{$item := index .Lists 0}}
<div class="form-row">
  <div class="form-group col-md-4">
    <label>Scope</label>
    <select class="form-control" name="entitytype_id">
      <option value=""{{if $item.entitytype_global}} selected{{end}}>All Traffic</option>
      <option value="3"{{if $item.entitytype_pub}} selected{{end}}>Publisher</option>
      <option value="31"{{if $item.entitytype_site}} selected{{end}}>Traffic Source (Website/App)</option>
      <option value="32"{{if $item.entitytype_slot}} selected{{end}}>Ad Slot</option>
    </select>
  </div>
  <div class="form-group col-md-4">
    <label>Entity ID</label>
    <input class="form-control" type="number" min="1" name="entity_id" value="{{$item.entity_id}}">
  </div>
  <div class="form-group col-md-4">
    <label>Size</label>
    <select class="form-control" name="size_id">
      <option value="">Any Size</option>
      {{ range $size := index .Other "midroute_sizes" }}
        <option value="{{$size.size_id}}"{{if eq $size.size_id $item.size_id}} selected{{end}}>{{$size.size_id}} {{$size.size_name}} {{$size.width}}x{{$size.height}}</option>
      {{ end }}
    </select>
  </div>
</div>
<div class="form-row">
  <div class="form-group col-md-6">
    <label>Priority</label>
    <input class="form-control" type="number" min="1" max="65535" name="priority" value="{{$item.priority}}">
  </div>
  <div class="form-group col-md-6">
    <label>Enabled</label>
    <select class="form-control" name="active">
      <option value="Yes"{{if eq $item.active "Yes"}} selected{{end}}>Enabled</option>
      <option value="No"{{if eq $item.active "No"}} selected{{end}}>Disabled</option>
    </select>
  </div>
</div>
{{ end }}

{{ define "midroute_group_nav" }}
{{ $group := index .Other "midroute_group" }}
{{ if $group }}
<div class="mb-3">
  <a class="btn btn-sm btn-outline-secondary" href="midroute?action=topics">Route Groups</a>
  <a class="btn btn-sm btn-outline-primary" href="midroute?action=edit&group_id={{$group.group_id}}">Edit {{$group.group_name}}</a>
  <a class="btn btn-sm btn-outline-primary" href="midroute?action=bidders&group_id={{$group.group_id}}">Downstream Bid Endpoints</a>
  <a class="btn btn-sm btn-outline-primary" href="midroute?action=targets&group_id={{$group.group_id}}">Traffic Targets</a>
</div>
{{ end }}
{{ end }}
