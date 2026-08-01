{{ template "header" .}}
{{ template "agentheader" .}}

<h3>代理商账户详情</h3>
<pre>{{$item := index .Lists 0}}{{range $k, $v := $item}}
{{$k}}:{{$v}}{{end}}
</pre>

{{ template "footer" .}}
