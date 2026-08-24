package hostedpayment

import (
	"crypto/sha256"
	"encoding/hex"
	"fmt"
	"net/url"
	"strconv"
	"strings"

	"github.com/guruperl/aofei/accounting"
	payment "github.com/guruperl/aofei/hostedpayment"
	"github.com/guruperl/genelet"
	"github.com/guruperl/pzdesign/summer"
)

type Filter struct{ summer.Filter }

var paymentPermissions = []string{
	payment.PermissionRead, payment.PermissionFundingBind, payment.PermissionPayoutBind,
	payment.PermissionBindingApprove, payment.PermissionCheckoutPropose,
	payment.PermissionPayoutPropose, payment.PermissionRefundPropose,
	payment.PermissionOperationApprove, payment.PermissionOperationExecute,
	payment.PermissionOperationCancel, payment.PermissionDisputeHandle,
	payment.PermissionReconcile, payment.PermissionSecretReadiness,
}

func (f *Filter) Before(model *Model, _, _ url.Values) error {
	service, _ := model.Storage["HostedPayment"].(*payment.Service)
	if service == nil {
		return genelet.Err(503, "托管资金与结算服务尚未启用")
	}
	actor, scope, err := paymentActor(f)
	if err != nil {
		return err
	}
	args := f.R.Form
	other := *f.OTHER
	other["PaymentScope"] = scope
	other["PaymentIsAdmin"] = actor.Role == "admin"
	other["PaymentIsAdvertiser"] = actor.Role == "adv"
	other["PaymentIsPublisher"] = actor.Role == "pub"
	other["CSRFInput"] = f.CSRFInput()

	switch f.Action {
	case "fundingCustomer":
		id, err := requiredUint(args.Get("adv_id"), "advertiser id")
		if err != nil {
			return err
		}
		binding, err := service.StartFundingCustomer(f.R.Context(), actor, id, args.Get("request_key"), args.Get("reason"))
		if err != nil {
			return err
		}
		other["PaymentMessage"] = fmt.Sprintf("广告主托管付款客户已创建，绑定 #%d 等待独立复核。", binding.ID)
		setPaymentAudit(args, "HostedFundingCustomerProposed", binding.ID, "Absent", string(binding.Status))
	case "payoutOnboarding":
		id, err := requiredUint(args.Get("pub_id"), "publisher id")
		if err != nil {
			return err
		}
		binding, redirect, err := service.StartPayoutOnboarding(f.R.Context(), actor, id, strings.ToUpper(args.Get("country")), args.Get("request_key"), args.Get("reason"))
		if err != nil {
			return err
		}
		setPaymentAudit(args, "HostedPayoutOnboardingStarted", binding.ID, "Absent", string(binding.Status))
		return genelet.Gerror{Code: 303, Errstr: redirect.URL}
	case "refreshOnboarding":
		bindingID, version, err := formIdentity(args, "binding")
		if err != nil {
			return err
		}
		redirect, err := service.RefreshPayoutOnboarding(f.R.Context(), actor, bindingID, uint32(version), args.Get("request_key"), args.Get("reason"))
		if err != nil {
			return err
		}
		setPaymentAudit(args, "HostedPayoutOnboardingRefreshed", bindingID, "Pending", "Pending")
		return genelet.Gerror{Code: 303, Errstr: redirect.URL}
	case "approveBinding":
		bindingID, version, err := formIdentity(args, "binding")
		if err != nil {
			return err
		}
		if err := service.ApproveBinding(f.R.Context(), actor, bindingID, uint32(version), args.Get("reason")); err != nil {
			return err
		}
		other["PaymentMessage"] = "托管账户绑定已经独立复核并生效。"
		setPaymentAudit(args, "HostedBindingApproved", bindingID, "Ready", "Approved")
	case "proposeFunding", "proposePayout", "proposeRefund":
		operation, err := proposeOperation(service, f, actor)
		if err != nil {
			return err
		}
		other["PaymentMessage"] = fmt.Sprintf("资金操作 #%d 已建立，等待独立复核。", operation.ID)
		setPaymentAudit(args, "HostedOperationProposed", operation.ID, "Absent", string(operation.Status))
	case "approveOperation":
		operationID, version, err := formIdentity(args, "operation")
		if err != nil {
			return err
		}
		if err := service.ApproveOperation(f.R.Context(), actor, operationID, uint32(version), args.Get("reason")); err != nil {
			return err
		}
		other["PaymentMessage"] = "资金操作已经独立复核，可进入执行步骤。"
		setPaymentAudit(args, "HostedOperationApproved", operationID, "Proposed", "Approved")
	case "executeOperation":
		operationID, version, err := formIdentity(args, "operation")
		if err != nil {
			return err
		}
		result, err := service.ExecuteOperation(f.R.Context(), actor, operationID, uint32(version))
		if err != nil {
			return err
		}
		setPaymentAudit(args, "HostedOperationSubmitted", operationID, "Approved", string(result.Operation.Status))
		if result.Redirect != nil {
			return genelet.Gerror{Code: 303, Errstr: result.Redirect.URL}
		}
		other["PaymentMessage"] = "资金操作已按原幂等键提交给托管服务商，最终结果以签名回调和对账为准。"
	case "cancelOperation":
		operationID, version, err := formIdentity(args, "operation")
		if err != nil {
			return err
		}
		if err := service.CancelOperation(f.R.Context(), actor, operationID, uint32(version), args.Get("reason")); err != nil {
			return err
		}
		other["PaymentMessage"] = "尚未结算的资金操作已取消。"
		setPaymentAudit(args, "HostedOperationCanceled", operationID, "Pending", "Canceled")
	case "reconcile":
		operationID, err := requiredUint(args.Get("operation_id"), "operation id")
		if err != nil {
			return err
		}
		summary, err := service.ReconcileOperation(f.R.Context(), actor, operationID, args.Get("reason"))
		if err != nil {
			return err
		}
		other["PaymentReconciliationSummary"] = summary
		other["PaymentMessage"] = fmt.Sprintf("操作 #%d 对账完成；匹配：%t，未决项：%d。", operationID, summary.Matched, summary.Exceptions)
		setPaymentAudit(args, "HostedOperationReconciled", operationID, "Recorded", "Reviewed")
	case "resolveReconciliation":
		id, err := requiredUint(args.Get("reconciliation_id"), "reconciliation id")
		if err != nil {
			return err
		}
		if err := service.ResolveReconciliation(f.R.Context(), actor, id, args.Get("reason")); err != nil {
			return err
		}
		other["PaymentMessage"] = "未决对账项已由独立人员复核关闭。"
		setPaymentAudit(args, "HostedReconciliationResolved", id, "Unresolved", "Resolved")
	case "secretReadiness":
		readiness, err := service.CheckSecretReadiness(f.R.Context(), actor, args.Get("reason"))
		if err != nil {
			return err
		}
		other["PaymentSecretReadiness"] = readiness
		other["PaymentMessage"] = "密钥引用就绪检查已完成；页面不会显示任何密钥值。"
		setPaymentAudit(args, "HostedSecretReadinessChecked", 0, "Unknown", "Checked")
	}

	bindings, err := service.ListBindings(f.R.Context(), actor, scope)
	if err != nil {
		return err
	}
	operations, err := service.ListOperations(f.R.Context(), actor, scope)
	if err != nil {
		return err
	}
	reconciliations, err := service.ListReconciliations(f.R.Context(), actor, scope)
	if err != nil {
		return err
	}
	var statements []accounting.Statement
	if scope.PartyType != "" {
		statements, err = (accounting.Service{DB: service.DB}).ListStatements(f.R.Context(), scope.PartyType, scope.PartyID)
		if err != nil {
			return err
		}
	}
	other["PaymentBindings"] = bindings
	other["PaymentOperations"] = operations
	other["PaymentReconciliations"] = reconciliations
	other["PaymentStatements"] = statements
	return nil
}

