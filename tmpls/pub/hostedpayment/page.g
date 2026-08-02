{{template "header" .}}
<div class="container-fluid">
  <h1 class="h3">媒体收益结算账户</h1>
  <p class="text-muted">收款账户、身份核验与银行资料只在 Stripe 托管页面填写。W8M 仅保存不透明的 Connect 账户标识，不保存完整银行账号或路由信息。</p>
  {{if .Other.PaymentMessage}}<div class="alert alert-success">{{.Other.PaymentMessage}}</div>{{end}}
  <div class="card border-success"><div class="card-body">
    <h2 class="h5">开通托管收款账户</h2><p>请选择经营主体所在国家或地区的两位代码。完成托管核验后，绑定仍须由独立人员复核。</p>
    <form method="post" action="hostedpayment?action=payoutOnboarding">{{.Other.CSRFInput}}<input type="hidden" name="pub_id" value="{{.Other.PaymentScope.PartyID}}"><label>国家或地区代码</label><input class="form-control" name="country" minlength="2" maxlength="2" value="US" required><label>幂等请求号</label><input class="form-control" name="request_key" maxlength="128" required><label>操作原因</label><input class="form-control" name="reason" maxlength="500" required><button class="btn btn-success mt-2" type="submit">进入托管开通流程</button></form>
  </div></div>
  <h2 class="h4 mt-4">收款账户绑定</h2><div class="table-responsive"><table class="table table-sm table-striped"><thead><tr><th>ID</th><th>不透明服务商标识</th><th>托管就绪</th><th>状态</th><th>操作</th></tr></thead><tbody>
    {{range .Other.PaymentBindings}}<tr><td>{{.ID}}</td><td><code>{{.ProviderToken}}</code>{{if .Country.Valid}}<br><small>{{.Country.String}}</small>{{end}}</td><td>{{.ProviderReady}}</td><td>{{.Status}}</td><td>{{if or (eq .Status "Proposed") (and (eq .Status "Revoked") .RevokedBy.Valid (eq .RevokedBy.String "provider:stripe"))}}<form method="post" action="hostedpayment?action=refreshOnboarding">{{$.Other.CSRFInput}}<input type="hidden" name="pub_id" value="{{$.Other.PaymentScope.PartyID}}"><input type="hidden" name="binding_id" value="{{.ID}}"><input type="hidden" name="binding_version" value="{{.Version}}"><input name="request_key" maxlength="128" placeholder="新的幂等请求号" required><input name="reason" maxlength="500" placeholder="继续开通的原因" required><button class="btn btn-sm btn-outline-success" type="submit">继续托管开通</button></form>{{else if eq .Status "Ready"}}等待独立复核{{else if eq .Status "Approved"}}已核准{{else}}已撤销{{end}}</td></tr>{{else}}<tr><td colspan="5">尚未建立托管收款账户。</td></tr>{{end}}
  </tbody></table></div>
  <h2 class="h4 mt-4">结算账单</h2><div class="table-responsive"><table class="table table-sm"><thead><tr><th>ID</th><th>周期</th><th>金额</th><th>状态</th></tr></thead><tbody>{{range .Other.PaymentStatements}}<tr><td>{{.ID}}</td><td>{{.PeriodStart}} 至 {{.PeriodEnd}}</td><td>{{.TotalAmount}} {{.Currency}}</td><td>{{.Status}}</td></tr>{{else}}<tr><td colspan="4">暂无结算账单。</td></tr>{{end}}</tbody></table></div>
  <h2 class="h4 mt-4">打款进度</h2><div class="table-responsive"><table class="table table-sm table-striped"><thead><tr><th>ID</th><th>账单</th><th>金额</th><th>状态</th><th>更新时间</th></tr></thead><tbody>{{range .Other.PaymentOperations}}<tr><td>{{.ID}}</td><td>#{{.StatementID}}</td><td>{{.Amount}} {{.Currency}}</td><td>{{.Status}}</td><td>{{.UpdatedAt}}</td></tr>{{else}}<tr><td colspan="5">暂无打款操作。</td></tr>{{end}}</tbody></table></div>
</div>
{{template "footer" .}}
