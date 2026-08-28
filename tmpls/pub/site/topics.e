{{ template "header" .}}
{{ template "siteheader" .}}

          <div class="card">
            <div class="card-header">
              Traffic Sources
            </div>
            <div class="card-body">

<div class="table-responsive">
<table class="table table-striped table-sm">
              <thead>
                <tr>
                  <th>Traffic Source Name</th>
                  <th>URL</th>
                  <th>Traffic Environment</th>
                  <th>Integration Mode</th>
                  <th>Created</th>
                  <th>Active</th>
<th colspan=2 class="text-right"><a class="btn btn-primary" href="#" data-title="Add Traffic Source" data-href="site?action=startnew" id="startnewPopup">Add Website or App</a> </th>
                </tr>
              </thead>
              <tbody>{{ with .Lists }}{{ range . }}
<tr>
<td><a href="#" data-title="Update Traffic Source: {{.site_name}}" data-href="site?action=edit&site_id={{.site_id}}&site_md5={{.site_md5}}&site_name={{.site_name | urlquery }}" id="editPopup">{{.site_name}}</a></td>
<td>{{.site_url}}</td>
<td>{{.inventory_environment}}</td>
<td>{{.integration_mode}}</td>
<td>{{.created}}</td>
<td>{{.active}}</td>
<td><a class="btn btn-sm btn-info" href="slot?action=topics&site_id={{.site_id}}&site_md5={{.site_md5}}&site_name={{.site_name | urlquery }}&site_type={{.site_type | urlquery}}">All Ad Slots</a></td>
<td><a class="btn btn-sm btn-danger" onClick="return (confirm('Delete traffic source “{{.site_name}}”? This action cannot be undone.')) ? true : false;" href="site?action=delete&site_id={{.site_id}}">Delete</a></td>
</tr>
{{end}}{{end}}</tobdy>
</table>
</div>

            </div>
            <!-- /.card body -->
          </div>
          <!-- /.card -->


<!-- Modal -->
<div class="modal fade" id="myModal" role="dialog">
  <div class="modal-dialog modal-lg">
    <!-- Modal content-->
    <div class="modal-content">
      <div class="modal-header">
        <h4 id="d-title" class="modal-title">Traffic Source</h4>
        <button type="button" class="close" data-dismiss="modal">&times;</button>
      </div>
      <div id="d-body" class="modal-body"></div>
      <div class="modal-footer">
        <button type="button" class="btn btn-default" data-dismiss="modal">Close</button>
      </div>
    </div>
    <!-- Modal content-->
  </div>
</div>
<!-- /Modal -->

{{ template "footer" }}
<script>
  $(document).ready(function(){
    $('#startnewPopup,#editPopup').on('click',function(){
      var dataTITLE = $(this).attr('data-title');
      var dataURL = $(this).attr('data-href');
      $('#d-title').text(dataTITLE);
      $('#d-body').load(dataURL,function(){
        $('#myModal').modal({show:true});
      });
    });
  });
</script>


</body>
</html>
