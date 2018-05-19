{{ template "header" .}}
{{ template "paymentheader" .}}

<h3>Your current balance: {{$self := index .Other.adv_edit 0}}{{$self.balance}}
<h3>Payments</h3>

<div class="table-responsive">
<table class="table table-striped table-sm">
<thead><tr>
<th>Tyep</th>
<th>ID</th>
<th>Amount</th>
<th>Created</th>
<th></th>
</tr></thead>
<tbody>{{with .Lists}}{{range .}}
<td>{{.paytype_id}}</td>
<td>{{.entity_id}}</td>
<td>{{.amount}}</td>
<td>{{.created}}</td>
{{$second := print "payment_id=" .payment_id "&payment_md5=" .payment_md5}}
<td><a href="payment?action=edit&{{$second}}">View</a></td>
</tr>{{end}}{{end}}
</tbody>
</table>
</div>

<form class="form" method="post" action="payment">
<input type=hidden name="action" value="insert" />
<pre>
Pay Method: <select name=paymethod><option value="1">Cash</option><option value="2">Debt</option>{{if .Other}}{{if .Other.paymethods}}{{range $item := .Other.paymethods}}<option value="{{$item.paytype_id}}_{{$item.entity_id}}_{{$item.entity_md5}}">{{$item.paytype_value}} {{$item.id}}</option>{{end}}{{end}}{{end}}</select>
Amount: <input type=text name=amount />
</pre>
<input type=submit value=" Add to My Account " />
</form>

<h3>New Pay Method</h3>

<pre>
<a href="cc?action=startnew">New Credit Card</a>
<a href="cheque?action=startnew">New Cheque</a>
<a href="wechat?action=startnew">New Wechat Pay</a>
<a href="alipay?action=startnew">New Alipay</a>
</pre>

{{template "footer"}}
