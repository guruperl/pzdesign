{{ template "header" .}}
{{ template "slotheader" .}}

{{$item := index .Lists 0}}
<h3>广告位分类审核</h3>
<div class="table-responsive"><table class="table table-sm table-bordered"><tbody>
<tr><th>广告位</th><td>{{$item.slot_name}}</td><th>尺寸 ID</th><td>{{$item.size_id}}</td></tr>
<tr><th>最低竞价</th><td>{{$item.bidfloor}} USD CPM</td><th>状态</th><td>{{$item.active}}</td></tr>
<tr><th>媒体形式</th><td>{{$item.media_intent}}</td><th>展示位置</th><td>{{$item.placement}}</td></tr>
<tr><th>呈现场景</th><td>{{$item.render_context}}</td><th>刷新</th><td>{{$item.refresh_mode}} / {{$item.refresh_seconds}} 秒</td></tr>
<tr><th>广告密度</th><td>{{$item.ad_density}}</td><th>流量质量</th><td>{{$item.traffic_quality}}</td></tr>
<tr><th>流量来源</th><td>{{$item.source_quality}}</td><th>管理责任</th><td>{{$item.management_control}}</td></tr>
</tbody></table></div>
<p class="text-muted">运营审核应核对分类与实际页面/App 行为。定时刷新仅允许 15–3600 秒；分类不会改变结算归属。</p>

{{ template "footer" .}}
