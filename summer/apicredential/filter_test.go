package apicredential

import (
	"errors"
	"net/http/httptest"
	"net/url"
	"testing"

	"github.com/guruperl/aofei/managementapi"
	"github.com/guruperl/genelet"
)

func TestDisabledManagementAPIProducesControlledMaintenanceError(t *testing.T) {
	filter := &Filter{}
	filter.R = httptest.NewRequest("GET", "/goto/adv/g/apicredential?action=topics", nil)
	model := &Model{}
	err := filter.Before(model, nil, nil)
	var gerr genelet.Gerror
	if !errors.As(err, &gerr) || gerr.Code != 503 {
		t.Fatalf("disabled management API error=%#v", err)
	}
}

func TestManagementAPIFilterRejectsCallerIdentityStrings(t *testing.T) {
	filter := &Filter{}
	filter.C = &genelet.Config{Roles: map[string]genelet.Role{
		"adv": {Id_name: "adv_id", Permissions: []string{managementapi.ScopeCampaignRead}},
	}}
	filter.R = httptest.NewRequest("GET", "/goto/adv/g/apicredential?action=topics", nil)
	filter.R.Form = url.Values{
		"_grole": {"adv"}, "adv_id": {"7"}, "_gpermission": {"api.credential.read"},
	}
	filter.Identity = &genelet.IdentityService{}
	filter.RoleValue = "adv"
	filter.Component = "apicredential"
	filter.Action = "topics"
	filter.R.Header.Set("X-Forwarded-User", "7")
	model := &Model{}
	model.Storage = map[string]interface{}{"ManagementAPI": &managementapi.Service{}}
	if err := filter.Before(model, nil, nil); err == nil {
		t.Fatal("caller strings created a management API actor")
	}
}
