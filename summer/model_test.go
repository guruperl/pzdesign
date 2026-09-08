package summer

import (
	"bytes"
	"context"
	"database/sql"
	"encoding/base64"
	"net/url"
	"testing"

	"github.com/guruperl/genelet"
	_ "github.com/mattn/go-sqlite3"
)

func openAccountProtectionTestDB(t *testing.T) *sql.DB {
	t.Helper()
	db, err := sql.Open("sqlite3", ":memory:")
	if err != nil {
		t.Fatal(err)
	}
	db.SetMaxOpenConns(1)
	t.Cleanup(func() { db.Close() })
	return db
}

func testAccountProtector(t *testing.T) *genelet.AccountProtector {
	return testAccountProtectorWithRetirement(t, false)
}

func testAccountProtectorWithRetirement(t *testing.T, retired bool) *genelet.AccountProtector {
	t.Helper()
	t.Setenv("SUMMER_ACCOUNT_TEST_KEY", base64.StdEncoding.EncodeToString(bytes.Repeat([]byte{8}, 32)))
	protector, err := genelet.NewAccountProtector(&genelet.Config{
		AccountProtection: genelet.AccountProtectionConfig{Enabled: true, PlaintextRetired: retired, Current: genelet.AccountProtectionKeyConfig{ID: "test-v1", KeyEnv: "SUMMER_ACCOUNT_TEST_KEY"}},
		Roles: map[string]genelet.Role{"adv": {Issuers: map[string]genelet.Issuer{"db": {
			PasswordHash: "passwd", ProtectedSQL: "SELECT", IdentifierNamespace: "adv.email",
			IdentifierNormalization: "email", IdentifierCipherAttribute: "a_email",
		}}}},
	})
	if err != nil {
		t.Fatal(err)
	}
	return protector
}

func TestRetiredAccountInsertOmitsPlaintextIdentifierColumn(t *testing.T) {
	db := openAccountProtectionTestDB(t)
	if _, err := db.Exec(`CREATE TABLE adv (adv_id INTEGER PRIMARY KEY, email_hmac BLOB NOT NULL UNIQUE, email_cipher TEXT NOT NULL, address_id INTEGER)`); err != nil {
		t.Fatal(err)
	}
	if _, err := db.Exec(`CREATE TABLE add_address (address_id INTEGER PRIMARY KEY AUTOINCREMENT, company TEXT, contact TEXT, contact_email TEXT)`); err != nil {
		t.Fatal(err)
	}
	address := new(Model)
	genelet.Invoke0(address, "Initialize", genelet.NewComponent("address/component.json"))
	protector := testAccountProtectorWithRetirement(t, true)
	storage := map[string]interface{}{"address": address, AccountProtectionStorageKey: protector}
	model := new(Model)
	model.DB, model.CurrentTable, model.CurrentKey = db, "adv", "adv_id"
	model.SetDriver("sqlite3")
	model.InsertPars = []string{"adv_id", "email", "email_hmac", "email_cipher", "address_id"}
	args := url.Values{
		"adv_id": {"17"}, "email": {"Owner@Example.Test"},
		"contact": {"Owner"}, "contact_email": {"owner@example.test"}, "company": {"Example"},
	}
	lists := make([]map[string]interface{}, 0)
	other := make(map[string]interface{})
	model.SetDefaults(args, &lists, &other, storage)
	if err := model.Insert(url.Values{}); err != nil {
		t.Fatal(err)
	}
	var digest []byte
	var encrypted string
	if err := db.QueryRow(`SELECT email_hmac,email_cipher FROM adv WHERE adv_id=17`).Scan(&digest, &encrypted); err != nil {
		t.Fatal(err)
	}
	plain, err := protector.DecryptIdentifier("adv.email", encrypted)
	if err != nil || plain != "owner@example.test" || len(digest) != 32 {
		t.Fatalf("retired insert identifier=%q digest=%d err=%v", plain, len(digest), err)
	}
	if len(lists) != 1 {
		t.Fatalf("response rows = %d", len(lists))
	}
	if _, exists := lists[0]["email_hmac"]; exists {
		t.Fatal("account digest leaked into the insert response")
	}
	if _, exists := lists[0]["email_cipher"]; exists {
		t.Fatal("account ciphertext leaked into the insert response")
	}
}

