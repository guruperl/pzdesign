{{ template "header" .}}
{{ template "midrouteheader" .}}
{{$item := index .Lists 0}}
<div class="alert alert-success">竞价端点路由已添加。</div>
<a class="btn btn-primary" href="midroute?action=editBidder&route_bidder_id={{$item.route_bidder_id}}">继续编辑</a>
<a class="btn btn-secondary" href="midroute?action=bidders&group_id={{$item.group_id}}">返回竞价端点</a>
{{ template "footer" .}}
