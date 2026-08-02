{{ template "header" .}}
{{ template "bidderheader" .}}

<div class="row">
  <div class="col-lg-8">
    <div class="panel panel-primary">
      <div class="panel-heading">创建竞价端点</div>
      <div class="panel-body">
        <form role="form" method="post" action="bidder?action=insert">
          <div class="form-group">
            <label>名称</label>
            <input class="form-control" name="bidder_name" required>
          </div>
          <div class="form-group">
            <label>端点 URL</label>
            <input class="form-control" type="url" name="endpoint_url" required>
          </div>
          <div class="form-group">
            <label>OpenRTB 版本</label>
            <input class="form-control" name="openrtb_version" value="2.5" readonly>
            <p class="help-block">当前合作方协议固定使用 OpenRTB 2.5。</p>
          </div>
          <div class="form-group">
            <label>买方席位（Seat，可选）</label>
            <input class="form-control" name="seat">
          </div>
          <div class="form-group">
            <label>请求超时（毫秒）</label>
            <input class="form-control" type="number" min="1" max="5000" name="timeout_ms" value="100">
          </div>
          <button type="submit" class="btn btn-primary">创建</button>
          <a class="btn btn-default" href="bidder?action=topics">取消</a>
        </form>
      </div>
    </div>
  </div>
</div>

{{ template "footer" .}}
