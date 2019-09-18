{{ template "header" .}}
{{ template "itemheader" .}}

<h3>广告条细节</h3>
<pre>{{$item := index .Lists 0}}{{range $k, $v := $item}}
{{$k}}:{{$v}}{{end}}
</pre>

{{ template "footer" .}}
