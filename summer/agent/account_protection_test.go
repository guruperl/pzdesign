package agent

import (
	"bytes"
	"database/sql"
	"encoding/base64"
	"net/http/httptest"
	"net/url"
	"testing"

	"github.com/guruperl/genelet"
	"github.com/guruperl/pzdesign/summer"
	_ "github.com/mattn/go-sqlite3"
)

func TestProtectedAgentUpdateWritesOneTupleAndScrubsResponse(t *testing.T) {
	db, err := sql.Open("sqlite3", ":memory:")
	if err != nil {
		t.Fatal(err)
	}
	defer db.Close()
	if _, err := db.Exec(`CREATE TABLE agent (agent_id INTEGER PRIMARY KEY, login TEXT NOT NULL, login_hmac BLOB NOT NULL, login_cipher TEXT NOT NULL)`); err != nil {
		t.Fatal(err)
	}
	t.Setenv("AGENT_UPDATE_TEST_KEY", base64.StdEncoding.EncodeToString(bytes.Repeat([]byte{41}, 32)))
	config := &genelet.Config{
		AccountProtection: genelet.AccountProtectionConfig{Enabled: true, Current: genelet.AccountProtectionKeyConfig{ID: "test-v1", KeyEnv: "AGENT_UPDATE_TEST_KEY"}},
		Roles: map[string]genelet.Role{"agent": {Issuers: map[string]genelet.Issuer{"db": {
			PasswordHash: "passwd", ProtectedSQL: "SELECT", IdentifierNamespace: "agent.login",
			IdentifierNormalization: "login", IdentifierCipherAttribute: "agent_login",
		}}}},
	}
	protector, err := genelet.NewAccountProtector(config)
	if err != nil {
		t.Fatal(err)
	}
	oldDigest, oldCipher, err := protector.ProtectIdentifier("agent.login", "login", "oldagent")
	if err != nil {
		t.Fatal(err)
	}
	if _, err := db.Exec(`INSERT INTO agent (agent_id,login,login_hmac,login_cipher) VALUES (9,'oldagent',?,?)`, oldDigest, oldCipher); err != nil {
		t.Fatal(err)
	}
	lists := make([]map[string]interface{}, 0)
	other := make(map[string]interface{})
	args := url.Values{"agent_id": {"9"}, "login": {" NewAgent "}}
	model := &Model{}
	model.DB = db
	model.CurrentTable = "agent"
	model.CurrentKey = "agent_id"
	model.UpdatePars = []string{"agent_id", "login", "login_hmac", "login_cipher"}
	model.ARGS, model.LISTS, model.OTHER = args, &lists, &other
	model.Storage = map[string]interface{}{summer.AccountProtectionStorageKey: protector}
	if err := model.Update(); err != nil {
		t.Fatal(err)
	}
	var login, cipher string
	var digest []byte
	if err := db.QueryRow(`SELECT login,login_hmac,login_cipher FROM agent WHERE agent_id=9`).Scan(&login, &digest, &cipher); err != nil {
		t.Fatal(err)
	}
	plain, err := protector.DecryptIdentifier("agent.login", cipher)
	if err != nil || login != "newagent" || plain != login || len(digest) != 32 {
		t.Fatalf("protected tuple login=%q plain=%q digest=%d err=%v", login, plain, len(digest), err)
	}
	if model.ARGS.Get("login_hmac") != "" || model.ARGS.Get("login_cipher") != "" {
		t.Fatal("storage-only agent fields remained in request arguments")
	}
	if _, ok := (*model.LISTS)[0]["login_hmac"]; ok {
		t.Fatal("agent digest leaked into the response row")
	}
	if _, ok := (*model.LISTS)[0]["login_cipher"]; ok {
		t.Fatal("agent ciphertext leaked into the response row")
	}
}

func TestProtectedAgentEditDoesNotReadPlaintextLogin(t *testing.T) {
	db, err := sql.Open("sqlite3", ":memory:")
	if err != nil {
		t.Fatal(err)
	}
	defer db.Close()
	if _, err := db.Exec(`CREATE TABLE agent (agent_id INTEGER PRIMARY KEY, login_hmac BLOB NOT NULL, login_cipher TEXT NOT NULL)`); err != nil {
		t.Fatal(err)
	}
	t.Setenv("AGENT_EDIT_TEST_KEY", base64.StdEncoding.EncodeToString(bytes.Repeat([]byte{42}, 32)))
	config := &genelet.Config{
		AccountProtection: genelet.AccountProtectionConfig{Enabled: true, PlaintextRetired: true, Current: genelet.AccountProtectionKeyConfig{ID: "test-v1", KeyEnv: "AGENT_EDIT_TEST_KEY"}},
		Roles: map[string]genelet.Role{"agent": {Issuers: map[string]genelet.Issuer{"db": {
			PasswordHash: "passwd", ProtectedSQL: "SELECT", IdentifierNamespace: "agent.login",
			IdentifierNormalization: "login", IdentifierCipherAttribute: "agent_login",
		}}}},
	}
	protector, err := genelet.NewAccountProtector(config)
	if err != nil {
		t.Fatal(err)
	}
	digest, encrypted, err := protector.ProtectIdentifier("agent.login", "login", "owner")
	if err != nil {
		t.Fatal(err)
	}
	if _, err := db.Exec(`INSERT INTO agent (agent_id,login_hmac,login_cipher) VALUES (9,?,?)`, digest, encrypted); err != nil {
		t.Fatal(err)
	}
	args := url.Values{"agent_id": {"9"}}
	lists := make([]map[string]interface{}, 0)
	other := make(map[string]interface{})
	model := &Model{}
	model.DB, model.CurrentTable, model.CurrentKey = db, "agent", "agent_id"
	model.EditPars = []string{"agent_id", "login"}
	model.ARGS, model.LISTS, model.OTHER = args, &lists, &other
	model.Storage = map[string]interface{}{summer.AccountProtectionStorageKey: protector}
	if err := model.Edit(); err != nil {
		t.Fatal(err)
	}
	if len(lists) != 1 || lists[0]["login"] != "owner" {
		t.Fatalf("protected agent edit = %#v", lists)
	}
	if _, exists := lists[0]["login_cipher"]; exists {
		t.Fatal("agent ciphertext leaked into edit response")
	}
}

func TestAgentFilterHashesUpdatedPasswords(t *testing.T) {
	request := httptest.NewRequest("POST", "/goto/admin/e/agent?action=update&agent_id=9&passwd=a+new+secure+agent+passphrase", nil)
	if err := request.ParseForm(); err != nil {
		t.Fatal(err)
	}
	filter := &Filter{}
	filter.R = request
	filter.Action = "update"
	filter.RoleValue = "admin"
	if err := filter.Preset(); err != nil {
		t.Fatal(err)
	}
	if err := genelet.CheckPasswordHash("a new secure agent passphrase", request.Form.Get("passwd")); err != nil {
		t.Fatal("agent update did not replace the password with bcrypt")
	}
}