func TestProtectedAdvertiserUpdateKeepsTupleTogetherAndRevokesProofs(t *testing.T) {
	db := openAccountProtectionTestDB(t)
	if _, err := db.Exec(`CREATE TABLE testing_adv (
		adv_id INTEGER PRIMARY KEY, email TEXT, email_hmac BLOB NOT NULL,
		email_cipher TEXT NOT NULL, activation_token_digest BLOB,
		activation_token_expires DATETIME, reset_token_digest BLOB,
		reset_token_expires DATETIME
	)`); err != nil {
		t.Fatal(err)
	}
	protector := testAccountProtector(t)
	oldDigest, oldCipher, err := protector.ProtectIdentifier("adv.email", "email", "old@example.test")
	if err != nil {
		t.Fatal(err)
	}
	if _, err := db.Exec(`INSERT INTO testing_adv
		(adv_id,email,email_hmac,email_cipher,activation_token_digest,reset_token_digest)
		VALUES (7,'old@example.test',?,?,X'01',X'02')`, oldDigest, oldCipher); err != nil {
		t.Fatal(err)
	}
	args := url.Values{"adv_id": {"7"}, "email": {" New@Example.Test "}}
	lists := make([]map[string]interface{}, 0)
	other := make(map[string]interface{})
	model := &Model{}
	model.DB, model.CurrentTable, model.CurrentKey = db, "testing_adv", "adv_id"
	model.UpdatePars = []string{"adv_id", "email", "email_hmac", "email_cipher"}
	model.SetDefaults(args, &lists, &other, map[string]interface{}{AccountProtectionStorageKey: protector})
	if err := model.UpdateProtectedAccount("adv"); err != nil {
		t.Fatal(err)
	}
	var email, encrypted string
	var digest, activation, reset []byte
	if err := db.QueryRow(`SELECT email,email_hmac,email_cipher,activation_token_digest,reset_token_digest FROM testing_adv WHERE adv_id=7`).
		Scan(&email, &digest, &encrypted, &activation, &reset); err != nil {
		t.Fatal(err)
	}
	plain, err := protector.DecryptIdentifier("adv.email", encrypted)
	if err != nil || email != "new@example.test" || plain != email || len(digest) != 32 {
		t.Fatalf("protected tuple email=%q plain=%q digest=%d err=%v", email, plain, len(digest), err)
	}
	if activation != nil || reset != nil {
		t.Fatalf("identifier change retained action proofs: activation=%x reset=%x", activation, reset)
	}
}

