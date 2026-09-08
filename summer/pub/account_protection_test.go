package pub

import (
	"bytes"
	"database/sql"
	"encoding/base64"
	"net/url"
	"testing"

	"github.com/guruperl/genelet"
	"github.com/guruperl/pzdesign/summer"
	_ "github.com/mattn/go-sqlite3"
)

func publisherUpdateModel(t *testing.T, retired bool) (*Model, *sql.DB, *genelet.AccountProtector) {
	t.Helper()
	db, err := sql.Open("sqlite3", ":memory:")
	if err != nil {
		t.Fatal(err)
	}
	t.Cleanup(func() { _ = db.Close() })
	if _, err := db.Exec(`CREATE TABLE testing_pub (pub_id INTEGER PRIMARY KEY, email TEXT, email_hmac BLOB NOT NULL, email_cipher TEXT NOT NULL, activation_token_digest BLOB, activation_token_expires DATETIME, reset_token_digest BLOB, reset_token_expires DATETIME)`); err != nil {
		t.Fatal(err)
	}
	t.Setenv("PUBLISHER_UPDATE_TEST_KEY", base64.StdEncoding.EncodeToString(bytes.Repeat([]byte{31}, 32)))
	config := &genelet.Config{
		AccountProtection: genelet.AccountProtectionConfig{
			Enabled: true, PlaintextRetired: retired,
			Current: genelet.AccountProtectionKeyConfig{ID: "test-v1", KeyEnv: "PUBLISHER_UPDATE_TEST_KEY"},
		},
		Roles: map[string]genelet.Role{"pub": {Issuers: map[string]genelet.Issuer{"db": {
			PasswordHash: "passwd", ProtectedSQL: "SELECT", IdentifierNamespace: "pub.email",
			IdentifierNormalization: "email", IdentifierCipherAttribute: "p_email",
		}}}},
	}
	protector, err := genelet.NewAccountProtector(config)
	if err != nil {
		t.Fatal(err)
	}
	oldDigest, oldCipher, err := protector.ProtectIdentifier("pub.email", "email", "old@example.test")
	if err != nil {
		t.Fatal(err)
	}
	if _, err := db.Exec(`INSERT INTO testing_pub (pub_id,email,email_hmac,email_cipher,activation_token_digest,reset_token_digest) VALUES (7,'old@example.test',?,?,X'01',X'02')`, oldDigest, oldCipher); err != nil {
		t.Fatal(err)
	}
	lists := make([]map[string]interface{}, 0)
	other := make(map[string]interface{})
	args := url.Values{"pub_id": {"7"}, "email": {" New@Example.Test "}}
	model := &Model{}
	model.DB = db
	model.CurrentTable = "testing_pub"
	model.CurrentKey = "pub_id"
	model.UpdatePars = []string{"pub_id", "email", "email_hmac", "email_cipher"}
	model.ARGS, model.LISTS, model.OTHER = args, &lists, &other
	model.Storage = map[string]interface{}{summer.AccountProtectionStorageKey: protector}
	return model, db, protector
}

func TestProtectedPublisherUpdateWritesOneTupleAndScrubsResponse(t *testing.T) {
	model, db, protector := publisherUpdateModel(t, false)
	if err := model.Update(); err != nil {
		t.Fatal(err)
	}
	var email, cipher string
	var digest []byte
	if err := db.QueryRow(`SELECT email,email_hmac,email_cipher FROM testing_pub WHERE pub_id=7`).Scan(&email, &digest, &cipher); err != nil {
		t.Fatal(err)
	}
	plain, err := protector.DecryptIdentifier("pub.email", cipher)
	if err != nil || email != "new@example.test" || plain != email || len(digest) != 32 {
		t.Fatalf("protected tuple email=%q plain=%q digest=%d err=%v", email, plain, len(digest), err)
	}
	if model.ARGS.Get("email_hmac") != "" || model.ARGS.Get("email_cipher") != "" {
		t.Fatal("storage-only publisher fields remained in request arguments")
	}
	if len(*model.LISTS) != 1 {
		t.Fatalf("response rows = %d", len(*model.LISTS))
	}
	if _, ok := (*model.LISTS)[0]["email_hmac"]; ok {
		t.Fatal("publisher digest leaked into the response row")
	}
	if _, ok := (*model.LISTS)[0]["email_cipher"]; ok {
		t.Fatal("publisher ciphertext leaked into the response row")
	}
	var activation, reset []byte
	if err := db.QueryRow(`SELECT activation_token_digest,reset_token_digest FROM testing_pub WHERE pub_id=7`).Scan(&activation, &reset); err != nil {
		t.Fatal(err)
	}
	if activation != nil || reset != nil {
		t.Fatalf("identifier change retained action proofs: activation=%x reset=%x", activation, reset)
	}
}

func TestRetiredPublisherUpdateDoesNotReferencePlaintextColumn(t *testing.T) {
	model, db, _ := publisherUpdateModel(t, true)
	if _, err := db.Exec(`ALTER TABLE testing_pub DROP COLUMN email`); err != nil {
		t.Fatal(err)
	}
	if err := model.Update(); err != nil {
		t.Fatal(err)
	}
}
