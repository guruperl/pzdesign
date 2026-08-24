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

func TestPublisherScopeRejectsCallerIdentityStrings(t *testing.T) {
	filter := &Filter{}
	filter.C = &genelet.Config{Roles: map[string]genelet.Role{
		"pub": {Id_name: "pub_id", Permissions: []string{quality.PermissionEvidenceRead, quality.PermissionAppealSubmit}},
	}}
	filter.Action = "topicsPub"
	filter.R = httptest.NewRequest("GET", "/goto/pub/g/trafficquality", nil)
	filter.R.Form = url.Values{"_grole": {"pub"}, "pub_id": {"7"}, "scope_id": {"999"}, "scope_type": {"Advertiser"}}
	filter.Identity = &genelet.IdentityService{}
	filter.R.Header.Set("X-Forwarded-User", "7")
	if actor, scope, err := qualityActor(filter); err == nil {
		t.Fatalf("caller strings created quality actor=%#v scope=%#v", actor, scope)
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
