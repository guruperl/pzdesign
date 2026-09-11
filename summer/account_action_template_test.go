package summer

import (
	"bytes"
	"net/url"
	"path/filepath"
	"strings"
	"testing"
	"text/template"

	"github.com/guruperl/genelet"
)

func renderAccountMail(t *testing.T, path string, page genelet.Tmpl) string {
	t.Helper()
	parsed, err := template.ParseFiles(path)
	if err != nil {
		t.Fatalf("parse %s: %v", path, err)
	}
	var rendered bytes.Buffer
	if err := parsed.Execute(&rendered, page); err != nil {
		t.Fatalf("render %s: %v", path, err)
	}
	return rendered.String()
}

func accountMailURL(t *testing.T, rendered string) *url.URL {
	t.Helper()
	for _, field := range strings.Fields(rendered) {
		if !strings.HasPrefix(field, "https://") {
			continue
		}
		parsed, err := url.Parse(field)
		if err != nil {
			t.Fatalf("parse rendered account mail URL: %v", err)
		}
		if _, err := url.ParseQuery(parsed.RawQuery); err != nil {
			t.Fatalf("rendered account mail query is invalid: %v", err)
		}
		return parsed
	}
	t.Fatal("rendered account mail omitted its URL")
	return nil
}

func TestProtectedAccountMailLinksContainOnlyOpaqueProof(t *testing.T) {
	root := filepath.Join("..", "tmpls", "web")
	for _, role := range []string{"adv", "pub"} {
		idField := role + "_id"
		for _, action := range []string{"insert", "retrieve"} {
			for _, language := range []string{"e", "g"} {
				name := role + "/" + action + ".mail." + language
				args := url.Values{
					"serverUrl": {"https://www.w8m.com"}, idField: {"7"},
					"email": {"owner+demo@example.test"}, "firstname": {"First Name"}, "lastname": {"Last Name"},
				}
				lists := []map[string]interface{}{{idField: int64(7), "firstname": "First Name", "lastname": "Last Name"}}
				rendered := renderAccountMail(t, filepath.Join(root, name), genelet.Tmpl{
					ARGS: args, Lists: lists, Extra: map[string]interface{}{"action_token": "opaque proof"}, Success: true,
				})
				query := accountMailURL(t, rendered).Query()
				if query.Get("action_token") != "opaque proof" {
					t.Errorf("%s omitted the opaque action proof", name)
				}
				for _, leaked := range []string{"email=", "stamp=", "owner%2Bdemo%40example.test", "owner+demo@example.test", "&#"} {
					if strings.Contains(rendered, leaked) {
						t.Errorf("%s protected link exposed %q", name, leaked)
					}
				}
			}
		}
	}
}

func TestLegacyAccountMailLinksRemainAvailableWhileProtectionIsOff(t *testing.T) {
	root := filepath.Join("..", "tmpls", "web")
	for _, role := range []string{"adv", "pub"} {
		idField := role + "_id"
		for _, action := range []string{"insert", "retrieve"} {
			for _, language := range []string{"e", "g"} {
				name := role + "/" + action + ".mail." + language
				args := url.Values{
					"serverUrl": {"https://www.w8m.com"}, idField: {"7"}, "email": {"owner+demo@example.test"},
					"firstname": {"First Name"}, "lastname": {"Last Name"}, "stamp": {"123"}, "md5": {"legacy-proof"},
				}
				lists := []map[string]interface{}{{idField: int64(7), "firstname": "First Name", "lastname": "Last Name"}}
				rendered := renderAccountMail(t, filepath.Join(root, name), genelet.Tmpl{ARGS: args, Lists: lists, Success: true})
				query := accountMailURL(t, rendered).Query()
				if query.Get("email") != "owner+demo@example.test" || query.Get("firstname") != "First Name" || query.Get("lastname") != "Last Name" || query.Get("stamp") != "123" || query.Get("md5") != "legacy-proof" {
					t.Fatalf("%s legacy rollback query = %v", name, query)
				}
				if query.Get("action_token") != "" || strings.Contains(rendered, "&#") {
					t.Fatalf("%s legacy rollback link used the wrong encoding", name)
				}
			}
		}
	}
}
