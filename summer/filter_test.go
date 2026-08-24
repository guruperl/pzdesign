package summer

import (
	"net/http/httptest"
	"net/url"
	"strconv"
	"testing"
	"time"

	"github.com/guruperl/genelet"
)

func TestFilter(t *testing.T) {
	filter := new(Filter)
	comp := genelet.NewComponent("./address/component.json")
	filter.Initialize(comp)
	filter.Action = "insert"
	filter.Component = "address"

	filter.Base.C = testSummerConfig(t)
	jar := GetJar()
	filter.Base.R = GetNewRequest("http://www.u2link.com", jar)
	filter.Base.W = httptest.NewRecorder()
	if err := filter.Base.R.ParseForm(); err != nil {
		t.Errorf("%v\n", err)
	}
	filter.R.Form.Set("_gtime", strconv.FormatInt(time.Now().Unix(), 10))
	if err := filter.Preset(); err != nil {
		t.Errorf("%v\n", err)
	}
	if filter.R.Form.Get("ip") != "210.51.200.123" {
		t.Errorf("%v\n", filter.R.Form)
	}
}

func TestAuthorizedPrincipalRejectsCallerControlledIdentityStrings(t *testing.T) {
	filter := &Filter{}
	filter.C = &genelet.Config{Roles: map[string]genelet.Role{
		"admin": {Id_name: "admin_id", Permissions: []string{"*"}},
	}}
	filter.R = httptest.NewRequest("GET", "/goto/admin/g/trafficquality?action=dashboard", nil)
	filter.R.Form = url.Values{
		"_grole": {"admin"}, "admin_id": {"2"}, "_gpermission": {"quality.evidence.read"},
	}
	filter.Identity = &genelet.IdentityService{}
	filter.RoleValue = "admin"
	filter.Component = "trafficquality"
	filter.Action = "dashboard"
	filter.R.Header.Set("X-Forwarded-User", "2")
	filter.R.Header.Set("X-Forwarded-MFA", "1")
	if principal, _, err := filter.AuthorizedPrincipal(); err == nil {
		t.Fatalf("caller strings created verified principal %#v", principal)
	}
}

func TestAfterItemSetDoesNotMutateLargeOptions(t *testing.T) {
	filter := &Filter{}
	original := LARGES["language"][0]["selected"]

	options := filter.AfterItemSet("language", "ZH")
	if len(options) == 0 {
		t.Fatal("AfterItemSet returned no options")
	}
	options[0]["selected"] = "changed"

	if got := LARGES["language"][0]["selected"]; got != original {
		t.Fatalf("LARGES mutated: got %#v, want %#v", got, original)
	}
	if _, ok := LARGES["language"][0]["label_chinese"]; ok {
		t.Fatal("LARGES gained request-specific translated label")
	}
}
