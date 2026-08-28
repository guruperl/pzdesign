{{ template "header" .}}
{{ template "midrouteheader" .}}
{{$item := index .Lists 0}}
<div class="alert alert-success">Route group created.</div>
<a class="btn btn-primary" href="midroute?action=edit&group_id={{$item.group_id}}">Continue Editing</a>
<a class="btn btn-secondary" href="midroute?action=topics">Back to List</a>
{{ template "footer" .}}
