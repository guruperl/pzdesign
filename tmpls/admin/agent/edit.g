{{ template "header" .}}
{{ template "agentheader" .}}

<h3>审查单位细节</h3>
<pre>{{$item := index .Lists 0}}{{range $k, $v := $item}}
{{$k}}:{{$v}}{{end}}
</pre>

{{ template "footer" .}}
