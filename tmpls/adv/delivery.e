{{ define "deliveryschedule" }}
<div class="form-group row">
  <label class="col-sm-2 col-form-label">Delivery Pacing:</label>
  <div class="col-sm-4">
    <select class="form-control" name="pacing_mode">
      <option value="Fast"{{if eq .Other.delivery_pacing "Fast"}} selected{{end}}>Deliver as Fast as Possible</option>
      <option value="Even"{{if eq .Other.delivery_pacing "Even"}} selected{{end}}>Evenly Over Time</option>
    </select>
    <small class="form-text text-muted">Even pacing limits spend according to elapsed time in the UTC day or campaign period; it does not adjust bids automatically. Delivery hours separately control auction participation, so a narrow schedule may not spend the full budget.</small>
  </div>
  {{if .Other.delivery_has_timezone}}
  <label class="col-sm-2 col-form-label">Delivery Time Zone:</label>
  <div class="col-sm-4">
    <input class="form-control" name="delivery_timezone" value="{{.Other.delivery_timezone}}" list="delivery-timezones" placeholder="UTC">
    <datalist id="delivery-timezones">
      <option value="UTC"><option value="Asia/Shanghai"><option value="Asia/Hong_Kong">
      <option value="America/New_York"><option value="America/Los_Angeles"><option value="Europe/London">
    </datalist>
    <small class="form-text text-muted">Start and end times use UTC; this time zone applies to the weekly delivery schedule. Daily budgets reset at 00:00 UTC.</small>
  </div>
  {{end}}
</div>
<details class="form-group"{{if .Other.delivery_schedule_enabled}} open{{end}}>
  <summary>Weekly Delivery Schedule (Optional)</summary>
  <label class="mt-2"><input type="checkbox" name="weekly_schedule_enabled" value="1"{{if .Other.delivery_schedule_enabled}} checked{{end}}> Enable the weekly hours below; leave disabled for delivery at all hours</label>
  <div class="table-responsive">
    <table class="table table-sm table-bordered text-center">
      <thead><tr><th>Day / Hour</th>{{range $hour := (index .Other.delivery_schedule_rows 0).Hours}}<th>{{$hour.Hour}}</th>{{end}}</tr></thead>
      <tbody>{{range $day := .Other.delivery_schedule_rows}}<tr><th>{{$day.Label}}</th>{{range $hour := $day.Hours}}<td><input aria-label="{{$day.Label}} {{$hour.Hour}}:00" type="checkbox" name="weekly_hour" value="{{$hour.Index}}"{{if $hour.Selected}} checked{{end}}></td>{{end}}</tr>{{end}}</tbody>
    </table>
  </div>
</details>
{{ end }}
