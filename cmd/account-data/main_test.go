package main

import (
	"bytes"
	"context"
	"database/sql"
	"encoding/base64"
	"errors"
	"strings"
	"testing"

	mysqlDriver "github.com/go-sql-driver/mysql"
	"github.com/guruperl/genelet"
	_ "github.com/mattn/go-sqlite3"
)

func TestSafeDatabaseErrorDoesNotEchoDriverValues(t *testing.T) {
	const secret = "identifier-or-digest-must-not-escape"
	got := safeDatabaseError("protected account update", &mysqlDriver.MySQLError{Number: 1062, Message: "Duplicate entry '" + secret + "'"})
	if strings.Contains(got.Error(), secret) || !strings.Contains(got.Error(), "mysql code 1062") {
		t.Fatalf("sanitized MySQL error = %q", got)
	}
	got = safeDatabaseError("verification scan", errors.New(secret))
	if strings.Contains(got.Error(), secret) {
		t.Fatalf("sanitized generic error = %q", got)
	}
}

func accountDataTestProtector(t *testing.T, retired bool) *genelet.AccountProtector {
	t.Helper()
	t.Setenv("ACCOUNT_DATA_COMMAND_TEST_KEY", base64.StdEncoding.EncodeToString(bytes.Repeat([]byte{23}, 32)))
	config := &genelet.Config{
		AccountProtection: genelet.AccountProtectionConfig{
			Enabled: true, PlaintextRetired: retired,
			Current: genelet.AccountProtectionKeyConfig{ID: "test-v1", KeyEnv: "ACCOUNT_DATA_COMMAND_TEST_KEY"},
		},
		Roles: map[string]genelet.Role{"adv": {Issuers: map[string]genelet.Issuer{"db": {
			PasswordHash: "passwd", ProtectedSQL: "SELECT", IdentifierNamespace: "adv.email",
			IdentifierNormalization: "email", IdentifierCipherAttribute: "a_email",
		}}}},
	}
	protector, err := genelet.NewAccountProtector(config)
	if err != nil {
		t.Fatal(err)
	}
	return protector
}

func TestVerifyTableRequiresRollbackIdentifierParity(t *testing.T) {
	db, err := sql.Open("sqlite3", ":memory:")
	if err != nil {
		t.Fatal(err)
	}
	defer db.Close()
	if _, err := db.Exec(`CREATE TABLE adv (adv_id INTEGER PRIMARY KEY, email TEXT NOT NULL, email_hmac BLOB, email_cipher BLOB)`); err != nil {
		t.Fatal(err)
	}
	protector := accountDataTestProtector(t, false)
	digest, encrypted, err := protector.ProtectIdentifier("adv.email", "email", "owner@example.test")
	if err != nil {
		t.Fatal(err)
	}
	if _, err := db.Exec(`INSERT INTO adv VALUES (1,'different@example.test',?,?)`, digest, encrypted); err != nil {
		t.Fatal(err)
	}
	if _, err := verifyTable(context.Background(), db, protector, accountTables[0], 10); err == nil || !strings.Contains(err.Error(), "rollback identifier") {
		t.Fatalf("rollback parity error = %v", err)
	}
}

func TestVerifyTableDoesNotReferenceRetiredPlaintextColumn(t *testing.T) {
	db, err := sql.Open("sqlite3", ":memory:")
	if err != nil {
		t.Fatal(err)
	}
	defer db.Close()
	if _, err := db.Exec(`CREATE TABLE adv (adv_id INTEGER PRIMARY KEY, email_hmac BLOB, email_cipher BLOB)`); err != nil {
		t.Fatal(err)
	}
	protector := accountDataTestProtector(t, true)
	digest, encrypted, err := protector.ProtectIdentifier("adv.email", "email", "owner@example.test")
	if err != nil {
		t.Fatal(err)
	}
	if _, err := db.Exec(`INSERT INTO adv VALUES (1,?,?)`, digest, encrypted); err != nil {
		t.Fatal(err)
	}
	result, err := verifyTable(context.Background(), db, protector, accountTables[0], 10)
	if err != nil || result.processed != 1 {
		t.Fatalf("retired verification = %+v, %v", result, err)
	}
}

func TestRotationRejectsMismatchedLookupDigest(t *testing.T) {
	protector := accountDataTestProtector(t, false)
	digest, _, err := protector.ProtectIdentifier("adv.email", "email", "owner@example.test")
	if err != nil {
		t.Fatal(err)
	}
	matched, err := lookupDigestMatches(protector, accountTables[0], "owner@example.test", digest)
	if err != nil || !matched {
		t.Fatalf("valid digest match = %v, %v", matched, err)
	}
	digest[0] ^= 0xff
	matched, err = lookupDigestMatches(protector, accountTables[0], "owner@example.test", digest)
	if err != nil || matched {
		t.Fatalf("corrupt digest match = %v, %v", matched, err)
	}
}

func TestSourceValidationReportsOnlyNumericID(t *testing.T) {
	db, err := sql.Open("sqlite3", ":memory:")
	if err != nil {
		t.Fatal(err)
	}
	defer db.Close()
	if _, err := db.Exec(`CREATE TABLE pub (pub_id INTEGER PRIMARY KEY, email TEXT NOT NULL)`); err != nil {
		t.Fatal(err)
	}
	const invalid = "historical-domain-without-an-email"
	if _, err := db.Exec(`INSERT INTO pub (pub_id,email) VALUES (19,?)`, invalid); err != nil {
		t.Fatal(err)
	}
	err = validatePlaintextTable(context.Background(), db, accountTables[1])
	if err == nil || !strings.Contains(err.Error(), "account id 19") || strings.Contains(err.Error(), invalid) {
		t.Fatalf("source validation error = %v", err)
	}
}
