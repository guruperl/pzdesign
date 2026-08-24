package site

import (
	"net/http"
	"net/http/httptest"
	"net/url"
	"strings"
	"sync/atomic"
	"testing"

	"github.com/guruperl/genelet"
)

func TestComponentCarriesSupplyTaxonomy(t *testing.T) {
	component := genelet.NewComponent("component.json")
	for _, field := range []string{"inventory_environment", "canonical_identity", "store_url", "integration_mode"} {
		if !siteContains(component.InsertPars, field) || !siteContains(component.UpdatePars, field) || !siteContains(component.EditPars, field) {
			t.Fatalf("site component is missing %s", field)
		}
	}
}

func TestPresetTreatsPrivateHostReviewURLAsUnfetchedMetadata(t *testing.T) {
	var requests atomic.Int32
	server := httptest.NewServer(http.HandlerFunc(func(http.ResponseWriter, *http.Request) {
		requests.Add(1)
	}))
	defer server.Close()

	request := httptest.NewRequest("POST", "/site", nil)
	request.Form = url.Values{
		"site_type": {"Web"}, "foreign_id": {"example.com"},
		"inventory_environment": {"Web"}, "integration_mode": {"BrowserTag"},
		"canonical_identity": {"example.com"}, "store_url": {server.URL + "/review"},
	}
	filter := &Filter{}
	filter.Action, filter.Component, filter.R = "insert", "site", request
	if err := filter.Preset(); err != nil {
		t.Fatal(err)
	}
	if requests.Load() != 0 {
		t.Fatalf("management review URL was fetched %d times", requests.Load())
	}
}

func TestPresetValidatesCanonicalSupplyMetadata(t *testing.T) {
	valid := url.Values{
		"site_type": {"Web"}, "foreign_id": {"example.com"},
		"inventory_environment": {"Web"}, "integration_mode": {"BrowserTag"},
		"canonical_identity": {"example.com"}, "store_url": {"https://example.com/review"},
	}
	request := httptest.NewRequest("POST", "/site", nil)
	request.Form = valid
	filter := &Filter{}
	filter.Action, filter.Component, filter.R = "insert", "site", request
	if err := filter.Preset(); err != nil {
		t.Fatal(err)
	}

	for name, mutate := range map[string]func(url.Values){
		"hostile URL":          func(values url.Values) { values.Set("store_url", "javascript:alert(1)") },
		"environment mismatch": func(values url.Values) { values.Set("site_type", "App") },
		"URL as domain":        func(values url.Values) { values.Set("canonical_identity", "https://example.com") },
	} {
		t.Run(name, func(t *testing.T) {
			values := make(url.Values, len(valid))
			for key, source := range valid {
				values[key] = append([]string(nil), source...)
			}
			mutate(values)
			req := httptest.NewRequest("POST", "/site", nil)
			req.Form = values
			candidate := &Filter{}
			candidate.Action, candidate.Component, candidate.R = "insert", "site", req
			if err := candidate.Preset(); err == nil || !strings.Contains(err.Error(), "supply") && !strings.Contains(err.Error(), "requires") {
				t.Fatalf("Preset error = %v", err)
			}
		})
	}
}

func siteContains(values []string, want string) bool {
	for _, value := range values {
		if value == want {
			return true
		}
	}
	return false
}
