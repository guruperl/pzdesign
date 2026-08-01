{{ template "header" .}}
{{ template "campaignheader" .}}

<h3>广告活动详情</h3>
<pre>{{$item := index .Lists 0}}{{range $k, $v := $item}}
{{$k}}:{{$v}}{{end}}
</pre>

{{ template "footer" .}}
