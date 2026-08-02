{{ template "header" .}}
{{ template "siteheader" .}}

{{$item := index .Lists 0}}
<h3>流量源分类审核</h3>
<div class="table-responsive"><table class="table table-sm table-bordered">
<tbody>
<tr><th>流量源</th><td>{{$item.site_name}}</td><th>类型</th><td>{{$item.site_type}}</td></tr>
<tr><th>Bundle / Domain</th><td>{{$item.foreign_id}}</td><th>状态</th><td>{{$item.active}}</td></tr>
<tr><th>流量环境</th><td>{{$item.inventory_environment}}</td><th>接入方式</th><td>{{$item.integration_mode}}</td></tr>
<tr><th>规范标识</th><td>{{$item.canonical_identity}}</td><th>公开审核网址</th><td>{{$item.store_url}}</td></tr>
<tr><th>介绍网址</th><td colspan="3">{{$item.site_url}}</td></tr>
</tbody></table></div>
<p class="text-muted">运营审核应核对规范标识、公开网址及 Web/App 与接入方式是否一致。分类描述不授予流量权限。</p>

{{ template "footer" .}}