func proposeOperation(service *payment.Service, f *Filter, actor payment.Actor) (payment.Operation, error) {
	args := f.R.Form
	statementID, err := requiredUint(args.Get("statement_id"), "statement id")
	if err != nil {
		return payment.Operation{}, err
	}
	amount, err := accounting.ParseMoney(args.Get("amount"))
	if err != nil {
		return payment.Operation{}, err
	}
	input := payment.ProposeOperationInput{RequestKey: args.Get("request_key"), StatementID: statementID, Amount: amount, Reason: args.Get("reason")}
	switch f.Action {
	case "proposeFunding":
		input.Kind = payment.OperationFunding
		input.PartyID, err = requiredUint(args.Get("adv_id"), "advertiser id")
	case "proposePayout":
		input.Kind = payment.OperationPayout
		input.PartyID, err = requiredUint(args.Get("pub_id"), "publisher id")
	case "proposeRefund":
		input.Kind = payment.OperationRefund
		input.PartyID, err = requiredUint(args.Get("adv_id"), "advertiser id")
		if err == nil {
			input.ParentOperationID, err = requiredUint(args.Get("parent_operation_id"), "parent operation id")
		}
	}
	if err != nil {
		return payment.Operation{}, err
	}
	return service.ProposeOperation(f.R.Context(), actor, input)
}

