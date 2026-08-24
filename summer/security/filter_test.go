package security

import (
	"net/http/httptest"
	"net/url"
	"testing"

	"github.com/guruperl/genelet"
)

func TestAccountRejectsCallerIdentityStrings(t *testing.T) {
	filter := &Filter{}
	filter.C = &genelet.Config{Roles: map[string]genelet.Role{
		"admin": {Id_name: "admin_id", Permissions: []string{"*"}},
	}}
	filter.R = httptest.NewRequest("GET", "/goto/admin/g/security?action=dashboard", nil)
	filter.R.Form = url.Values{
		"_grole": {"admin"}, "admin_id": {"2"}, "_gpermission": {"account.security.read"},
	}
	filter.Identity = &genelet.IdentityService{}
	filter.RoleValue = "admin"
	filter.Component = "security"
	filter.Action = "dashboard"
	filter.R.Header.Set("X-Forwarded-User", "2")
	if account, err := filter.account(); err == nil {
		t.Fatalf("caller strings created identity account %#v", account)
	}
}
