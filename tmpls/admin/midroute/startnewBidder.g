{{ template "header" .}}
{{ template "midrouteheader" .}}
{{ template "midroute_group_nav" .}}
{{$item := index .Lists 0}}

<form method="post" action="midroute?action=insertBidder">
  <input type="hidden" name="group_id" value="{{$item.group_id}}">
  {{ template "midroute_bidder_form" .}}
  <button type="submit" class="btn btn-primary">保存</button>
  <a class="btn btn-secondary" href="midroute?action=bidders&group_id={{$item.group_id}}">取消</a>
</form>

{{ template "footer" .}}
