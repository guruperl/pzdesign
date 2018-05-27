{{ template "header" .}}
{{ template "paymentheader" .}}

<h3>您要充值{{index .ARGS.amount 0}} 元。请等待我们后台审核，审核通过后我们将通知您！</h3>

{{template "footer"}}
