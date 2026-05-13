package ac

import (
	"net/http"
	"net/http/httptest"
	"net/url"
	"testing"

	"github.com/guruperl/pzdesign/genelet"
)

func TestPresetRejectsUnknownEntityType(t *testing.T) {
	req := httptest.NewRequest(http.MethodGet, "/", nil)
	req.Form = url.Values{"entitytype_id": {"bad"}}
	filter := &Filter{}
	filter.Base = genelet.Base{R: req}
	filter.Action = "topics"

	err := filter.Preset()
	if err == nil {
		t.Fatal("Preset returned nil, want error")
	}
	if gerr, ok := err.(genelet.Gerror); !ok || gerr.Code != 1092 {
		t.Fatalf("Preset error = %#v, want 1092 Gerror", err)
	}
}
