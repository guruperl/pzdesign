package pub

import (
	"net/http/httptest"
	"net/url"
	"strconv"
	"strings"
	"testing"
	"time"

	"github.com/guruperl/genelet"
	"github.com/guruperl/pzdesign/summer"
)

func TestFilter(t *testing.T) {
	filter := new(Filter)
	comp := genelet.NewComponent("../address/component.json")
	filter.Initialize(comp)
	filter.Action = "insert"
	filter.Component = "address"

	filter.Base.C = testSummerConfig(t)
	jar := summer.GetJar()
	filter.Base.R = summer.GetNewRequest("http://www.u2link.com", jar)
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

func TestPublisherSellerEditAlwaysRequiresOperatorReapproval(t *testing.T) {
	request := httptest.NewRequest("POST", "/pub", nil)
	request.Form = url.Values{
		"seller_id": {"seller-7"}, "seller_type": {"Publisher"}, "seller_asi": {"w8m.com"},
		"seller_name": {"Example Media"}, "seller_domain": {"example.com"}, "seller_authorized": {"Yes"},
	}
	filter := &Filter{}
	filter.Action, filter.Component, filter.RoleValue, filter.R = "update", "pub", "pub", request
	if err := filter.Preset(); err != nil {
		t.Fatal(err)
	}
	if got := request.Form.Get("seller_authorized"); got != "No" {
		t.Fatalf("publisher kept seller authorization %q", got)
	}
	request.Form.Set("seller_id", `<script>`)
	if err := filter.Preset(); err == nil || !strings.Contains(err.Error(), "seller") {
		t.Fatalf("hostile seller error = %v", err)
	}
}

func TestPublisherProtectionIgnoresClientSuppliedAdminMarker(t *testing.T) {
	request := httptest.NewRequest("POST", "/pub", nil)
	request.Form = url.Values{
		"_gadmin":   {"1"},
		"passwd":    {"local-demo-password"},
		"confirm":   {"local-demo-password"},
		"firstname": {"Local"},
		"lastname":  {"Publisher"},
	}
	filter := &Filter{}
	filter.Action, filter.Component, filter.RoleValue, filter.R = "insert", "pub", "web", request
	if err := filter.Preset(); err != nil {
		t.Fatal(err)
	}
	if got := request.Form.Get("firstname"); got == "1" {
		t.Fatalf("public publisher submission was treated as admin: firstname overwritten with dummy %q", got)
	}
	if got := request.Form.Get("passwd"); got == "" || got == "local-demo-password" || got == "1" {
		t.Fatalf("public publisher submission passwd = %q, want a hashed value", got)
	}
}
