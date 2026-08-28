{{ template "header" .}}
{{ template "midrouteheader" .}}
{{ template "midroute_group_nav" .}}
{{$item := index .Lists 0}}

<form method="post" action="midroute?action=insertTarget">
  <input type="hidden" name="group_id" value="{{$item.group_id}}">
  {{ template "midroute_target_form" .}}
  <button type="submit" class="btn btn-primary">Save</button>
  <a class="btn btn-secondary" href="midroute?action=targets&group_id={{$item.group_id}}">Cancel</a>
</form>

{{ template "footer" .}}
