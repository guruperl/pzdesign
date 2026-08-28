{{ template "header" .}}
{{ template "midrouteheader" .}}
{{$item := index .Lists 0}}
<div class="alert alert-success">Bid endpoint route updated.</div>
<a class="btn btn-primary" href="midroute?action=editBidder&route_bidder_id={{$item.route_bidder_id}}">Continue Editing</a>
<a class="btn btn-secondary" href="midroute?action=bidders&group_id={{$item.group_id}}">Back to Bid Endpoints</a>
{{ template "footer" .}}
