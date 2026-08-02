package registry

import (
	"encoding/json"
	"os"
	"path/filepath"
	"strings"
	"testing"

	"github.com/guruperl/genelet"
)

type actionPermissionFixture struct {
	Actions map[string]map[string][]string `json:"actions"`
}

func TestRegistryCoversComponentModules(t *testing.T) {
	registered := make(map[string]bool, len(Entries))
	for _, entry := range Entries {
		if entry.Name == "" || entry.NewModel == nil || entry.NewStorage == nil || entry.NewFilter == nil {
			t.Fatalf("invalid registry entry: %#v", entry)
		}
		if registered[entry.Name] {
			t.Fatalf("duplicate registry entry %q", entry.Name)
		}
		registered[entry.Name] = true
	}

	files, err := filepath.Glob("../*/component.json")
	if err != nil {
		t.Fatal(err)
	}
	for _, file := range files {
		module := filepath.Base(filepath.Dir(file))
		if !registered[module] {
			t.Fatalf("component module %q is missing from registry", module)
		}
	}
	for module := range registered {
		component := filepath.Join("..", module, "component.json")
		if _, err := os.Stat(component); err != nil {
			if strings.Contains(err.Error(), "no such file") {
				t.Fatalf("registry module %q has no component.json", module)
			}
			t.Fatal(err)
		}
		if _, err := genelet.LoadComponent(component); err != nil {
			t.Fatalf("registry module %q component did not validate: %v", module, err)
		}
	}
}

func TestRegistryDoesNotExposeRetiredCredentialOrFundingModules(t *testing.T) {
	retired := map[string]bool{"cc": true, "cheque": true, "payment": true, "alipay": true, "wechat": true}
	for _, entry := range Entries {
		if retired[entry.Name] {
			t.Errorf("retired financial module %q remains routable", entry.Name)
		}
	}
	advComponent, err := os.ReadFile("../adv/component.json")
	if err != nil {
		t.Fatal(err)
	}
	for _, retired := range []string{`"balance" :`, `"p.balance"`} {
		if strings.Contains(string(advComponent), retired) {
			t.Errorf("retired advertiser funding/account-balance surface %q remains", retired)
		}
	}
}

func TestExampleIdentityPermissionsCoverEveryRoutableRoleAction(t *testing.T) {
	config, err := genelet.NewConfig(filepath.Join("..", "..", "..", "aofei", "etc", "summer.example.json"))
	if err != nil {
		t.Fatal(err)
	}
	for _, entry := range Entries {
		content, err := os.ReadFile(filepath.Join("..", entry.Name, "component.json"))
		if err != nil {
			t.Fatal(err)
		}
		var component actionPermissionFixture
		if err := json.Unmarshal(content, &component); err != nil {
			t.Fatal(err)
		}
		for action, rule := range component.Actions {
			for _, roleName := range rule["groups"] {
				if roleName == config.Pubrole {
					continue
				}
				role, ok := config.Roles[roleName]
				if !ok {
					t.Errorf("%s.%s names undefined role %q", entry.Name, action, roleName)
					continue
				}
				permission := entry.Name + "." + action
				if explicit := rule["permission_"+roleName]; len(explicit) == 1 && explicit[0] != "" {
					permission = explicit[0]
				} else if explicit := rule["permission"]; len(explicit) == 1 && explicit[0] != "" {
					permission = explicit[0]
				}
				if !fixtureRoleHasPermission(role.Permissions, permission) {
					t.Errorf("example role %s cannot satisfy %s.%s permission %q", roleName, entry.Name, action, permission)
				}
			}
		}
	}
}

func fixtureRoleHasPermission(grants []string, required string) bool {
	for _, grant := range grants {
		if grant == "*" || grant == required || strings.HasSuffix(grant, "*") && strings.HasPrefix(required, strings.TrimSuffix(grant, "*")) {
			return true
		}
	}
	return false
}

func TestExampleAnalystRoleIsReadOnlyAndDelegated(t *testing.T) {
	config, err := genelet.NewConfig(filepath.Join("..", "..", "..", "aofei", "etc", "summer.example.json"))
	if err != nil {
		t.Fatal(err)
	}
	analyst := config.Roles["analyst"]
	if !analyst.RequireGrant {
		t.Fatal("analyst role does not require an exact database grant")
	}
	for _, forbidden := range []string{
		"*", "report.marketplace.export", "report.advertiser.export", "report.publisher.export",
		"route.group.edit", "bidder.profile.approve", "seller.authorize", "account.password.change",
	} {
		if fixtureRoleHasPermission(analyst.Permissions, forbidden) {
			t.Errorf("analyst role unexpectedly permits %q", forbidden)
		}
	}
}
