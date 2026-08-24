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

func TestAdvertiserPaymentScopeComesFromAuthenticatedIdentity(t *testing.T) {
	filter := &Filter{}
	filter.C = &genelet.Config{Roles: map[string]genelet.Role{
		"adv": {Id_name: "adv_id", Permissions: []string{payment.PermissionRead, payment.PermissionCheckoutPropose}},
	}}
	filter.Action = "topics"
	filter.R = httptest.NewRequest("GET", "/goto/adv/g/hostedpayment", nil)
	filter.R.Form = url.Values{genelet.PrincipalSourceField: {genelet.PrincipalSession}, "_grole": {"adv"}, "adv_id": {"7"}, "party_type": {"publisher"}, "party_id": {"999"}}
	actor, scope, err := paymentActor(filter)
	if err != nil {
		t.Fatal(err)
	}
	want := payment.Scope{PartyType: payment.PartyAdvertiser, PartyID: 7}
	if actor.Scope != want || scope != want || actor.RecentMFA {
		t.Fatalf("actor=%#v scope=%#v", actor, scope)
	}
	if !actor.Permissions[payment.PermissionCheckoutPropose] {
		t.Fatal("advertiser checkout permission was not propagated")
	}
}

func TestFinancialMutationActorRequiresRecentMFA(t *testing.T) {
	filter := &Filter{}
	filter.C = &genelet.Config{Roles: map[string]genelet.Role{
		"admin": {Id_name: "admin_id", Permissions: []string{"*"}},
	}}
	filter.Action = "approveOperation"
	filter.R = httptest.NewRequest("POST", "/goto/admin/g/hostedpayment", nil)
	filter.R.Form = url.Values{genelet.PrincipalSourceField: {genelet.PrincipalSession}, genelet.RecentMFAField: {"1"}, "_grole": {"admin"}, "admin_id": {"2"}}
	actor, _, err := paymentActor(filter)
	if err != nil {
		t.Fatal(err)
	}
	if !actor.RecentMFA || !actor.Permissions["*"] {
		t.Fatalf("admin mutation actor=%#v", actor)
	}
}

func TestUnknownPaymentActionCannotAssumeRecentMFA(t *testing.T) {
	filter := &Filter{}
	filter.C = &genelet.Config{Roles: map[string]genelet.Role{
		"admin": {Id_name: "admin_id", Permissions: []string{"*"}},
	}}
	filter.Action = "futureMutation"
	filter.R = httptest.NewRequest("POST", "/goto/admin/g/hostedpayment", nil)
	filter.R.Form = url.Values{genelet.PrincipalSourceField: {genelet.PrincipalSession}, "_grole": {"admin"}, "admin_id": {"2"}}
	actor, _, err := paymentActor(filter)
	if err != nil {
		t.Fatal(err)
	}
	if actor.RecentMFA {
		t.Fatal("unknown payment action was allowed to infer recent MFA")
	}
}
