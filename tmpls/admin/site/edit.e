{{ template "header" .}}
{{ template "siteheader" .}}

<h3>Sites</h3>
<pre>{{$item := index .Lists 0}}{{range $k, $v := $item}}
{{$k}}:{{$v}}{{end}}
</pre>

{{ template "footer" .}}
