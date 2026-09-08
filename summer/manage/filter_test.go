package manage

import (
	"net/http/httptest"
	"net/url"
	"testing"
)

func TestLoginAsIsAdministratorOnlyAndRequiresNumericTargetField(t *testing.T) {
	request := httptest.NewRequest("POST", "/goto/admin/e/manage", nil)
	request.Form = url.Values{"role": {"adv"}, "adv_id": {"7"}}
	filter := &Filter{}
	filter.Action, filter.RoleValue, filter.R = "login_as", "admin", request
	if err := filter.Preset(); err != nil {
		t.Fatal(err)
	}
	filter.RoleValue = "agent"
	if err := filter.Preset(); err == nil {
		t.Fatal("agent was permitted to create an advertiser session")
	}
	filter.RoleValue = "admin"
	request.Form.Del("adv_id")
	if err := filter.Preset(); err == nil {
		t.Fatal("login-as accepted a target without its numeric ID")
	}
	request.Form.Set("role", "unknown")
	if err := filter.Preset(); err == nil {
		t.Fatal("login-as accepted an unknown target role")
	}
	request.Form.Set("role", "adv")
	request.Form.Set("adv_id", "not-an-id")
	if err := filter.Preset(); err == nil {
		t.Fatal("login-as accepted a non-numeric target ID")
	}
}
