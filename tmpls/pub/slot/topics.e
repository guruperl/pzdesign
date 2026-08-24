{{ template "header" .}}
{{ template "slotheader" .}}

          <div class="card">
            <div class="card-header">
              Current List of <em>{{index .ARGS.site_name 0}}</em>
            </div>
            <div class="card-body">
{{with (index .ARGS "direct_token_version")}}			  <p class="text-muted">Integration locators: {{index . 0}}.{{with (index $.ARGS "request_authentication")}} App request authentication: {{index . 0}}.{{end}}</p>{{end}}

<div class="table-responsive">
<table class="table table-striped table-sm">
              <thead>
                <tr>
                  <th>Name</th>
                  <th>Platform</th>
                  <th>Minimum bid (USD CPM)</th>
                  <th>Active</th>
                  <th>Since</th>
                  <th colspan=3 class="text-right"><a class="btn btn-info" href="slot?action=startnew&site_id={{index .ARGS.site_id 0}}&site_md5={{index .ARGS.site_md5 0}}&site_name={{index .ARGS.site_name 0 | urlquery}}&site_type={{index .ARGS.site_type 0 | urlquery}}">Create New</a> </th>
                </tr>
              </thead>
              <tbody>{{ range .Lists }}
<tr><td><a href="slot?action=edit&site_id={{index $.ARGS.site_id 0}}&site_md5={{index $.ARGS.site_md5 0}}&site_name={{index $.ARGS.site_name 0 | urlquery}}&site_type={{index $.ARGS.site_type 0 | urlquery}}&slot_id={{.slot_id}}&slot_md5={{.slot_md5}}&slot_name={{.slot_name | urlquery}}">{{.slot_name}}</a></td>
<td>{{.qa_device}}</td>
<td>{{.bidfloor}}</td>
<td>{{.active}}</td>
<td>{{.created}}</td>
<td>{{if .browser_code}}<button class="btn btn-sm btn-primary" type="button" data-toggle="modal" data-target="#modal{{.slot_id}}">Web ad tag</button>{{end}}</td>
<td>{{if .api_code}}<button class="btn btn-sm btn-success" type="button" data-toggle="modal" data-target="#modalAPI{{.slot_id}}">App SDK / API</button>{{end}}</td>
<td><a class="btn btn-sm btn-danger" onClick="return (confirm('Do you want to remove your slot {{.slot_name}}?')) ? true : false;" href="slot?action=delete&slot_id={{.slot_id}}&site_id={{index $.ARGS.site_id 0}}&site_md5={{index $.ARGS.site_md5 0}}&site_name={{index $.ARGS.site_name 0 | urlquery}}&site_type={{index $.ARGS.site_type 0 | urlquery}}">Del</a></td>
{{end}}</tobdy>

</table>
</div>

{{ range $item := .Lists }}
{{if $item.browser_code}}<div class="modal fade" id="modal{{$item.slot_id}}" tabindex="-1" role="dialog" aria-labelledby="modal{{$item.slot_id}}Label" aria-hidden="true">
          <div class="modal-dialog" role="document">
            <div class="modal-content">
              <div class="modal-header">
                <h4 class="modal-title">Your HTML Page</h4>
                <button type="button" class="close" data-dismiss="modal" aria-label="Close">
                  <span aria-hidden="true">×</span>
                </button>
              </div>
              <div class="modal-body">
                <textarea class="form-control" rows="24" id="browserCode{{$item.slot_id}}" readonly>{{$item.browser_code}}</textarea>
              </div>
              <div class="modal-footer">
                <button type="button" class="btn btn-primary" onclick="pzCopyCode('browserCode{{$item.slot_id}}')">Copy</button>
                <button type="button" class="btn btn-success" onclick="pzDownloadCode('browserCode{{$item.slot_id}}', 'aofei-slot-{{$item.slot_id}}.html')">Download</button>
                <button type="button" class="btn btn-secondary" data-dismiss="modal">Close</button>
              </div>
            </div>
            <!-- /.modal-content -->
          </div>
          <!-- /.modal-dialog -->
        </div>
        <!-- /.modal -->{{end}}

{{if $item.api_code}}<div class="modal fade" id="modalAPI{{$item.slot_id}}" tabindex="-1" role="dialog" aria-labelledby="modalAPI{{$item.slot_id}}Label" aria-hidden="true">
          <div class="modal-dialog" role="document">
            <div class="modal-content">
              <div class="modal-header">
                <h4 class="modal-title">API Request</h4>
                <button type="button" class="close" data-dismiss="modal" aria-label="Close">
                  <span aria-hidden="true">×</span>
                </button>
              </div>
              <div class="modal-body">
                <textarea class="form-control" rows="22" id="apiCode{{$item.slot_id}}" readonly>{{$item.api_code}}</textarea>
              </div>
              <div class="modal-footer">
                <button type="button" class="btn btn-primary" onclick="pzCopyCode('apiCode{{$item.slot_id}}')">Copy</button>
                <button type="button" class="btn btn-secondary" data-dismiss="modal">Close</button>
              </div>
            </div>
            <!-- /.modal-content -->
          </div>
          <!-- /.modal-dialog -->
        </div>
        <!-- /.modal -->{{end}}
{{end}}

            </div>
          </div>

{{ template "footer" }}

<script>
  function pzCopyCode(id) {
    var field = document.getElementById(id);
    if (!field) {
      return;
    }
    field.focus();
    field.select();
    if (navigator.clipboard && navigator.clipboard.writeText) {
      navigator.clipboard.writeText(field.value);
      return;
    }
    document.execCommand('copy');
  }

  function pzDownloadCode(id, filename) {
    var field = document.getElementById(id);
    if (!field) {
      return;
    }
    var blob = new Blob([field.value], {type: 'text/html;charset=utf-8'});
    var link = document.createElement('a');
    link.href = URL.createObjectURL(blob);
    link.download = filename;
    document.body.appendChild(link);
    link.click();
    document.body.removeChild(link);
    URL.revokeObjectURL(link.href);
  }
</script>

</body>
</html>
