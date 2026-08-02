package hostedpayment

import (
	"encoding/json"
	"os"
	"testing"
)

func TestEveryFinancialMutationRequiresMFAAtTheRouteBoundary(t *testing.T) {
	data, err := os.ReadFile("component.json")
	if err != nil {
		t.Fatal(err)
	}
	var component struct {
		Actions map[string]map[string][]string `json:"actions"`
	}
	if err := json.Unmarshal(data, &component); err != nil {
		t.Fatal(err)
	}
	for action, rule := range component.Actions {
		if action == "topics" {
			if len(rule["reauth"]) != 0 || paymentActionRequiresMFA(action) {
				t.Errorf("read-only %s unexpectedly requires mutation MFA", action)
			}
			continue
		}
		if !paymentActionRequiresMFA(action) {
			t.Errorf("financial action %s is missing from the service MFA allowlist", action)
		}
		if len(rule["reauth"]) != 1 || rule["reauth"][0] != "mfa" {
			t.Errorf("financial action %s reauth=%v", action, rule["reauth"])
		}
	}
}
