{{ template "header" .}}
{{ template "midrouteheader" .}}
{{$item := index .Lists 0}}
<div class="alert alert-success">Traffic target added.</div>
<a class="btn btn-primary" href="midroute?action=editTarget&target_id={{$item.target_id}}">Continue Editing</a>
<a class="btn btn-secondary" href="midroute?action=targets&group_id={{$item.group_id}}">Back to Targets</a>
{{ template "footer" .}}
