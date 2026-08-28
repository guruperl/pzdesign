{{ template "header" .}}
{{ template "midrouteheader" .}}
{{ template "midroute_group_nav" .}}
{{$item := index .Lists 0}}

<form method="post" action="midroute?action=updateTarget">
  <input type="hidden" name="target_id" value="{{$item.target_id}}">
  <input type="hidden" name="group_id" value="{{$item.group_id}}">
  {{ template "midroute_target_form" .}}
  <button type="submit" class="btn btn-primary">Save</button>
  <a class="btn btn-secondary" href="midroute?action=targets&group_id={{$item.group_id}}">Cancel</a>
</form>

<hr>
<form method="post" action="midroute?action=deleteTarget" onsubmit="return confirm('Delete this traffic target?');">
  <input type="hidden" name="target_id" value="{{$item.target_id}}">
  <button type="submit" class="btn btn-outline-danger">Delete Traffic Target</button>
</form>

{{ template "footer" .}}
