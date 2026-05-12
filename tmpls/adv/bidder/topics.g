{{ template "header" .}}
{{ template "bidderheader" .}}

<div class="row">
  <div class="col-lg-12">
    <div class="panel panel-primary">
      <div class="panel-heading">OpenRTB 竞价端点</div>
      <div class="panel-body">
        <div class="table-responsive">
          <table class="table table-striped table-bordered table-hover">
            <thead>
              <tr>
                <th>名称</th>
                <th>端点</th>
                <th>OpenRTB</th>
                <th>Seat</th>
                <th>超时(ms)</th>
                <th>凭证状态</th>
                <th>启用</th>
                <th colspan="2" class="text-right"><a class="btn btn-primary" href="bidder?action=startnew">创建端点</a></th>
              </tr>
            </thead>
            <tbody>{{ with .Lists }}{{ range . }}
              <tr>
                <td><a href="bidder?action=edit&bidder_id={{.bidder_id}}&bidder_md5={{.bidder_md5}}">{{.bidder_name}}</a></td>
                <td>{{.endpoint_url}}</td>
                <td>{{.openrtb_version}}</td>
                <td>{{.seat}}</td>
                <td>{{.timeout_ms}}</td>
                <td>{{.credential_status}}</td>
                <td>{{.active}}</td>
                <td><a class="btn btn-sm btn-info" href="bidder?action=edit&bidder_id={{.bidder_id}}&bidder_md5={{.bidder_md5}}">编辑</a></td>
              </tr>
            {{end}}{{else}}
              <tr><td colspan="8">暂无竞价端点。</td></tr>
            {{end}}</tbody>
          </table>
        </div>
      </div>
    </div>
  </div>
</div>

{{ template "footer" .}}
