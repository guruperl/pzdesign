package apicredential

import (
	"errors"
	"net/http/httptest"
	"testing"

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
