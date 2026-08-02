package trafficquality

import (
	"encoding/json"
	"os"
	"testing"
)

func TestSensitiveQualityActionsRequireAdministratorMFA(t *testing.T) {
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
	for _, action := range []string{"createRule", "setMode", "resolve", "resolveAppeal", "enforce", "rollback", "recommendBilling", "approveBilling"} {
		rule := component.Actions[action]
		if len(rule["groups"]) != 1 || rule["groups"][0] != "admin" {
			t.Errorf("%s groups=%v", action, rule["groups"])
		}
		if len(rule["reauth"]) != 1 || rule["reauth"][0] != "mfa" {
			t.Errorf("%s reauth=%v", action, rule["reauth"])
		}
	}
	for _, action := range []string{"topicsAdv", "topicsPub", "topicsPartner"} {
		if len(component.Actions[action]["resource"]) != 2 {
			t.Errorf("%s has no delegated resource boundary", action)
		}
	}
	if groups := component.Actions["appeal"]["groups"]; len(groups) != 2 || groups[0] != "adv" || groups[1] != "pub" {
		t.Fatalf("appeal groups=%v", groups)
	}
}
