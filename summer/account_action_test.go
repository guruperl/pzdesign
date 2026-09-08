package summer

import (
	"context"
	"database/sql"
	"testing"
	"time"

	"github.com/guruperl/genelet"
)

func newAccountActionTestDB(t *testing.T) *sql.DB {
	t.Helper()
	db := openAccountProtectionTestDB(t)
	if _, err := db.Exec(`CREATE TABLE adv (
		adv_id INTEGER PRIMARY KEY,
		email_hmac BLOB NOT NULL UNIQUE,
		passwd TEXT NOT NULL,
		active TEXT NOT NULL,
		activation_token_digest BLOB,
		activation_token_expires DATETIME,
		reset_token_digest BLOB,
		reset_token_expires DATETIME
	)`); err != nil {
		t.Fatal(err)
	}
	return db
}

const accountActionTestEmail = "owner@example.test"

func insertAccountActionTestAccount(t *testing.T, db *sql.DB, protector *genelet.AccountProtector, active string) {
	t.Helper()
	digest, _, err := protector.ProtectIdentifier("adv.email", "email", accountActionTestEmail)
	if err != nil {
		t.Fatal(err)
	}
	if _, err := db.Exec(`INSERT INTO adv (adv_id,email_hmac,passwd,active) VALUES (1,?,'original',?)`, digest, active); err != nil {
		t.Fatal(err)
	}
}

func TestAccountActionTokensAreOpaqueExpiringAndSingleUse(t *testing.T) {
	db := newAccountActionTestDB(t)
	protector := testAccountProtector(t)
	insertAccountActionTestAccount(t, db, protector, "New")
	storage := map[string]interface{}{AccountProtectionStorageKey: protector}
	if _, err := IssueAccountActionToken(context.Background(), db, storage, "adv", "1", "activate", "changed@example.test"); err == nil {
		t.Fatal("token issuance ignored a concurrent identifier change")
	}
	token, err := IssueAccountActionToken(context.Background(), db, storage, "adv", "1", "activate", accountActionTestEmail)
	if err != nil {
		t.Fatal(err)
	}
	var stored []byte
	if err := db.QueryRow(`SELECT activation_token_digest FROM adv WHERE adv_id=1`).Scan(&stored); err != nil {
		t.Fatal(err)
	}
	if string(stored) == token || len(stored) != 32 {
		t.Fatalf("stored activation proof is not an opaque digest: len=%d", len(stored))
	}
	if err := ValidateAccountActionToken(context.Background(), db, storage, "adv", "1", "activate", token); err != nil {
		t.Fatal(err)
	}
	if err := ConsumeAccountActivation(context.Background(), db, storage, "adv", "1", token); err != nil {
		t.Fatal(err)
	}
	if err := ConsumeAccountActivation(context.Background(), db, storage, "adv", "1", token); err == nil {
		t.Fatal("consumed activation token was reusable")
	}
	var active string
	var digest any
	if err := db.QueryRow(`SELECT active,activation_token_digest FROM adv WHERE adv_id=1`).Scan(&active, &digest); err != nil {
		t.Fatal(err)
	}
	if active != "Yes" || digest != nil {
		t.Fatalf("activation state = %q digest=%v", active, digest)
	}
}

func TestAccountPasswordResetTokenExpiresAndConsumesWithBcryptWrite(t *testing.T) {
	db := newAccountActionTestDB(t)
	protector := testAccountProtector(t)
	insertAccountActionTestAccount(t, db, protector, "Yes")
	storage := map[string]interface{}{AccountProtectionStorageKey: protector}
	token, err := IssueAccountActionToken(context.Background(), db, storage, "adv", "1", "reset", accountActionTestEmail)
	if err != nil {
		t.Fatal(err)
	}
	if _, err := db.Exec(`UPDATE adv SET reset_token_expires=? WHERE adv_id=1`, time.Now().UTC().Add(-time.Minute)); err != nil {
		t.Fatal(err)
	}
	hash, err := genelet.HashPassword("replacement account passphrase")
	if err != nil {
		t.Fatal(err)
	}
	if err := ConsumeAccountPasswordReset(context.Background(), db, storage, "adv", "1", token, hash); err == nil {
		t.Fatal("expired reset token was accepted")
	}
	token, err = IssueAccountActionToken(context.Background(), db, storage, "adv", "1", "reset", accountActionTestEmail)
	if err != nil {
		t.Fatal(err)
	}
	if err := ConsumeAccountPasswordReset(context.Background(), db, storage, "adv", "1", token, hash); err != nil {
		t.Fatal(err)
	}
	var stored string
	var digest any
	if err := db.QueryRow(`SELECT passwd,reset_token_digest FROM adv WHERE adv_id=1`).Scan(&stored, &digest); err != nil {
		t.Fatal(err)
	}
	if err := genelet.CheckPasswordHash("replacement account passphrase", stored); err != nil {
		t.Fatal("reset did not store the expected bcrypt hash")
	}
	if digest != nil {
		t.Fatal("reset token digest remained after use")
	}
}

func TestPasswordResetInvalidatesPendingActivationProof(t *testing.T) {
	db := newAccountActionTestDB(t)
	protector := testAccountProtector(t)
	insertAccountActionTestAccount(t, db, protector, "New")
	storage := map[string]interface{}{AccountProtectionStorageKey: protector}
	activation, err := IssueAccountActionToken(context.Background(), db, storage, "adv", "1", "activate", accountActionTestEmail)
	if err != nil {
		t.Fatal(err)
	}
	reset, err := IssueAccountActionToken(context.Background(), db, storage, "adv", "1", "reset", accountActionTestEmail)
	if err != nil {
		t.Fatal(err)
	}
	hash, err := genelet.HashPassword("replacement account passphrase")
	if err != nil {
		t.Fatal(err)
	}
	if err := ConsumeAccountPasswordReset(context.Background(), db, storage, "adv", "1", reset, hash); err != nil {
		t.Fatal(err)
	}
	if err := ConsumeAccountActivation(context.Background(), db, storage, "adv", "1", activation); err == nil {
		t.Fatal("password recovery left a pending activation proof usable")
	}
}
