{{ template "header" .}}
{{ template "midrouteheader" .}}
{{$item := index .Lists 0}}
<div class="alert alert-success">Bid endpoint route deleted.</div>
<a class="btn btn-secondary" href="midroute?action=bidders&group_id={{$item.group_id}}">Back to Bid Endpoints</a>
{{ template "footer" .}}
