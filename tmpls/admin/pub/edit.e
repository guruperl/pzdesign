{{ template "header" .}}
{{ template "pubheader" .}}

<h3>Publishers</h3>
<pre>{{$item := index .Lists 0}}{{range $k, $v := $item}}
{{$k}}:{{$v}}{{end}}
</pre>

{{ template "footer" .}}
