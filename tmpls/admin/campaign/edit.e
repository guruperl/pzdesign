{{ template "header" .}}
{{ template "campaignheader" .}}

<h3>Campaigns</h3>
<pre>{{$item := index .Lists 0}}{{range $k, $v := $item}}
{{$k}}:{{$v}}{{end}}
</pre>

{{ template "footer" .}}
