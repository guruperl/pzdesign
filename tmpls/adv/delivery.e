{{ define "deliveryschedule" }}
<div class="form-group row">
  <label class="col-sm-2 col-form-label">Delivery pacing:</label>
  <div class="col-sm-4">
    <select class="form-control" name="pacing_mode">
      <option value="Fast"{{if eq .Other.delivery_pacing "Fast"}} selected{{end}}>As fast as possible</option>
      <option value="Even"{{if eq .Other.delivery_pacing "Even"}} selected{{end}}>Even over time</option>
    </select>
    <small class="form-text text-muted">Even pacing follows elapsed UTC-day or campaign-window time and never changes the bid automatically. Narrow weekly hours may underdeliver.</small>
  </div>
  {{if .Other.delivery_has_timezone}}
  <label class="col-sm-2 col-form-label">Delivery timezone:</label>
  <div class="col-sm-4">
    <input class="form-control" name="delivery_timezone" value="{{.Other.delivery_timezone}}" placeholder="UTC">
    <small class="form-text text-muted">Start/end are UTC; this timezone controls the weekly calendar. Daily limits reset at 00:00 UTC.</small>
  </div>
  {{end}}
</div>
<details class="form-group"{{if .Other.delivery_schedule_enabled}} open{{end}}>
  <summary>Weekly delivery hours (optional)</summary>
  <label class="mt-2"><input type="checkbox" name="weekly_schedule_enabled" value="1"{{if .Other.delivery_schedule_enabled}} checked{{end}}> Enforce the selected hours; leave disabled for all hours</label>
  <div class="table-responsive">
    <table class="table table-sm table-bordered text-center">
      <thead><tr><th>Day / hour</th>{{range $hour := (index .Other.delivery_schedule_rows_en 0).Hours}}<th>{{$hour.Hour}}</th>{{end}}</tr></thead>
      <tbody>{{range $day := .Other.delivery_schedule_rows_en}}<tr><th>{{$day.Label}}</th>{{range $hour := $day.Hours}}<td><input aria-label="{{$day.Label}} {{$hour.Hour}}:00" type="checkbox" name="weekly_hour" value="{{$hour.Index}}"{{if $hour.Selected}} checked{{end}}></td>{{end}}</tr>{{end}}</tbody>
    </table>
  </div>
</details>
{{ end }}
