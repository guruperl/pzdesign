package ledger

import (
	"errors"
	"net/http/httptest"
	"testing"

	"github.com/guruperl/genelet"
	"github.com/guruperl/pzdesign/summer"
)

func TestMarketplaceReportingRequiresActivatedSchema(t *testing.T) {
	filter := &Filter{}
	filter.Action = "topicsMarketplace"
	filter.R = httptest.NewRequest("GET", "/goto/adv/g/ledger?action=topicsMarketplace", nil)
	model := &Model{}
	model.Storage = map[string]interface{}{summer.MarketplaceReportingStorageKey: false}
	err := filter.Before(model, nil, nil)
	var gerr genelet.Gerror
	if !errors.As(err, &gerr) || gerr.Code != 503 {
		t.Fatalf("inactive marketplace report error=%#v, want controlled 503", err)
	}

	model.Storage[summer.MarketplaceReportingStorageKey] = true
	if err := filter.Before(model, nil, nil); err != nil {
		t.Fatalf("active marketplace report was rejected: %v", err)
	}
}

func TestActionReportingRequiresActivatedSchema(t *testing.T) {
	filter := &Filter{}
	filter.Action = "topicsAdvActions"
	filter.R = httptest.NewRequest("GET", "/goto/adv/g/ledger?action=topicsAdvActions", nil)
	model := &Model{}
	model.Storage = map[string]interface{}{summer.ActionReportingStorageKey: false}
	err := filter.Before(model, nil, nil)
	var gerr genelet.Gerror
	if !errors.As(err, &gerr) || gerr.Code != 503 {
		t.Fatalf("inactive action report error=%#v, want controlled 503", err)
	}

	model.Storage[summer.ActionReportingStorageKey] = true
	if err := filter.Before(model, nil, nil); err != nil {
		t.Fatalf("active action report was rejected: %v", err)
	}
}
