{{ template "header" .}}
{{ template "midrouteheader" .}}
{{$item := index .Lists 0}}
<div class="alert alert-success">竞价端点路由已删除。</div>
<a class="btn btn-secondary" href="midroute?action=bidders&group_id={{$item.group_id}}">返回竞价端点</a>
{{ template "footer" .}}
