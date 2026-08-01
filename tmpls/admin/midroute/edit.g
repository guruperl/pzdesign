{{ template "header" .}}
{{ template "midrouteheader" .}}
{{$item := index .Lists 0}}

<form method="post" action="midroute?action=update">
  <input type="hidden" name="group_id" value="{{$item.group_id}}">
  <div class="form-group">
    <label>名称</label>
    <input class="form-control" name="group_name" value="{{$item.group_name}}" required>
  </div>
  <div class="form-row">
    <div class="form-group col-md-4">
      <label>触发模式</label>
      <select class="form-control" name="trigger_mode">
        <option value="Fallback"{{if eq $item.trigger_mode "Fallback"}} selected{{end}}>Fallback（本地无填充时）</option>
        <option value="Always"{{if eq $item.trigger_mode "Always"}} selected{{end}}>Always（始终参与竞价）</option>
      </select>
    </div>
    <div class="form-group col-md-4">
      <label>总超时毫秒</label>
      <input class="form-control" type="number" min="1" max="5000" name="total_timeout_ms" value="{{$item.total_timeout_ms}}">
    </div>
    <div class="form-group col-md-4">
      <label>启用</label>
      <select class="form-control" name="active">
        <option value="Yes"{{if eq $item.active "Yes"}} selected{{end}}>启用</option>
        <option value="No"{{if eq $item.active "No"}} selected{{end}}>停用</option>
      </select>
    </div>
  </div>
  <div class="form-row">
    <div class="form-group col-md-6">
      <label>加价比例</label>
      <input class="form-control" type="number" min="0" max="1" step="0.0001" name="margin_pct" value="{{$item.margin_pct}}">
    </div>
    <div class="form-group col-md-6">
      <label>最低加价 CPM</label>
      <input class="form-control" type="number" min="0" step="0.0001" name="min_margin_cpm" value="{{$item.min_margin_cpm}}">
    </div>
  </div>
  <button type="submit" class="btn btn-primary">保存</button>
  <a class="btn btn-secondary" href="midroute?action=topics">取消</a>
  <a class="btn btn-outline-primary" href="midroute?action=bidders&group_id={{$item.group_id}}">竞价端点</a>
  <a class="btn btn-outline-primary" href="midroute?action=targets&group_id={{$item.group_id}}">目标</a>
</form>

<hr>
<form method="post" action="midroute?action=delete" onsubmit="return confirm('确认删除此路由组吗？此操作不可撤销。');">
  <input type="hidden" name="group_id" value="{{$item.group_id}}">
  <button type="submit" class="btn btn-outline-danger">删除路由组</button>
</form>

{{ template "footer" .}}
