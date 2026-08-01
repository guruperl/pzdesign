{{ template "header" .}}
{{ template "midrouteheader" .}}

<div class="mb-3">
  <a class="btn btn-outline-secondary" href="midroute?action=topics">路由组</a>
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
        <th>严重性</th>
        <th>问题</th>
        <th>路由组</th>
        <th>竞价端点</th>
        <th>凭证引用</th>
        <th>状态</th>
        <th>详情</th>
      </tr>
    </thead>
    <tbody>{{ with .Lists }}{{ range . }}
      <tr>
        <td>{{.severity}}</td>
        <td>{{.issue_type}}</td>
        <td>{{.group_id}} {{.group_name}}</td>
        <td>{{.bidder_id}} {{.bidder_name}}</td>
        <td>{{.credential_ref}}</td>
        <td>{{.credential_status}} {{.bidder_active}}</td>
        <td>{{.detail}}</td>
      </tr>
    {{end}}{{else}}
      <tr><td colspan="7">未发现外部需求方路由健康问题。</td></tr>
    {{end}}</tbody>
  </table>
</div>

{{ template "footer" .}}