func paymentActor(f *Filter) (payment.Actor, payment.Scope, error) {
	args := f.R.Form
	recentMFA, err := summer.VerifiedSessionState(args)
	if err != nil {
		return payment.Actor{}, payment.Scope{}, err
	}
	role := args.Get("_grole")
	roleConfig, ok := f.C.Roles[role]
	if !ok || roleConfig.Id_name == "" {
		return payment.Actor{}, payment.Scope{}, fmt.Errorf("authenticated payment actor is unavailable")
	}
	id := args.Get(roleConfig.Id_name)
	if _, err := requiredUint(id, "actor id"); err != nil {
		return payment.Actor{}, payment.Scope{}, err
	}
	permissions := make(map[string]bool)
	for _, permission := range paymentPermissions {
		if hasPermission(roleConfig.Permissions, permission) {
			permissions[permission] = true
		}
	}
	if hasPermission(roleConfig.Permissions, "*") {
		permissions["*"] = true
	}
	var actorScope payment.Scope
	switch role {
	case "adv":
		actorID, _ := strconv.ParseUint(id, 10, 64)
		actorScope = payment.Scope{PartyType: payment.PartyAdvertiser, PartyID: actorID}
		args.Set("adv_id", id)
	case "pub":
		actorID, _ := strconv.ParseUint(id, 10, 64)
		actorScope = payment.Scope{PartyType: payment.PartyPublisher, PartyID: actorID}
		args.Set("pub_id", id)
	case "admin":
	default:
		return payment.Actor{}, payment.Scope{}, fmt.Errorf("role is not a financial account role")
	}
	scope := actorScope
	if role == "admin" {
		party := payment.PartyType(args.Get("party_type"))
		if party != "" || args.Get("party_id") != "" {
			partyID, err := requiredUint(args.Get("party_id"), "party id")
			if err != nil || party != payment.PartyAdvertiser && party != payment.PartyPublisher {
				return payment.Actor{}, payment.Scope{}, fmt.Errorf("payment list scope is invalid")
			}
			scope = payment.Scope{PartyType: party, PartyID: partyID}
		}
	}
	return payment.Actor{Role: role, ID: id, Scope: actorScope, Permissions: permissions, RecentMFA: recentMFA}, scope, nil
}

func paymentActionRequiresMFA(action string) bool {
	switch action {
	case "fundingCustomer", "payoutOnboarding", "refreshOnboarding", "approveBinding",
		"proposeFunding", "proposePayout", "proposeRefund", "approveOperation",
		"executeOperation", "cancelOperation", "reconcile", "resolveReconciliation",
		"secretReadiness":
		return true
	default:
		return false
	}
}

func requiredUint(raw, name string) (uint64, error) {
	value, err := strconv.ParseUint(strings.TrimSpace(raw), 10, 64)
	if err != nil || value == 0 {
		return 0, fmt.Errorf("%s is invalid", name)
	}
	return value, nil
}

func formIdentity(args url.Values, prefix string) (uint64, uint64, error) {
	id, err := requiredUint(args.Get(prefix+"_id"), prefix+" id")
	if err != nil {
		return 0, 0, err
	}
	version, err := requiredUint(args.Get(prefix+"_version"), prefix+" version")
	return id, version, err
}

func hasPermission(grants []string, required string) bool {
	for _, grant := range grants {
		if grant == "*" || grant == required || strings.HasSuffix(grant, "*") && strings.HasPrefix(required, strings.TrimSuffix(grant, "*")) {
			return true
		}
	}
	return false
}

func setPaymentAudit(args url.Values, event string, id uint64, prior, next string) {
	hash := sha256.Sum256([]byte("hosted-payment:" + strconv.FormatUint(id, 10)))
	args.Set("_gaudit_event", event)
	args.Set("_gaudit_reason", args.Get("reason"))
	args.Set("_gaudit_prior_state", prior)
	args.Set("_gaudit_new_state", next)
	args.Set("_gaudit_object_hash", hex.EncodeToString(hash[:]))
}
