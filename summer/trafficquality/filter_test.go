package trafficquality

import (
	"errors"
	"net/http/httptest"
	"net/url"
	"testing"

	quality "github.com/guruperl/aofei/trafficquality"
	"github.com/guruperl/genelet"
)

func TestDisabledTrafficQualityProducesControlledMaintenanceError(t *testing.T) {
	filter := &Filter{}
	filter.R = httptest.NewRequest("GET", "/goto/pub/g/trafficquality?action=topicsPub", nil)
	model := &Model{}
	err := filter.Before(model, nil, nil)
	var gerr genelet.Gerror
	if !errors.As(err, &gerr) || gerr.Code != 503 {
		t.Fatalf("disabled traffic-quality error=%#v", err)
	}
}

func TestPublisherScopeComesFromAuthenticatedIdentity(t *testing.T) {
	filter := &Filter{}
	filter.C = &genelet.Config{Roles: map[string]genelet.Role{
		"pub": {Id_name: "pub_id", Permissions: []string{quality.PermissionEvidenceRead, quality.PermissionAppealSubmit}},
	}}
	filter.Action = "topicsPub"
	filter.R = httptest.NewRequest("GET", "/goto/pub/g/trafficquality", nil)
	filter.R.Form = url.Values{genelet.PrincipalSourceField: {genelet.PrincipalSession}, "_grole": {"pub"}, "pub_id": {"7"}, "scope_id": {"999"}, "scope_type": {"Advertiser"}}
	actor, scope, err := qualityActor(filter)
	if err != nil {
		t.Fatal(err)
	}
	if actor.Scope != (quality.Scope{Type: quality.ScopePublisher, ID: 7}) || scope != actor.Scope {
		t.Fatalf("actor=%#v scope=%#v", actor, scope)
	}
	if !actor.Can(quality.PermissionAppealSubmit) || actor.RecentMFA {
		t.Fatalf("publisher permission/MFA boundary=%#v", actor)
	}
}

func TestSensitiveActionCannotSynthesizeRecentMFA(t *testing.T) {
	filter := &Filter{}
	filter.C = &genelet.Config{Roles: map[string]genelet.Role{"admin": {Id_name: "admin_id", Permissions: []string{"*"}}}}
	filter.Action = "setMode"
	filter.R = httptest.NewRequest("POST", "/goto/admin/g/trafficquality", nil)
	filter.R.Form = url.Values{genelet.PrincipalSourceField: {genelet.PrincipalSession}, "_grole": {"admin"}, "admin_id": {"2"}}
	actor, _, err := qualityActor(filter)
	if err != nil {
		t.Fatal(err)
	}
	if actor.RecentMFA {
		t.Fatal("sensitive action name synthesized recent MFA")
	}
	filter.R.Form.Set(genelet.RecentMFAField, "1")
	actor, _, err = qualityActor(filter)
	if err != nil || !actor.RecentMFA {
		t.Fatalf("verified recent MFA actor=%#v err=%v", actor, err)
	}
}

func TestRuleFormRejectsInvalidRetentionAndScope(t *testing.T) {
	form := url.Values{
		"rule_key": {"replay.window"}, "signal": {"Replay"}, "rule_action": {"Flag"},
		"scope_type": {"Global"}, "scope_id": {"1"}, "threshold": {"2"},
		"window_seconds": {"60"}, "reason_code": {"replay.threshold"},
		"evidence_hours": {"0"}, "aggregate_days": {"400"}, "false_positive_bps": {"100"},
	}
	if _, err := qualityRuleFromForm(form); err == nil {
		t.Fatal("zero evidence retention accepted")
	}
	form.Set("evidence_hours", "24")
	rule, err := qualityRuleFromForm(form)
	if err != nil {
		t.Fatal(err)
	}
	if err := rule.Validate(); err == nil {
		t.Fatal("global rule with non-zero scope id accepted")
	}
}
