package hostedpayment

import (
	"errors"
	"net/http/httptest"
	"net/url"
	"testing"

	payment "github.com/guruperl/aofei/hostedpayment"
	"github.com/guruperl/genelet"
)

func TestDisabledHostedPaymentProducesControlledMaintenanceError(t *testing.T) {
	filter := &Filter{}
	filter.R = httptest.NewRequest("GET", "/goto/adv/g/hostedpayment?action=topics", nil)
	model := &Model{}
	err := filter.Before(model, nil, nil)
	var gerr genelet.Gerror
	if !errors.As(err, &gerr) || gerr.Code != 503 {
		t.Fatalf("disabled hosted-payment error=%#v", err)
	}
}

func TestAdvertiserPaymentScopeRejectsCallerIdentityStrings(t *testing.T) {
	filter := &Filter{}
	filter.C = &genelet.Config{Roles: map[string]genelet.Role{
		"adv": {Id_name: "adv_id", Permissions: []string{payment.PermissionRead, payment.PermissionCheckoutPropose}},
	}}
	filter.Action = "topics"
	filter.R = httptest.NewRequest("GET", "/goto/adv/g/hostedpayment", nil)
	filter.R.Form = url.Values{"_grole": {"adv"}, "adv_id": {"7"}, "party_type": {"publisher"}, "party_id": {"999"}}
	filter.Identity = &genelet.IdentityService{}
	filter.R.Header.Set("X-Forwarded-User", "7")
	if actor, scope, err := paymentActor(filter); err == nil {
		t.Fatalf("caller strings created payment actor=%#v scope=%#v", actor, scope)
	}
}

func TestFinancialMutationCannotInferRecentMFAFromAction(t *testing.T) {
	filter := &Filter{}
	filter.C = &genelet.Config{Roles: map[string]genelet.Role{
		"admin": {Id_name: "admin_id", Permissions: []string{"*"}},
	}}
	filter.Action = "approveOperation"
	filter.R = httptest.NewRequest("POST", "/goto/admin/g/hostedpayment", nil)
	filter.R.Form = url.Values{"_grole": {"admin"}, "admin_id": {"2"}}
	filter.Identity = &genelet.IdentityService{}
	filter.R.Header.Set("X-Forwarded-MFA", "1")
	if actor, _, err := paymentActor(filter); err == nil {
		t.Fatalf("action/header strings created recent-MFA actor=%#v", actor)
	}
}

func TestUnknownPaymentActionRequiresVerifiedPrincipal(t *testing.T) {
	filter := &Filter{}
	filter.C = &genelet.Config{Roles: map[string]genelet.Role{
		"admin": {Id_name: "admin_id", Permissions: []string{"*"}},
	}}
	filter.Action = "futureMutation"
	filter.R = httptest.NewRequest("POST", "/goto/admin/g/hostedpayment", nil)
	filter.R.Form = url.Values{"_grole": {"admin"}, "admin_id": {"2"}}
	if actor, _, err := paymentActor(filter); err == nil {
		t.Fatalf("unknown action created actor without verified principal=%#v", actor)
	}
}
