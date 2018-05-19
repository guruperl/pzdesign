{{ template "header" .}}
{{ template "paymentheader" .}}

<h3>Your current balance: {{$self := index .Other.adv_edit 0}}{{$self.balance}}</h3>
<br>

<div class="row">
                <div class="col-lg-12">
                <div class="panel panel-primary">
                    <div class="panel-heading">
                      <h3>Payments</h3>
                    </div>
                    <div class="panel-body">
<div style= 'font-size: 17px;'>

<div class="table-responsive">
<table class="table table-striped table-sm">
<thead><tr>
<th>Type</th>
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
Pay Method: <select name=paytype_id><option value="1">Cash</option><option value="2">Debt</option>{{if .Other}}{{if .Other.paymethods}}{{range $item := .Other.paymethods}}<option value="{{$item.paytype_id}}_{{$item.entity_id}}_{{$item.entity_md5}}">{{$item.paytype_value}} {{$item.id}}</option>{{end}}{{end}}{{end}}</select>
Amount: <input type=text name=amount />
</pre>
<input type=submit value=" Add to My Account " />
</form>
              </div>
            </div>
        </div>
    </div>


<div class="row">
                <div class="col-lg-12">
                <div class="panel panel-primary">
                    <div class="panel-heading">
                       <h3>New Pay Method</h3>
                    </div>
                    <div class="panel-body">
<pre>
<a href="cc?action=startnew"><font size=4>New Credit Card</font></a>
<a href="cheque?action=startnew"><font size=4>New Cheque</font></a>
<a href="wechat?action=startnew"><font size=4>New Wechat Pay</font></a>
<a href="alipay?action=startnew"><font size=4>New Alipay</font></a>
</pre>
              </div>
            </div>
        </div>
    </div>
</div>
{{template "footer"}}
