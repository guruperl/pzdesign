{{ template "header" .}}
{{ template "pubheader" .}}

<h3>媒体商户细节</h3>
<pre>{{$item := index .Lists 0}}{{range $k, $v := $item}}
{{$k}}:{{$v}}{{end}}
</pre>

{{ template "footer" .}}
