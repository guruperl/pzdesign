{{ template "header" .}}
{{ template "paymentheader" .}}

<h3>Existing Payments</h3>
<div class="table-responsive">
	<table class="table table-striped table-sm">
    	<thead>
        <tr>
            <th>Name</th>
        	<th>Payment</th>
        	<th>Method</th>
			<th>Status</th>
            <th>When</th>
            <th></th>
            <th></th>
        </tr>
        </thead>
        <tbody>{{ with .Lists }}{{ range . }}
			<tr>
				<td><a href="adv?action=edit&adv_id={{.adv_id}}">{{.sender_name}}</a></td>
				<td><a href="payment?action=edit&payment_id={{.payment_id}}">{{.amount}}</a></td>
				<td>{{.paytype_value}}</td>
				<td>{{.status}}</td>
				<td>{{.created}}</td>
				<td>
{{if eq .status "New"}}<a class="btn btn-sm btn-success" href="payment?action=update&status=Confirmed&payment_id={{.payment_id}}">Accept</a> <a class="btn btn-sm btn-primary" href="payment?action=update&status=Failed&payment_id={{.payment_id}}">Rejected</a>{{end}}
{{if eq .status "Confirmed"}}<a class="btn btn-sm btn-success" href="payment?action=update&status=Completed&payment_id={{.payment_id}}">Complete</a>{{end}}
</td>
				<td><a href="payment?action=delete&payment_id={{.payment_id}}">Del</a></td>
			</tr>{{end}}{{end}}
		</tbody>
	</table>
</div>

{{ template "footer" .}}
