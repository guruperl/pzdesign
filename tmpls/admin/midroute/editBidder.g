{{ template "header" .}}
{{ template "midrouteheader" .}}
{{ template "midroute_group_nav" .}}
{{$item := index .Lists 0}}

<form method="post" action="midroute?action=updateBidder">
  <input type="hidden" name="route_bidder_id" value="{{$item.route_bidder_id}}">
  <input type="hidden" name="group_id" value="{{$item.group_id}}">
  {{ template "midroute_bidder_form" .}}
  <button type="submit" class="btn btn-primary">保存</button>
  <a class="btn btn-secondary" href="midroute?action=bidders&group_id={{$item.group_id}}">取消</a>
</form>

<hr>
<form method="post" action="midroute?action=deleteBidder" onsubmit="return confirm('确认从路由组中删除此竞价端点吗？');">
  <input type="hidden" name="route_bidder_id" value="{{$item.route_bidder_id}}">
  <button type="submit" class="btn btn-outline-danger">删除竞价端点路由</button>
</form>

{{ template "footer" .}}
