{{ template "header" .}}
{{ template "acheader" .}}

{{$args := .ARGS}}

          <div class="card">
            <div class="card-header">
              Ad Group Review for <em>{{if eq "31" (index .ARGS.entitytype_id 0)}}Traffic Source “{{index .ARGS.site_name 0}}”{{else}}Publisher Account “{{index .ARGS.p_company 0}}”{{end}}</em>
            </div>
            <div class="card-body">

<form name=f1 class="form" method=post action="ac">
<input type=hidden name=action value="updateOrder" />
{{if eq "31" (index .ARGS.entitytype_id 0)}}
<input type=hidden name=site_id value="{{index .ARGS.site_id 0}}" />
<input type=hidden name=site_md5 value="{{index .ARGS.site_md5 0}}" />
<input type=hidden name=site_name value="{{index .ARGS.site_name 0}}" />
<input type=hidden name=entitytype_id value="31" />{{else}}
<input type=hidden name=entitytype_id value="3" />{{end}}

Traffic scope rule: <input type=radio name=access_order value="Black" {{if eq `Black` (index .ARGS.access_order 0)}}checked{{end}} />Blocklist
<input type=radio name=access_order value="White" {{if eq `White` (index .ARGS.access_order 0)}}checked{{end}} />Allowlist
{{if eq `31` (index .ARGS.entitytype_id 0)}}<input type=radio name=access_order value="Inherit" {{if eq `Inherit` (index .ARGS.access_order 0)}}checked{{end}} />Default{{end}}
<button class="btn btn-sm btn-primary" type=submit onClick="return (confirm('Change the traffic scope rule? This clears the existing rules.')) ? true : false;">Update Traffic Scope Rule</button>
</form>
            </div>
          </div>




          <div class="card">
            <div class="card-header">
              Current Allowlist/Blocklist for <em>{{if eq "31" (index .ARGS.entitytype_id 0)}}Traffic Source “{{index .ARGS.site_name 0}}”{{else}}Publisher Account “{{index .ARGS.p_company 0}}”{{end}}</em>
            </div>
            <div class="card-body">

<form name=f2 class="form-inline" method=post action="ac">
<input type=hidden name=entitytype_id value="{{index .ARGS.entitytype_id 0}}" />
<input type=hidden name=action value="inserts" />
<div class="table-responsive">
<table class="table table-striped table-sm">
              <thead>
                <tr>
                  <th>Advertiser</th>
                  <th>Advertiser Approval</th>
                  <th>Campaign</th>
                  <th>Campaign Approval</th>
                </tr>
              </thead>
              <tbody>{{ with .Lists }}{{ range . }}
<tr><td>{{.adv_name}}</td>
<td><input class="form-inline" type=checkbox name=adv_ids {{if .othertype_id}}{{if eq 4 .othertype_id}}checked{{end}}{{end}} value="{{.adv_id}}"></td>
<td><a href="#" data-title="{{.campaign_name}}" data-href="item?action=topics&campaign_id={{.campaign_id}}&campaign_md5={{.campaign_md5}}&campaign_name={{.campaign_name|urlquery}}" class="openPopup">{{.campaign_name}}</a></td>
<td><input class="form-inline" type=checkbox name=campaign_ids {{if .othertype_id}}{{if eq 41 .othertype_id}}checked{{end}}{{end}} value="{{.campaign_id}}"></td>
</tr>{{end}}{{end}}
</tobdy>
</table>
</div>
<button type="submit" class="btn btn-primary">Submit Review Results</button>
</form>
            </div>
          </div>

<!-- Modal -->
<div class="modal fade" id="myModal" role="dialog">
  <div class="modal-dialog">
    <!-- Modal content-->
    <div class="modal-content">
      <div class="modal-header">
        <h4 class="modal-title">Creatives</h4>
        <button type="button" class="close" data-dismiss="modal">&times;</button>
      </div>
      <div class="modal-body"></div>
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
    $('.openPopup').on('click',function(){
      var dataTITLE = $(this).attr('data-title');
      var dataURL = $(this).attr('data-href');
      $('.modal-title').text(dataTITLE);
      $('.modal-body').load(dataURL,function(){
        $('#myModal').modal({show:true});
      });
    });
  });
</script>
</body>
</html>
