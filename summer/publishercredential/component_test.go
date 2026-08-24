package publishercredential

import (
	"encoding/json"
	"os"
	"testing"
)

func TestCredentialMutationsRequireNamedPermissionScopeAndMFA(t *testing.T) {
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
	for _, action := range []string{"issue", "rotate", "revoke"} {
		rule := component.Actions[action]
		if len(rule["permission"]) != 1 || rule["permission"][0] != "publisher.credential."+action {
			t.Errorf("%s permission=%v", action, rule["permission"])
		}
		if len(rule["resource"]) != 2 || rule["resource"][0] != "pub" || rule["resource"][1] != "$f:pub_id" {
			t.Errorf("%s resource=%v", action, rule["resource"])
		}
		if len(rule["reauth"]) != 1 || rule["reauth"][0] != "mfa" {
			t.Errorf("%s reauth=%v", action, rule["reauth"])
		}
	}
}
