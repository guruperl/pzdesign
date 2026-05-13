{{ template "header" .}}
{{ template "midrouteheader" .}}
{{$item := index .Lists 0}}
<div class="alert alert-success">流量目标已更新。</div>
<a class="btn btn-primary" href="midroute?action=editTarget&target_id={{$item.target_id}}">继续编辑</a>
<a class="btn btn-secondary" href="midroute?action=targets&group_id={{$item.group_id}}">返回目标</a>
{{ template "footer" .}}
