{{ template "header" .}}
{{ template "acheader" .}}

{{$args := .ARGS}}

          <div class="card">
            <div class="card-header">
              <em>{{if eq "31" (index .ARGS.entitytype_id 0)}}广告位组{{index .ARGS.site_name 0}}{{else}}媒体商户{{index .ARGS.p_company 0}}{{end}}</em>的创意审核
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

黑白逻辑: <input type=radio name=access_order value="Black" {{if eq `Black` (index .ARGS.access_order 0)}}checked{{end}} />黑名单
<input type=radio name=access_order value="White" {{if eq `White` (index .ARGS.access_order 0)}}checked{{end}} />白名单
{{if eq `31` (index .ARGS.entitytype_id 0)}}<input type=radio name=access_order value="Inherit" {{if eq `Inherit` (index .ARGS.access_order 0)}}checked{{end}} />默认{{end}}
<button class="btn btn-sm btn-primary" type=submit onClick="return (confirm('This will delete all existing access list and reset logic. Do you want to continue?')) ? true : false;">更新逻辑次序</button>
</form>
            </div>
          </div>




          <div class="card">
            <div class="card-header">
              <em>{{if eq "31" (index .ARGS.entitytype_id 0)}}广告位组{{index .ARGS.site_name 0}}{{else}}商户{{index .ARGS.p_company 0}}{{end}}</em>目前的黑白名单
            </div>
            <div class="card-body">

<div class="table-responsive">
<table class="table table-striped table-sm">
              <thead>
                <tr>
                  <th>公司</th>
                  <th>广告活动</th>
                  <th></th>
                </tr>
              </thead>
              <tbody>{{ with .Lists }}{{ range . }}
<tr><td>{{.adv_name}}</td>
<!--
<td><a href="item?action=topics&campaign_id={{.campaign_id}}&campaign_md5={{.campaign_md5}}&campaign_name={{.campaign_name|urlquery}}">{{.campaign_name}}</a></td>
-->
<td><a href="javascript:void(0);" data-title="{{.campaign_name}}" data-href="item?action=topics&campaign_id={{.campaign_id}}&campaign_md5={{.campaign_md5}}&campaign_name={{.campaign_name|urlquery}}" class="openPopup">{{.campaign_name}}</a></td>
<td><input type=checkbox name=ac_id value="{{.ac_id}}"></td>
</tr>{{end}}{{end}}
</tobdy>
</table>
</div>
            </div>
          </div>

<!-- Modal -->
<div class="modal fade" id="myModal" role="dialog">
  <div class="modal-dialog">
    <!-- Modal content-->
    <div class="modal-content">
      <div class="modal-header">
        <h4 class="modal-title">物料</h4>
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

          <div class="card">
            <div class="card-header">
              添加审核名单
            </div>
            <div class="card-body">
<form name=f2 class="form" method=post action="ac">
<input type=hidden name=action value="insert" />
{{if eq "31" (index .ARGS.entitytype_id 0)}}
<input type=hidden name=site_id value="{{index .ARGS.site_id 0}}" />
<input type=hidden name=site_md5 value="{{index .ARGS.site_md5 0}}" />
<input type=hidden name=site_name value="{{index .ARGS.site_name 0}}" />
<input type=hidden name=entitytype_id value="31" />{{else}}
<input type=hidden name=entitytype_id value="3" />{{end}}
选择：<input type=radio name=othertype_id value="4" />广告商 <input type=radio name=othertype_id value="41" />广告活动
其代码: <input type=text name=other_id size=12 />
<button type=submit class="btn btn-sm btn-primary">添加</button>
</form>
            </div>
          </div>

{{ template "footer" }}
<script>
  $(document).ready(function(){
    $('.openPopup').on('click',function(){
      var dataTITLE = $(this).attr('data-title');
      var dataURL = $(this).attr('data-href');
      $('.modal-title').html(dataTITLE);
      $('.modal-body').load(dataURL,function(){
        $('#myModal').modal({show:true});
      });
    }); 
  });
</script>
</body>
</html>

