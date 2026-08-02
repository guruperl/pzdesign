package adv

import (
	"net/http/httptest"
	"net/url"
	"testing"

	"github.com/guruperl/genelet"
)

func TestIdentityPasswordChangeValidatesButDoesNotPrehash(t *testing.T) {
	request := httptest.NewRequest("POST", "/adv", nil)
	request.Form = url.Values{
		"passwd":  {"a secure advertiser passphrase"},
		"confirm": {"a secure advertiser passphrase"},
	}
	filter := &Filter{}
	filter.Action, filter.Component, filter.RoleValue, filter.R = "updatepass", "adv", "adv", request
	filter.Identity = &genelet.IdentityService{}

	if err := filter.Preset(); err != nil {
		t.Fatal(err)
	}
	if got := request.Form.Get("passwd"); got != "a secure advertiser passphrase" {
		t.Fatalf("identity password change pre-hashed the password: %q", got)
	}
	if request.Form.Has("confirm") {
		t.Fatal("confirmed password remained in the model arguments")
	}
}

func TestAdvertiserPasswordChangeRejectsShortPassword(t *testing.T) {
	request := httptest.NewRequest("POST", "/adv", nil)
	request.Form = url.Values{"passwd": {"too-short"}, "confirm": {"too-short"}}
	filter := &Filter{}
	filter.Action, filter.Component, filter.RoleValue, filter.R = "updatepass", "adv", "adv", request
	filter.Identity = &genelet.IdentityService{}

	if err := filter.Preset(); err == nil {
		t.Fatal("advertiser password change accepted fewer than 12 characters")
	}
}
