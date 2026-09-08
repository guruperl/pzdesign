package summer

import (
	"html/template"
	"net/url"
	"path/filepath"
	"strings"
	"testing"

	"github.com/guruperl/genelet"
)

func TestProtectedAccountMailLinksContainOnlyOpaqueProof(t *testing.T) {
	root := filepath.Join("..", "tmpls", "web")
	for _, role := range []string{"adv", "pub"} {
		idField := role + "_id"
		for _, action := range []string{"insert", "retrieve"} {
			for _, language := range []string{"e", "g"} {
				name := role + "/" + action + ".mail." + language
				parsed, err := template.ParseFiles(filepath.Join(root, name))
				if err != nil {
					t.Fatalf("parse %s: %v", name, err)
				}
				args := url.Values{
					"serverUrl": {"https://www.w8m.com"}, idField: {"7"},
					"email": {"owner@example.test"}, "firstname": {"First"}, "lastname": {"Last"},
				}
				lists := []map[string]interface{}{{idField: int64(7), "firstname": "First", "lastname": "Last"}}
				rendered, err := (&genelet.Tmpl{ARGS: args, Lists: lists, Extra: map[string]interface{}{"action_token": "opaque-token"}, Success: true}).Get_page(parsed)
				if err != nil {
					t.Fatalf("render %s: %v", name, err)
				}
				if !strings.Contains(rendered, "action_token=opaque-token") {
					t.Errorf("%s omitted the opaque action proof", name)
				}
				for _, leaked := range []string{"email=", "stamp=", "owner%40example.test", "owner@example.test"} {
					if strings.Contains(rendered, leaked) {
						t.Errorf("%s protected link exposed %q", name, leaked)
					}
				}
			}
		}
	}
}

func TestLegacyAccountMailLinksRemainAvailableWhileProtectionIsOff(t *testing.T) {
	path := filepath.Join("..", "tmpls", "web", "adv", "insert.mail.e")
	parsed, err := template.ParseFiles(path)
	if err != nil {
		t.Fatal(err)
	}
	args := url.Values{
		"serverUrl": {"https://www.w8m.com"}, "adv_id": {"7"}, "email": {"owner@example.test"},
		"firstname": {"First"}, "lastname": {"Last"}, "stamp": {"123"}, "md5": {"legacy-proof"},
	}
	rendered, err := (&genelet.Tmpl{ARGS: args, Success: true}).Get_page(parsed)
	if err != nil {
		t.Fatal(err)
	}
	if !strings.Contains(rendered, "email=owner%40example.test") || !strings.Contains(rendered, "stamp=123") || strings.Contains(rendered, "action_token=") {
		t.Fatalf("legacy rollback link = %q", rendered)
	}
}
