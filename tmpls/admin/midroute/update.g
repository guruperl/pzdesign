{{ template "header" .}}
{{ template "midrouteheader" .}}
{{$item := index .Lists 0}}
<div class="alert alert-success">路由组已更新。</div>
<a class="btn btn-primary" href="midroute?action=edit&group_id={{$item.group_id}}">继续编辑</a>
<a class="btn btn-secondary" href="midroute?action=topics">返回列表</a>
{{ template "footer" .}}
