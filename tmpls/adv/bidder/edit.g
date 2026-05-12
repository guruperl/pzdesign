{{ template "header" .}}
{{ template "bidderheader" .}}
{{$item := index .Lists 0}}

<div class="row">
  <div class="col-lg-8">
    <div class="panel panel-primary">
      <div class="panel-heading">编辑竞价端点</div>
      <div class="panel-body">
        <form role="form" method="post" action="bidder?action=update">
          <input type="hidden" name="bidder_id" value="{{$item.bidder_id}}">
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
            <label>凭证状态</label>
            <p class="form-control-static">{{$item.credential_status}}</p>
          </div>
          <div class="form-group">
            <label>启用</label>
            <p class="form-control-static">{{$item.active}}</p>
          </div>
          <button type="submit" class="btn btn-primary">保存</button>
          <a class="btn btn-default" href="bidder?action=topics">取消</a>
        </form>
      </div>
    </div>
  </div>
</div>

{{ template "footer" .}}
