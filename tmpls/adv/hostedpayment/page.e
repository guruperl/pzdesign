{{template "header" .}}
<div class="container-fluid">
  <h1 class="h3">Advertiser Account Funding</h1>
  <p class="text-muted">Payment information is collected on Stripe-hosted pages. W8M stores only opaque customer, checkout, and transaction identifiers and never receives or stores full card, bank-account, or routing numbers.</p>
  {{if .Other.PaymentMessage}}<div class="alert alert-success">{{.Other.PaymentMessage}}</div>{{end}}
  <div class="row">
    <div class="col-lg-6">
      <div class="card"><div class="card-body">
        <h2 class="h5">Create Hosted Payment Customer</h2>
        <p>Create this once on first use. The binding requires independent review before hosted checkout is available; payment cannot be submitted without an approved, ready binding.</p>
        <form method="post" action="hostedpayment?action=fundingCustomer">{{.Other.CSRFInput}}
          <input type="hidden" name="adv_id" value="{{.Other.PaymentScope.PartyID}}">
          <label>Idempotency Request Key</label><input class="form-control" name="request_key" maxlength="128" placeholder="For example, funding-customer-202608" required>
          <label>Reason</label><input class="form-control" name="reason" maxlength="500" required>
          <button class="btn btn-outline-danger mt-2" type="submit">Create Hosted Customer</button>
        </form>
      </div></div>
    </div>
    <div class="col-lg-6">
      <div class="card"><div class="card-body">
        <h2 class="h5">Request Payment of a Confirmed Statement</h2>
        <p>The amount must be exact USD to the cent and cannot exceed the corresponding Confirmed statement. The request requires independent review before redirecting to hosted payment.</p>
        <form method="post" action="hostedpayment?action=proposeFunding">{{.Other.CSRFInput}}
          <input type="hidden" name="adv_id" value="{{.Other.PaymentScope.PartyID}}">
          <label>Statement ID</label><input class="form-control" type="number" min="1" name="statement_id" required>
          <label>Amount (USD)</label><input class="form-control" name="amount" pattern="[0-9]+\.[0-9]{2,6}" placeholder="100.00" required>
          <label>Idempotency Request Key</label><input class="form-control" name="request_key" maxlength="128" required>
          <label>Reason</label><input class="form-control" name="reason" maxlength="500" required>
          <button class="btn btn-danger mt-2" type="submit">Submit Payment Request</button>
        </form>
      </div></div>
    </div>
  </div>
  <h2 class="h4 mt-4">Statements</h2>
  <div class="table-responsive"><table class="table table-sm table-striped"><thead><tr><th>ID</th><th>Period</th><th>Amount</th><th>Status</th></tr></thead><tbody>
    {{range .Other.PaymentStatements}}<tr><td>{{.ID}}</td><td>{{.PeriodStart}} to {{.PeriodEnd}}</td><td>{{.TotalAmount}} {{.Currency}}</td><td>{{.Status}}</td></tr>{{else}}<tr><td colspan="4">No statements.</td></tr>{{end}}
  </tbody></table></div>
  <h2 class="h4 mt-4">Payment Operations</h2>
  <div class="table-responsive"><table class="table table-sm table-striped"><thead><tr><th>ID</th><th>Type / Statement</th><th>Amount</th><th>Status</th><th>Action</th></tr></thead><tbody>
    {{range .Other.PaymentOperations}}<tr><td>{{.ID}}</td><td>{{.Kind}} / #{{.StatementID}}</td><td>{{.Amount}} {{.Currency}}</td><td>{{.Status}}{{if .FailureCode.Valid}}<br><small>{{.FailureCode.String}}</small>{{end}}</td><td>
      {{if eq .Status "Approved"}}<form method="post" action="hostedpayment?action=executeOperation">{{$.Other.CSRFInput}}<input type="hidden" name="operation_id" value="{{.ID}}"><input type="hidden" name="operation_version" value="{{.Version}}"><button class="btn btn-sm btn-danger" type="submit">Go to Hosted Payment</button></form>{{end}}
      {{if and (eq .Kind "Funding") (eq .Status "Submitted")}}<form method="post" action="hostedpayment?action=executeOperation">{{$.Other.CSRFInput}}<input type="hidden" name="operation_id" value="{{.ID}}"><input type="hidden" name="operation_version" value="{{.Version}}"><button class="btn btn-sm btn-outline-danger" type="submit">Reopen Hosted Payment</button></form>{{end}}
      {{if or (eq .Status "Proposed") (and (eq .Status "Approved") (eq .AttemptCount 0)) (and (eq .Kind "Funding") (or (eq .Status "Submitted") (eq .Status "Canceling")))}}<form method="post" action="hostedpayment?action=cancelOperation">{{$.Other.CSRFInput}}<input type="hidden" name="operation_id" value="{{.ID}}"><input type="hidden" name="operation_version" value="{{.Version}}"><input name="reason" maxlength="500" placeholder="Cancellation reason" required><button class="btn btn-sm btn-outline-secondary" type="submit">{{if eq .Status "Canceling"}}Continue Cancellation{{else}}Cancel{{end}}</button></form>{{end}}
    </td></tr>{{else}}<tr><td colspan="5">No hosted payment operations.</td></tr>{{end}}
  </tbody></table></div>
  <h2 class="h4 mt-4">Opaque Account Bindings</h2>
  <div class="table-responsive"><table class="table table-sm"><thead><tr><th>ID</th><th>Type</th><th>Provider Identifier</th><th>Status</th></tr></thead><tbody>{{range .Other.PaymentBindings}}<tr><td>{{.ID}}</td><td>{{.Kind}}</td><td><code>{{.ProviderToken}}</code></td><td>{{.Status}}</td></tr>{{else}}<tr><td colspan="4">No bindings.</td></tr>{{end}}</tbody></table></div>
</div>
{{template "footer" .}}
