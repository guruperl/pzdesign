{{template "header" .}}
<div class="container-fluid">
  <h1 class="h3">广告账户资金管理</h1>
  <p class="text-muted">付款信息由 Stripe 托管页面采集。W8M 只保存不透明的客户、结账和交易标识，不接收或保存完整卡号、银行账号或路由信息。</p>
  {{if .Other.PaymentMessage}}<div class="alert alert-success">{{.Other.PaymentMessage}}</div>{{end}}
  <div class="row">
    <div class="col-lg-6">
      <div class="card"><div class="card-body">
        <h2 class="h5">建立托管付款客户</h2>
        <p>首次使用时建立一次。绑定须经独立人员复核后才可进入托管结账；没有已核准且就绪的绑定时不能提交付款。</p>
        <form method="post" action="hostedpayment?action=fundingCustomer">{{.Other.CSRFInput}}
          <input type="hidden" name="adv_id" value="{{.Other.PaymentScope.PartyID}}">
          <label>幂等请求号</label><input class="form-control" name="request_key" maxlength="128" placeholder="例如 funding-customer-202608" required>
          <label>操作原因</label><input class="form-control" name="reason" maxlength="500" required>
          <button class="btn btn-outline-danger mt-2" type="submit">建立托管客户</button>
        </form>
      </div></div>
    </div>
    <div class="col-lg-6">
      <div class="card"><div class="card-body">
        <h2 class="h5">申请支付已确认账单</h2>
        <p>金额必须是精确到美分的 USD，且不得超过对应的 Confirmed 账单。申请需经独立复核后才能跳转到托管付款页。</p>
        <form method="post" action="hostedpayment?action=proposeFunding">{{.Other.CSRFInput}}
          <input type="hidden" name="adv_id" value="{{.Other.PaymentScope.PartyID}}">
          <label>账单 ID</label><input class="form-control" type="number" min="1" name="statement_id" required>
          <label>金额（USD）</label><input class="form-control" name="amount" pattern="[0-9]+\.[0-9]{2,6}" placeholder="100.00" required>
          <label>幂等请求号</label><input class="form-control" name="request_key" maxlength="128" required>
          <label>操作原因</label><input class="form-control" name="reason" maxlength="500" required>
          <button class="btn btn-danger mt-2" type="submit">提交付款申请</button>
        </form>
      </div></div>
    </div>
  </div>
  <h2 class="h4 mt-4">账单</h2>
  <div class="table-responsive"><table class="table table-sm table-striped"><thead><tr><th>ID</th><th>周期</th><th>金额</th><th>状态</th></tr></thead><tbody>
    {{range .Other.PaymentStatements}}<tr><td>{{.ID}}</td><td>{{.PeriodStart}} 至 {{.PeriodEnd}}</td><td>{{.TotalAmount}} {{.Currency}}</td><td>{{.Status}}</td></tr>{{else}}<tr><td colspan="4">暂无账单。</td></tr>{{end}}
  </tbody></table></div>
  <h2 class="h4 mt-4">付款操作</h2>
  <div class="table-responsive"><table class="table table-sm table-striped"><thead><tr><th>ID</th><th>类型 / 账单</th><th>金额</th><th>状态</th><th>操作</th></tr></thead><tbody>
    {{range .Other.PaymentOperations}}<tr><td>{{.ID}}</td><td>{{.Kind}} / #{{.StatementID}}</td><td>{{.Amount}} {{.Currency}}</td><td>{{.Status}}{{if .FailureCode.Valid}}<br><small>{{.FailureCode.String}}</small>{{end}}</td><td>
      {{if eq .Status "Approved"}}<form method="post" action="hostedpayment?action=executeOperation">{{$.Other.CSRFInput}}<input type="hidden" name="operation_id" value="{{.ID}}"><input type="hidden" name="operation_version" value="{{.Version}}"><button class="btn btn-sm btn-danger" type="submit">前往托管付款页</button></form>{{end}}
      {{if and (eq .Kind "Funding") (eq .Status "Submitted")}}<form method="post" action="hostedpayment?action=executeOperation">{{$.Other.CSRFInput}}<input type="hidden" name="operation_id" value="{{.ID}}"><input type="hidden" name="operation_version" value="{{.Version}}"><button class="btn btn-sm btn-outline-danger" type="submit">重新打开托管付款页</button></form>{{end}}
      {{if or (eq .Status "Proposed") (and (eq .Status "Approved") (eq .AttemptCount 0)) (and (eq .Kind "Funding") (or (eq .Status "Submitted") (eq .Status "Canceling")))}}<form method="post" action="hostedpayment?action=cancelOperation">{{$.Other.CSRFInput}}<input type="hidden" name="operation_id" value="{{.ID}}"><input type="hidden" name="operation_version" value="{{.Version}}"><input name="reason" maxlength="500" placeholder="取消原因" required><button class="btn btn-sm btn-outline-secondary" type="submit">{{if eq .Status "Canceling"}}继续取消{{else}}取消{{end}}</button></form>{{end}}
    </td></tr>{{else}}<tr><td colspan="5">暂无托管付款操作。</td></tr>{{end}}
  </tbody></table></div>
  <h2 class="h4 mt-4">不透明账户绑定</h2>
  <div class="table-responsive"><table class="table table-sm"><thead><tr><th>ID</th><th>类型</th><th>服务商标识</th><th>状态</th></tr></thead><tbody>{{range .Other.PaymentBindings}}<tr><td>{{.ID}}</td><td>{{.Kind}}</td><td><code>{{.ProviderToken}}</code></td><td>{{.Status}}</td></tr>{{else}}<tr><td colspan="4">暂无绑定。</td></tr>{{end}}</tbody></table></div>
</div>
{{template "footer" .}}
