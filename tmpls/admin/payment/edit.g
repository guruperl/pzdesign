{{ template "header" .}}
{{ template "paymentheader" .}}

<h3>交易详情</h3>
<pre>{{$item := index .Lists 0}}{{range $k, $v := $item}}
{{$k}}:{{$v}}{{end}}
</pre>

{{ template "footer" .}}
