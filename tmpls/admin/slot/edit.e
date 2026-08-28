{{ template "header" .}}
{{ template "slotheader" .}}

{{$item := index .Lists 0}}
<h3>Ad Slot Classification Review</h3>
<div class="table-responsive"><table class="table table-sm table-bordered"><tbody>
<tr><th>Ad Slot</th><td>{{$item.slot_name}}</td><th>Size ID</th><td>{{$item.size_id}}</td></tr>
<tr><th>Minimum Bid</th><td>{{$item.bidfloor}} USD CPM</td><th>Status</th><td>{{$item.active}}</td></tr>
<tr><th>Media Format</th><td>{{$item.media_intent}}</td><th>Placement</th><td>{{$item.placement}}</td></tr>
<tr><th>Render Context</th><td>{{$item.render_context}}</td><th>Refresh</th><td>{{$item.refresh_mode}} / {{$item.refresh_seconds}} seconds</td></tr>
<tr><th>Ad Density</th><td>{{$item.ad_density}}</td><th>Traffic Quality</th><td>{{$item.traffic_quality}}</td></tr>
<tr><th>Traffic Source Quality</th><td>{{$item.source_quality}}</td><th>Management Responsibility</th><td>{{$item.management_control}}</td></tr>
</tbody></table></div>
<p class="text-muted">Operational review must compare the classifications with actual page/app behavior. Timed refresh permits only 15–3600 seconds; classification does not change settlement ownership.</p>

{{ template "footer" .}}
