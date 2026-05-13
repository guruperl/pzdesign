{{ template "header" .}}
{{ template "midrouteheader" .}}
{{$item := index .Lists 0}}
<div class="alert alert-success">流量目标已删除。</div>
<a class="btn btn-secondary" href="midroute?action=targets&group_id={{$item.group_id}}">返回目标</a>
{{ template "footer" .}}
