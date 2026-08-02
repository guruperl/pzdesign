{{ template "header" .}}
{{ template "acheader" .}}

{{$args := .ARGS}}

          <div class="card">
            <div class="card-header">
              <em>{{if eq "31" (index .ARGS.entitytype_id 0)}}流量源“{{index .ARGS.site_name 0}}”{{else}}流量方账户“{{index .ARGS.p_company 0}}”{{end}}</em>的广告组审核
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

流量范围规则：<input type=radio name=access_order value="Black" {{if eq `Black` (index .ARGS.access_order 0)}}checked{{end}} />黑名单
<input type=radio name=access_order value="White" {{if eq `White` (index .ARGS.access_order 0)}}checked{{end}} />白名单
{{if eq `31` (index .ARGS.entitytype_id 0)}}<input type=radio name=access_order value="Inherit" {{if eq `Inherit` (index .ARGS.access_order 0)}}checked{{end}} />默认{{end}}
<button class="btn btn-sm btn-primary" type=submit onClick="return (confirm('确认更改流量范围规则吗？此操作将清除现有规则。')) ? true : false;">更新流量范围规则</button>
</form>
            </div>
          </div>




          <div class="card">
            <div class="card-header">
              <em>{{if eq "31" (index .ARGS.entitytype_id 0)}}流量源“{{index .ARGS.site_name 0}}”{{else}}流量方账户“{{index .ARGS.p_company 0}}”{{end}}</em>当前的白名单/黑名单
            </div>
            <div class="card-body">

<form name=f2 class="form-inline" method=post action="ac">
<input type=hidden name=entitytype_id value="{{index .ARGS.entitytype_id 0}}" />
<input type=hidden name=action value="inserts" />
<div class="table-responsive">
<table class="table table-striped table-sm">
              <thead>
                <tr>
                  <th>广告主</th>
                  <th>广告主审核</th>
                  <th>广告活动</th>
                  <th>活动审核</th>
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
<button type="submit" class="btn btn-primary">提交审核结果</button>
</form>
            </div>
          </div>

<!-- Modal -->
<div class="modal fade" id="myModal" role="dialog">
  <div class="modal-dialog">
    <!-- Modal content-->
    <div class="modal-content">
      <div class="modal-header">
        <h4 class="modal-title">广告素材</h4>
        <button type="button" class="close" data-dismiss="modal">&times;</button>
      </div>
      <div class="modal-body"></div>
      <div class="modal-footer">
        <button type="button" class="btn btn-default" data-dismiss="modal">关闭</button>
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
