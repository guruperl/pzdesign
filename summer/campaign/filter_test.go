package campaign

import (
	"net/http/httptest"
	"net/url"
	"strings"
	"testing"
)

func TestPresetKeepsExternalBusinessIDSeparateFromQualityURL(t *testing.T) {
	request := httptest.NewRequest("POST", "/campaign", nil)
	request.Form = url.Values{
		"foreign_id": {" external-order-42 "},
		"iurl":       {"https://cdn.example/quality.png"},
	}
	filter := &Filter{}
	filter.Action = "insert"
	filter.Component = "campaign"
	filter.RoleValue = "adv"
	filter.R = request
	if err := filter.Preset(); err != nil {
		t.Fatal(err)
	}
	if got := request.Form.Get("foreign_id"); got != "external-order-42" {
		t.Fatalf("foreign_id = %q", got)
	}
}

func TestPresetRejectsUnsafeCampaignQualityURL(t *testing.T) {
	request := httptest.NewRequest("POST", "/campaign", nil)
	request.Form = url.Values{"iurl": {"javascript:alert(1)"}}
	filter := &Filter{}
	filter.Action = "insert"
	filter.Component = "campaign"
	filter.RoleValue = "adv"
	filter.R = request
	if err := filter.Preset(); err == nil || !strings.Contains(err.Error(), "absolute HTTP(S)") {
		t.Fatalf("quality URL error = %v", err)
	}
}
