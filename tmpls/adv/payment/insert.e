{{ template "header" .}}
{{ template "paymentheader" .}}

<h3>{{index .ARGS.amount 0}} added. We will notify you when it is successful.</h3>

{{template "footer"}}
