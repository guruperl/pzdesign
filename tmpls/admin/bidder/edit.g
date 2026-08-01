{{ template "header" .}}
{{ template "bidderheader" .}}
{{$item := index .Lists 0}}

<form method="post" action="bidder?action=update">
  <input type="hidden" name="bidder_id" value="{{$item.bidder_id}}">
  <div class="form-group">
    <label>广告主</label>
    <p class="form-control-static">{{$item.adv_id}} {{$item.adv_email}}</p>
  </div>
  <div class="form-group">
    <label>名称</label>
    <input class="form-control" name="bidder_name" value="{{$item.bidder_name}}" required>
  </div>
  <div class="form-group">
    <label>端点 URL</label>
    <input class="form-control" type="url" name="endpoint_url" value="{{$item.endpoint_url}}" required>
  </div>
  <div class="form-group">
    <label>OpenRTB 版本</label>
    <input class="form-control" name="openrtb_version" value="{{$item.openrtb_version}}">
  </div>
  <div class="form-group">
    <label>Seat</label>
    <input class="form-control" name="seat" value="{{$item.seat}}">
  </div>
  <div class="form-group">
    <label>超时毫秒</label>
    <input class="form-control" type="number" min="1" max="5000" name="timeout_ms" value="{{$item.timeout_ms}}">
  </div>
  <div class="form-group">
    <label>凭证引用</label>
    <input class="form-control" name="credential_ref" value="{{$item.credential_ref}}">
  </div>
  <div class="form-group">
    <label>凭证状态</label>
    <select class="form-control" name="credential_status">
      <option value="Missing"{{if eq $item.credential_status "Missing"}} selected{{end}}>未配置</option>
      <option value="Pending"{{if eq $item.credential_status "Pending"}} selected{{end}}>待审批</option>
      <option value="Active"{{if eq $item.credential_status "Active"}} selected{{end}}>已启用</option>
      <option value="Disabled"{{if eq $item.credential_status "Disabled"}} selected{{end}}>已停用</option>
    </select>
  </div>
  <div class="form-group">
    <label>启用</label>
    <select class="form-control" name="active">
      <option value="No"{{if eq $item.active "No"}} selected{{end}}>停用</option>
      <option value="Yes"{{if eq $item.active "Yes"}} selected{{end}}>启用</option>
    </select>
  </div>
  <div class="form-row">
    <div class="form-group col-md-4">
      <label>合成活动</label>
      <p class="form-control-static">{{$item.synthetic_campaign_id}}</p>
    </div>
    <div class="form-group col-md-4">
      <label>合成广告组</label>
      <p class="form-control-static">{{$item.synthetic_item_id}}</p>
    </div>
    <div class="form-group col-md-4">
      <label>合成广告素材</label>
      <p class="form-control-static">{{$item.synthetic_creative_id}}</p>
    </div>
  </div>
  <button type="submit" class="btn btn-primary">保存</button>
  <a class="btn btn-secondary" href="bidder?action=topics">取消</a>
</form>

<hr>
<form method="post" action="bidder?action=approve">
  <input type="hidden" name="bidder_id" value="{{$item.bidder_id}}">
  <div class="form-group">
    <label>审批凭证引用</label>
    <input class="form-control" name="credential_ref" value="{{$item.credential_ref}}" required>
  </div>
  <button type="submit" class="btn btn-success">审批启用</button>
</form>

{{ template "footer" .}}
