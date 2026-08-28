{{ template "header" .}}
{{ template "itemheader" .}}

<h3>Ad Group Details</h3>
<pre>{{$item := index .Lists 0}}{{range $k, $v := $item}}
{{$k}}:{{$v}}{{end}}
</pre>

{{ template "footer" .}}
