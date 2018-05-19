{{ template "header" .}}
{{ template "paymentheader" .}}

<h3>账户当前余额:<b><font color="darkblue"> {{$self := index .Other.adv_edit 0}}{{$self.balance}}</font></b>元</h3>
<br>

<div class="row">
                <div class="col-lg-12">
                <div class="panel panel-primary">
                    <div class="panel-heading">
                      <font size= 4>充值</font>
                    </div>
                    <div class="panel-body">
                    <div style= 'font-size: 17px;'>
<form class="form" method="post" action="payment">
<input type=hidden name="action" value="insert" />

充值方式: <select name=paytype_id><option value="1">现金充值</option><option value="2">欠债</option>{{if .Other}}{{if .Other.paymethods}}{{range $item := .Other.paymethods}}<option value="{{$item.paytype_id}}_{{$item.entity_id}}_{{$item.entity_md5}}">{{$item.paytype_value}} {{$item.id}}</option>{{end}}{{end}}{{end}}</select>
<font color="gray" size = 2>目前充值采用线下充值方式，如果要充值请联系023-1234567</font>
<br>充值金额(元): <input type=text name=amount />

<br><input type=submit value=" 确定充值 " />
</form>
</div>
</div>
</div>
</div>
</div>

<div class="row">
                <div class="col-lg-12">
                <div class="panel panel-primary">
                    <div class="panel-heading">
                      <font size= 4>充值记录</font>
                    </div>
                    <div class="panel-body">
<div style= 'font-size: 17px;'>

<div class="table-responsive">
<table class="table table-striped table-sm">
<thead><tr>
<th>充值方式</th>
<th>充值记录id</th>
<th>充值金额</th>
<th>创建时间</th>
<th>充值状态</th>
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

              </div>
            </div>
        </div>
    </div>


<div class="row">
                <div class="col-lg-12">
                <div class="panel panel-primary">
                    <div class="panel-heading">
                       <font size = 4>下个版本新增充值方式</font>
                    </div>
                    <div class="panel-body">
<div style= 'font-size: 17px;'>
微信支付
<br>支付宝支付
<!--
<pre>
<a href="cc?action=startnew"><font size=4>信用卡充值</font></a>
<a href="cheque?action=startnew"><font size=4>支票充值</font></a>
<a href="wechat?action=startnew"><font size=4>微信支付</font></a>
<a href="alipay?action=startnew"><font size=4>支付宝支付</font></a>
</pre>
--!>
              </div>
            </div>
        </div>
    </div>
 </div>
{{template "footer"}}