func TestIdentifierAvailabilityChecksPreviousRotationKeys(t *testing.T) {
	db := openAccountProtectionTestDB(t)
	if _, err := db.Exec(`CREATE TABLE adv (adv_id INTEGER PRIMARY KEY, email_hmac BLOB NOT NULL UNIQUE)`); err != nil {
		t.Fatal(err)
	}
	t.Setenv("SUMMER_ACCOUNT_CURRENT_TEST_KEY", base64.StdEncoding.EncodeToString(bytes.Repeat([]byte{51}, 32)))
	t.Setenv("SUMMER_ACCOUNT_PREVIOUS_TEST_KEY", base64.StdEncoding.EncodeToString(bytes.Repeat([]byte{52}, 32)))
	config := &genelet.Config{
		AccountProtection: genelet.AccountProtectionConfig{
			Enabled:  true,
			Current:  genelet.AccountProtectionKeyConfig{ID: "current", KeyEnv: "SUMMER_ACCOUNT_CURRENT_TEST_KEY"},
			Previous: []genelet.AccountProtectionKeyConfig{{ID: "previous", KeyEnv: "SUMMER_ACCOUNT_PREVIOUS_TEST_KEY"}},
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
	digests, err := protector.LookupDigests("adv.email", "email", "owner@example.test")
	if err != nil {
		t.Fatal(err)
	}
	if _, err := db.Exec(`INSERT INTO adv (adv_id,email_hmac) VALUES (7,?)`, digests[1]); err != nil {
		t.Fatal(err)
	}
	storage := map[string]interface{}{AccountProtectionStorageKey: protector}
	if err := EnsureAccountIdentifierAvailable(context.Background(), db, storage, "adv", "owner@example.test", ""); err == nil {
		t.Fatal("previous-key identifier was available for a duplicate insert")
	}
	if err := EnsureAccountIdentifierAvailable(context.Background(), db, storage, "adv", "owner@example.test", "7"); err != nil {
		t.Fatalf("current account could not retain its identifier: %v", err)
	}
}

func TestResetpassRequiresMatchingEmail(t *testing.T) {
	db := openSummerTestDB(t)
	defer db.Close()

	const table = "testing_resetpass"
	if _, err := db.Exec(`DROP TABLE IF EXISTS ` + table); err != nil {
		t.Fatal(err)
	}
	defer func() { _, _ = db.Exec(`DROP TABLE IF EXISTS ` + table) }()
	if _, err := db.Exec(`CREATE TABLE ` + table + ` (
		id int(10) unsigned NOT NULL,
		email varchar(255) NOT NULL,
		passwd varchar(255) NOT NULL,
		active enum('Yes','No','New') default 'New',
		PRIMARY KEY (id)
	)`); err != nil {
		t.Fatal(err)
	}
	if _, err := db.Exec(`INSERT INTO ` + table + ` (id, email, passwd) VALUES (1, 'owner@example.test', 'original')`); err != nil {
		t.Fatal(err)
	}

	model := new(Model)
	model.DB = db
	model.CurrentTable = table
	model.CurrentKey = "id"
	args := make(url.Values)
	lists := make([]map[string]interface{}, 0)
	other := make(map[string]interface{})
	model.SetDefaults(args, &lists, &other, nil)
	args.Set("id", "1")
	args.Set("passwd", "replacement")
	args.Set("email", "different@example.test")

	if err := model.Resetpass(); err != nil {
		t.Fatal(err)
	}
	var stored string
	if err := db.QueryRow(`SELECT passwd FROM ` + table + ` WHERE id=1`).Scan(&stored); err != nil {
		t.Fatal(err)
	}
	if stored != "original" {
		t.Fatal("password changed for a non-matching email")
	}

	args.Set("email", "owner@example.test")
	if err := model.Resetpass(); err != nil {
		t.Fatal(err)
	}
	if err := db.QueryRow(`SELECT passwd FROM ` + table + ` WHERE id=1`).Scan(&stored); err != nil {
		t.Fatal(err)
	}
	if err := genelet.CheckPasswordHash("replacement", stored); err != nil {
		t.Fatal("password was not changed for the matching email")
	}
}

func TestProtectedResetpassMatchesOnlyIdentifierDigest(t *testing.T) {
	db := openAccountProtectionTestDB(t)
	if _, err := db.Exec(`CREATE TABLE adv (adv_id INTEGER PRIMARY KEY, email TEXT NOT NULL, email_hmac BLOB, email_cipher TEXT, passwd TEXT NOT NULL, active TEXT, activation_token_digest BLOB, activation_token_expires DATETIME, reset_token_digest BLOB, reset_token_expires DATETIME)`); err != nil {
		t.Fatal(err)
	}
	protector := testAccountProtector(t)
	digest, encrypted, err := protector.ProtectIdentifier("adv.email", "email", "owner@example.test")
	if err != nil {
		t.Fatal(err)
	}
	if _, err := db.Exec(`INSERT INTO adv (adv_id,email,email_hmac,email_cipher,passwd,active) VALUES (1,'legacy-visible@example.test',?,?, 'original','New')`, digest, encrypted); err != nil {
		t.Fatal(err)
	}
	model := &Model{}
	model.DB, model.CurrentTable, model.CurrentKey = db, "adv", "adv_id"
	storage := map[string]interface{}{AccountProtectionStorageKey: protector}
	token, err := IssueAccountActionToken(context.Background(), db, storage, "adv", "1", "reset", "owner@example.test")
	if err != nil {
		t.Fatal(err)
	}
	args := url.Values{"adv_id": {"1"}, "action_token": {token}, "passwd": {"replacement"}}
	lists := make([]map[string]interface{}, 0)
	other := make(map[string]interface{})
	model.SetDefaults(args, &lists, &other, storage)
	if err := model.Resetpass(); err != nil {
		t.Fatal(err)
	}
	var stored string
	if err := db.QueryRow(`SELECT passwd FROM adv WHERE adv_id=1`).Scan(&stored); err != nil {
		t.Fatal(err)
	}
	if err := genelet.CheckPasswordHash("replacement", stored); err != nil {
		t.Fatal("protected reset did not update bcrypt password")
	}
	args.Set("email", "legacy-visible@example.test")
	args.Set("action_token", base64.RawURLEncoding.EncodeToString(bytes.Repeat([]byte{99}, 32)))
	args.Set("passwd", "must-not-match-plaintext")
	if err := model.Resetpass(); err == nil {
		t.Fatal("plaintext column value authorized a protected reset")
	}
}

func TestProtectedTopicsReadsCiphertextWithoutPlaintextColumn(t *testing.T) {
	db := openAccountProtectionTestDB(t)
	if _, err := db.Exec(`CREATE TABLE adv (adv_id INTEGER PRIMARY KEY, email_cipher TEXT NOT NULL)`); err != nil {
		t.Fatal(err)
	}
	protector := testAccountProtector(t)
	_, encrypted, err := protector.ProtectIdentifier("adv.email", "email", "owner@example.test")
	if err != nil {
		t.Fatal(err)
	}
	if _, err := db.Exec(`INSERT INTO adv (adv_id,email_cipher) VALUES (1,?)`, encrypted); err != nil {
		t.Fatal(err)
	}
	model := &Model{}
	model.DB, model.CurrentTable, model.CurrentKey = db, "adv", "adv_id"
	model.SetDriver("sqlite3")
	model.TopicsPars = []string{"adv_id", "email"}
	args := make(url.Values)
	lists := make([]map[string]interface{}, 0)
	other := make(map[string]interface{})
	model.SetDefaults(args, &lists, &other, map[string]interface{}{AccountProtectionStorageKey: protector})
	if err := model.Topics(); err != nil {
		t.Fatal(err)
	}
	if len(lists) != 1 || lists[0]["email"] != "owner@example.test" {
		t.Fatalf("protected topics = %#v", lists)
	}
	if _, exists := lists[0]["email_cipher"]; exists {
		t.Fatal("ciphertext leaked into the model response")
	}
}

func TestProtectedTopicsHashReplacesPlaintextProjection(t *testing.T) {
	got, replaced := replaceProtectedHash(map[string]string{"p.adv_id": "adv_id", "p.email": "email"}, "p.email", "p.email_cipher", "email_cipher")
	if !replaced || got["p.email_cipher"] != "email_cipher" {
		t.Fatalf("protected topics hash = %#v replaced=%v", got, replaced)
	}
	if _, exists := got["p.email"]; exists {
		t.Fatal("plaintext identifier projection remained enabled")
	}
}

func TestModelExternal(t *testing.T) {
	db := openSummerTestDB(t)
	defer db.Close()

	model := new(Model)
	model.DB = db
	model.CurrentTable = "testing_summer"
	model.SORTBY = "sortby"
	model.SORTREVERSE = "sortreverse"
	model.PAGENO = "pageno"
	model.ROWCOUNT = "rowcount"
	model.TOTALNO = "totalno"
	model.MAXPAGENO = "max_pageno"
	model.FIELD = "field"
	model.EMPTIES = "empties"

	ret := model.ExecSQL(`drop table if exists testing_f`)
	if ret != nil {
		t.Errorf("create table testing_f failed %s", ret.Error())
	}
	ret = model.ExecSQL(`drop table if exists testing_summer`)
	if ret != nil {
		t.Errorf("create table testing failed %s", ret.Error())
	}
	ret = model.ExecSQL(`CREATE TABLE testing_summer (id int(10) unsigned NOT NULL, email varchar(255) not null, address_id int(10) unsigned DEFAULT NULL, active enum('Yes','No','New') default 'New', primary key (id))`)
	if ret != nil {
		t.Errorf("create table testing failed %s", ret.Error())
	}

	add := new(Model)
	comp := genelet.NewComponent("address/component.json")
	genelet.Invoke0(add, "Initialize", comp)
	storage := map[string]interface{}{"address": add}

	args := make(url.Values)
	lists := make([]map[string]interface{}, 0)
	other := make(map[string]interface{})
	extra := []url.Values{{}}
	model.SetDefaults(args, &lists, &other, storage)

	model.CurrentKey = "id"
	addressTables = append(addressTables, "testing_summer")
	defer func() { addressTables = addressTables[:len(addressTables)-1] }()
	model.InsertPars = []string{"id", "email", "address_id"}
	model.EditPars = []string{"id", "email", "address_id", "active"}
	model.UpdatePars = []string{"id", "email", "address_id"}

	args["email"] = []string{"a_email"}
	args["contact"] = []string{"b_contact"}
	args["contact_email"] = args["email"]
	args["company"] = []string{"b_company"}

	args["id"] = []string{"160"}
	err := model.Insert(extra...)
	if err != nil {
		t.Fatal(err)
	}
	result := other["address_insert"].([]map[string]interface{})
	if result[0]["company"].(string) != "b_company" {
		t.Errorf("%v", other)
	}
	addressID := result[0]["address_id"].(string)
	address := lists[0]["address_id"].(string)
	if addressID != address {
		t.Errorf("%s", addressID)
		t.Errorf("%s", address)
		t.Errorf("%v", lists)
	}

	lists = make([]map[string]interface{}, 0)
	extra = []url.Values{{}}
	err = model.Edit(extra...)
	if err != nil {
		t.Fatal(err)
	}
	if lists[0]["contact"].(string) != "b_contact" {
		t.Errorf("%v", lists)
	}

	err = model.Activate(extra...)
	if err == nil {
		lists = make([]map[string]interface{}, 0)
		err = model.Edit(extra...)
	}
	if err != nil {
		t.Fatal(err)
	}
	if lists[0]["active"].(string) != "Yes" {
		t.Errorf("%v", lists)
	}

	lists = make([]map[string]interface{}, 0)
	extra = []url.Values{{}}
	args["email"] = []string{"c_email"}
	args["contact"] = []string{"c_contact"}
	err = model.Update(extra...)
	if err == nil {
		err = model.Edit(extra...)
	}
	if err != nil {
		t.Fatal(err)
	}
	if lists[0]["contact"].(string) != "c_contact" || lists[0]["email"].(string) != "c_email" {
		t.Errorf("%v", lists)
	}

	if _, err = db.Exec("DROP TABLE testing_summer"); err == nil {
		_, err = db.Exec("DELETE FROM add_address WHERE address_id=?", addressID)
	}
	if err != nil {
		t.Errorf("%v", err)
	}
}

func TestScrubAccountProtectionInputRejectsClientStorageFields(t *testing.T) {
	values := url.Values{
		"email":                    {"owner@example.test"},
		"email_hmac":               {"attacker-controlled"},
		"email_cipher":             {"attacker-controlled"},
		"login_hmac":               {"attacker-controlled"},
		"login_cipher":             {"attacker-controlled"},
		"activation_token_digest":  {"attacker-controlled"},
		"activation_token_expires": {"attacker-controlled"},
		"reset_token_digest":       {"attacker-controlled"},
		"reset_token_expires":      {"attacker-controlled"},
	}
	ScrubAccountProtectionInput(values)
	if values.Get("email") != "owner@example.test" {
		t.Fatal("ordinary identifier input was removed")
	}
	for key := range values {
		if key != "email" {
			t.Fatalf("storage-only request field survived: %s", key)
		}
	}
}

/*
	func loadSample(mysqlConn string) error {
		re := regexp.MustCompile(`^(\S+):(\S+)@tcp\((\S+)\)\/(\S+)$`)
		arr := re.FindStringSubmatch(mysqlConn)
		if len(arr) != 5 {
			return fmt.Errorf("%s not found", mysqlConn)
		}
		user := arr[1]
		pass := arr[2]
		host := arr[3]
		name := arr[4]
		if user == "" || pass == "" || host == "" || name == "" {
			return fmt.Errorf("%s", mysqlConn)
		}
		cmd := exec.Command("mysql", "-u"+user, "-p"+pass, "-h", host, name, "<", "sample.sql")
		bs, err := cmd.Output()
		if err != nil {
			log.Printf("%s", cmd.String()
		)
			log.Printf("%s", bs)
			return err
		}
		cmd = exec.Command("mysql", "-u"+user, "-p"+pass, "-h", host, name, "<", "more.sql")
		return cmd.Run()
	}
*/
func TestModelSummer(t *testing.T) {
	db := openSummerTestDB(t)
	defer db.Close()

	model := new(Model)
	model.DB = db
	model.CurrentTable = "pub_slot"

	storage := make(map[string]interface{})

	args := make(url.Values)
	lists := make([]map[string]interface{}, 0)
	other := make(map[string]interface{})
	extra := []url.Values{{}}
	model.SetDefaults(args, &lists, &other, storage)

	model.CurrentKey = "slot_id"
	model.EditPars = []string{"slot_id", "site_id", "slot_name", "qa_device", "qa_position", "fl_expnd", "channel_order", "created", "active"}

	args["slot_id"] = []string{"1"}
	err := model.Edit(extra...)

	if err != nil {
		t.Fatal(err)
	}

	one := lists[0]
	if one["active"].(string) != "Yes" ||
		one["slot_name"].(string) != "defaultSlot" ||
		one["slot_id"].(int64) != 1 ||
		one["site_id"].(int64) != 1 ||
		one["qa_device"].(string) != "0" ||
		one["qa_position"].(string) != "0" ||
		one["fl_expnd"].(string) != "0,1,2,3,4,5" ||
		one["channel_order"].(string) != "Black" {
		t.Errorf("%v", lists)
	}
}
