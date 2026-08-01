{{ template "header" .}}
{{ template "paymentheader" .}}

<h4>Your current balance: {{$self := index .Other.adv_edit 0}}{{$self.balance}}</h4>

<div class="row">
	<div class="col-lg-12">
		<div class="panel panel-primary">
			<div class="panel-heading">
				Payment History
			</div>
			<div class="panel-body">

<div class="table-responsive">
<table class="table table-striped table-condensed">
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
<td><a href="payment?action=edit&payment_id={{.payment_id}}&payment_md5={{.payment_md5}}">View</a></td>
</tr>{{end}}{{end}}
</tbody>
</table>
</div>

		<form class="form" method="post" action="payment">
			<input type=hidden name="action" value="insert" />

            <div class="form-group row">
                <div class="col-sm-12">
                    <div class="form-check form-check-inline">
						<label class="form-check-label">Pay Method:</label>
                        <input class="form-check-input" type=radio name=paytype_id value="1"><label class="form-check-label">Cash</label>
                        <input class="form-check-input" type=radio name=paytype_id value="2"><label class="form-check-label">Debt</label>
                        {{if .Other}}{{if .Other.paymethods}}{{range $item := .Other.paymethods}}<input class="form-check-input" type=radio name=paytype_id value="{{$item.paytype_id}}_{{$item.entity_id}}_{{$item.entity_md5}}"><label class="form-check-label">{{$item.paytype_value}} {{$item.id}}</label>{{end}}{{end}}{{end}}
                    </div>
                </div>
            </div>

            <div class="form-group row">
                <div class="col-sm-12">
                    <div class="form-check form-check-inline">
						<label class="form-check-label">Amount:</label>
                        <input class="form-check-input" type=text name=amount placeholder="100.0">
						<input class="btn btn-primary" type=submit value="Add to My Account" />
					</div>
            	</div>
            </div>
		</form>

<a class="btn btn-sm" href="cc?action=startnew">New Credit Card</a>
<a class="btn btn-sm" href="cheque?action=startnew">New Cheque</a>
<a class="btn btn-sm" href="wechat?action=startnew">New Wechat Pay</a>
<a class="btn btn-sm" href="alipay?action=startnew">New Alipay</a>
        	</div>
    	</div>
	</div>
</div>

{{template "footer"}}
