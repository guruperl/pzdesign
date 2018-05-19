{{ template "header" .}}
{{ template "advheader" .}}

<h3>Advertiser</h3>
<pre>{{$item := index .Lists 0}}{{range $k, $v := $item}}
{{$k}}:{{$v}}{{end}}
</pre>

{{ template "footer" .}}
