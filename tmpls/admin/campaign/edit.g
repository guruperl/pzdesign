{{ template "header" .}}
{{ template "campaignheader" .}}

<h3>活动细节</h3>
<pre>{{$item := index .Lists 0}}{{range $k, $v := $item}}
{{$k}}:{{$v}}{{end}}
</pre>

{{ template "footer" .}}
