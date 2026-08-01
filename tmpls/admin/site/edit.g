{{ template "header" .}}
{{ template "siteheader" .}}

<h3>流量源详情</h3>
<pre>{{$item := index .Lists 0}}{{range $k, $v := $item}}
{{$k}}:{{$v}}{{end}}
</pre>

{{ template "footer" .}}
