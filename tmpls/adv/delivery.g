{{ define "deliveryschedule" }}
<div class="form-group row">
  <label class="col-sm-2 col-form-label">投放节奏：</label>
  <div class="col-sm-4">
    <select class="form-control" name="pacing_mode">
      <option value="Fast"{{if eq .Other.delivery_pacing "Fast"}} selected{{end}}>尽快投放</option>
      <option value="Even"{{if eq .Other.delivery_pacing "Even"}} selected{{end}}>按时间均匀投放</option>
    </select>
    <small class="form-text text-muted">均匀投放按 UTC 日内或活动周期的时间进度限制消耗，不会自动调整出价；投放时段另行控制是否参与竞价，因此较窄时段可能无法用完预算。</small>
  </div>
  {{if .Other.delivery_has_timezone}}
  <label class="col-sm-2 col-form-label">投放时区：</label>
  <div class="col-sm-4">
    <input class="form-control" name="delivery_timezone" value="{{.Other.delivery_timezone}}" list="delivery-timezones" placeholder="UTC">
    <datalist id="delivery-timezones">
      <option value="UTC"><option value="Asia/Shanghai"><option value="Asia/Hong_Kong">
      <option value="America/New_York"><option value="America/Los_Angeles"><option value="Europe/London">
    </datalist>
    <small class="form-text text-muted">开始和结束时间使用 UTC；此时区用于每周投放时段。每日预算在 UTC 00:00 重置。</small>
  </div>
  {{end}}
</div>
<details class="form-group"{{if .Other.delivery_schedule_enabled}} open{{end}}>
  <summary>每周投放时段（可选）</summary>
  <label class="mt-2"><input type="checkbox" name="weekly_schedule_enabled" value="1"{{if .Other.delivery_schedule_enabled}} checked{{end}}> 启用以下每周时段；不启用表示全天投放</label>
  <div class="table-responsive">
    <table class="table table-sm table-bordered text-center">
      <thead><tr><th>星期 / 小时</th>{{range $hour := (index .Other.delivery_schedule_rows 0).Hours}}<th>{{$hour.Hour}}</th>{{end}}</tr></thead>
      <tbody>{{range $day := .Other.delivery_schedule_rows}}<tr><th>{{$day.Label}}</th>{{range $hour := $day.Hours}}<td><input aria-label="{{$day.Label}} {{$hour.Hour}}:00" type="checkbox" name="weekly_hour" value="{{$hour.Index}}"{{if $hour.Selected}} checked{{end}}></td>{{end}}</tr>{{end}}</tbody>
    </table>
  </div>
</details>
{{ end }}
