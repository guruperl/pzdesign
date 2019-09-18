{{ template "header" .}}
{{ template "paymentheader" .}}

<h3>账户当前余额:<b><font color="darkblue"> {{$self := index .Other.adv_edit 0}}{{$self.balance}}</font></b>元</h3>

<div class="row">
	<div class="col-lg-12">
			<div class="panel panel-primary">
                    <div class="panel-heading">
                      充值
                    </div>
                    <div class="panel-body">

<form class="form" method="post" action="payment">
<input type=hidden name="action" value="insert" />

        <form class="form" method="post" action="payment">
            <input type=hidden name="action" value="insert" />

            <div class="form-group row">
                <div class="col-sm-12">
                    <div class="form-check form-check-inline">
                        <label class="form-check-label">充值方式:</label>
                        <input class="form-check-input" type=radio name=paytype_id value="1"><label class="form-check-label">现金</label>
                        <input class="form-check-input" type=radio name=paytype_id value="2"><label class="form-check-label">贷款</label>
                    </div>
                </div>
            </div>

            <div class="form-group row">
                <div class="col-sm-12">
                    <div class="form-check form-check-inline">
                        <label class="form-check-label">充值金额(元):</label>
                        <input class="form-check-input" type=text name=amount placeholder="100.0">
                        <input class="btn btn-primary" type=submit value="确定充值" />
                    </div>
                </div>
            </div>
        </form>



                      <h4>充值记录:</h4>

<div class="table-responsive">
<table class="table table-striped table-sm">
<thead><tr>
<th>充值ID</th>
<th>充值方式</th>
<th>充值金额</th>
<th>创建时间</th>
<th>充值状态</th>
</tr></thead>
<tbody>{{with .Lists}}{{range .}}{{$second := print "payment_id=" .payment_id "&payment_md5=" .payment_md5}}
<td><a href="payment?action=edit&{{$second}}">{{.payment_id}}</a></td>
<td>{{.paytype_value}}</td>
<td>{{.amount}}</td>
<td>{{.created}}</td>
<td>{{.status}}</td>
</tr>{{end}}{{end}}
</tbody>
</table>
</div>

            </div>
        </div>
    </div>
</div>

{{template "footer"}}
