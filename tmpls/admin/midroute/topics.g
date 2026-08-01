{{ template "header" .}}
{{ template "midrouteheader" .}}

<div class="mb-3">
  <a class="btn btn-primary" href="midroute?action=startnew">新建路由组</a>
  <a class="btn btn-outline-secondary" href="midroute?action=health">健康检查</a>
</div>

{{ $cache := index .Other "midroute_cache_status" }}
{{ if $cache }}
<div class="table-responsive mb-3">
  <table class="table table-sm table-bordered">
    <tbody>
      <tr>
        <th>Redis Key</th>
        <td>{{$cache.cache_key}}</td>
        <th>状态</th>
        <td>{{$cache.cache_status}}</td>
      </tr>
      <tr>
        <th>生成时间</th>
        <td>{{$cache.cache_generated_at}}</td>
        <th>缓存条目</th>
        <td>{{$cache.cache_entry_count}}</td>
      </tr>
      <tr>
        <th>缓存高水位</th>
        <td>{{$cache.cache_route_high_water}}</td>
        <th>数据库高水位</th>
        <td>{{$cache.db_route_high_water}}</td>
      </tr>
      <tr>
        <th>来源</th>
        <td>{{$cache.cache_source}}</td>
        <th>校验和</th>
        <td>{{$cache.cache_checksum}}</td>
      </tr>
      {{ if $cache.cache_error }}
      <tr>
        <th>错误</th>
        <td colspan="3">{{$cache.cache_error}}</td>
      </tr>
      {{ end }}
    </tbody>
  </table>
</div>
{{ end }}

<div class="table-responsive">
  <table class="table table-striped table-sm">
    <thead>
      <tr>
        <th>ID</th>
        <th>名称</th>
        <th>触发</th>
        <th>总超时</th>
        <th>加价比例</th>
        <th>最低加价</th>
        <th>启用</th>
        <th>竞价端点</th>
        <th>目标</th>
        <th></th>
      </tr>
    </thead>
    <tbody>{{ with .Lists }}{{ range . }}
      <tr>
        <td>{{.group_id}}</td>
        <td>{{.group_name}}</td>
        <td>{{.trigger_mode}}</td>
        <td>{{.total_timeout_ms}} ms</td>
        <td>{{.margin_pct}}</td>
        <td>{{.min_margin_cpm}}</td>
        <td>{{.active}}</td>
        <td><a href="midroute?action=bidders&group_id={{.group_id}}">{{.bidder_count}}</a></td>
        <td><a href="midroute?action=targets&group_id={{.group_id}}">{{.target_count}}</a></td>
        <td>
          <a class="btn btn-sm btn-primary" href="midroute?action=edit&group_id={{.group_id}}">编辑</a>
        </td>
      </tr>
    {{end}}{{else}}
      <tr><td colspan="10">暂无外部需求方路由组。</td></tr>
    {{end}}</tbody>
  </table>
</div>

{{ template "footer" .}}
