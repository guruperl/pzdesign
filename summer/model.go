// Package summer provides models and methods for handling various operations
// related to addresses, user accounts, and administrative tasks.
package summer

import (
	"context"
	"database/sql"
	"fmt"
	"net/url"
	"strconv"

	"github.com/guruperl/genelet"
)

type Model struct {
	genelet.Model
}

var addressTables []string = []string{"pub", "adv", "testing"}

func accountProtector(storage map[string]interface{}) (*genelet.AccountProtector, bool, error) {
	raw, exists := storage[AccountProtectionStorageKey]
	if !exists || raw == nil {
		return nil, false, nil
	}
	protector, ok := raw.(*genelet.AccountProtector)
	if !ok {
		return nil, false, fmt.Errorf("storage %s has type %T, want *genelet.AccountProtector", AccountProtectionStorageKey, raw)
	}
	return protector, true, nil
}

// AccountProtectionEnabled reports whether protected account reads and writes
// are authoritative for this request.
func AccountProtectionEnabled(storage map[string]interface{}) (bool, error) {
	_, enabled, err := accountProtector(storage)
	return enabled, err
}

// AccountPlaintextRetired reports whether write paths must omit the legacy
// plaintext identifier column after the separately reviewed one-way cutover.
func AccountPlaintextRetired(storage map[string]interface{}) (bool, error) {
	protector, enabled, err := accountProtector(storage)
	if err != nil || !enabled {
		return false, err
	}
	return protector.PlaintextRetired(), nil
}

func accountIdentifierContract(role string) (field, digestField, cipherField, namespace, normalization string, err error) {
	switch role {
	case "adv", "pub":
		return "email", "email_hmac", "email_cipher", role + ".email", "email", nil
	case "admin", "agent", "analyst":
		return "login", "login_hmac", "login_cipher", role + ".login", "login", nil
	default:
		return "", "", "", "", "", fmt.Errorf("unsupported protected account role %q", role)
	}
}

// ProtectAccountIdentifier normalizes the request value and returns the
// additive database fields for one account role. A nil result means the
// protection boundary is disabled and the legacy write remains unchanged.
func ProtectAccountIdentifier(storage map[string]interface{}, role, value string) (url.Values, error) {
	protector, enabled, err := accountProtector(storage)
	if err != nil || !enabled {
		return nil, err
	}
	_, digestField, cipherField, namespace, normalization, err := accountIdentifierContract(role)
	if err != nil {
		return nil, err
	}
	normalized, err := genelet.NormalizeAccountIdentifier(normalization, value)
	if err != nil {
		return nil, err
	}
	digest, encrypted, err := protector.ProtectIdentifier(namespace, normalization, normalized)
	if err != nil {
		return nil, err
	}
	return url.Values{digestField: {string(digest)}, cipherField: {encrypted}, "_normalized_identifier": {normalized}}, nil
}

// EnsureAccountIdentifierAvailable prevents a canonical identifier still
// stored under a previous rotation key from being recreated under Current.
// The current-key database index remains the final concurrent-writer guard.
func EnsureAccountIdentifierAvailable(ctx context.Context, db *sql.DB, storage map[string]interface{}, role, value, excludeID string) error {
	return ensureAccountIdentifierAvailable(ctx, db, storage, role, role, role+"_id", value, excludeID)
}

func ensureAccountIdentifierAvailable(ctx context.Context, db *sql.DB, storage map[string]interface{}, role, table, idColumn, value, excludeID string) error {
	if db == nil {
		return fmt.Errorf("account database is unavailable")
	}
	if err := genelet.ValidateSQLIdentifier("account table", table); err != nil {
		return err
	}
	if err := genelet.ValidateSQLIdentifier("account id", idColumn); err != nil {
		return err
	}
	protector, enabled, err := accountProtector(storage)
	if err != nil || !enabled {
		return err
	}
	_, digestField, _, namespace, normalization, err := accountIdentifierContract(role)
	if err != nil {
		return err
	}
	digests, err := protector.LookupDigests(namespace, normalization, value)
	if err != nil {
		return err
	}
	query := `SELECT COUNT(*) FROM ` + table + ` WHERE ` + digestField + `=?`
	argsSuffix := make([]interface{}, 0, 1)
	if excludeID != "" {
		id, err := strconv.ParseUint(excludeID, 10, 32)
		if err != nil || id == 0 {
			return fmt.Errorf("invalid protected account ID")
		}
		query += ` AND ` + idColumn + `<>?`
		argsSuffix = append(argsSuffix, id)
	}
	if ctx == nil {
		ctx = context.Background()
	}
	for _, digest := range digests {
		args := append([]interface{}{digest}, argsSuffix...)
		var count int
		if err := db.QueryRowContext(ctx, query, args...).Scan(&count); err != nil {
			return err
		}
		if count != 0 {
			return genelet.Err(1075)
		}
	}
	return nil
}

// DecryptAccountIdentifier unwraps one protected identifier for an authorized
// application response. A disabled boundary returns the supplied legacy value.
func DecryptAccountIdentifier(storage map[string]interface{}, role, value string) (string, error) {
	protector, enabled, err := accountProtector(storage)
	if err != nil || !enabled {
		return value, err
	}
	_, _, _, namespace, _, err := accountIdentifierContract(role)
	if err != nil {
		return "", err
	}
	return protector.DecryptIdentifier(namespace, value)
}

// DecryptAccountRows replaces a ciphertext projection with the authorized
// plaintext display field and removes the ciphertext from the response.
func DecryptAccountRows(storage map[string]interface{}, role, cipherField, outputField string, rows []map[string]interface{}) error {
	protector, enabled, err := accountProtector(storage)
	if err != nil || !enabled {
		return err
	}
	_, _, _, namespace, _, err := accountIdentifierContract(role)
	if err != nil {
		return err
	}
	for _, row := range rows {
		raw, exists := row[cipherField]
		if !exists || raw == nil {
			return fmt.Errorf("protected %s projection is incomplete", role)
		}
		plain, err := protector.DecryptIdentifier(namespace, genelet.Interface2String(raw))
		if err != nil {
			return err
		}
		row[outputField] = plain
		delete(row, cipherField)
	}
	return nil
}

func mergeAccountExtra(extra []url.Values, protected url.Values) []url.Values {
	if protected == nil {
		return extra
	}
	if len(extra) == 0 {
		extra = []url.Values{make(url.Values)}
	} else if extra[0] == nil {
		extra[0] = make(url.Values)
	}
	for key, values := range protected {
		if key != "_normalized_identifier" {
			extra[0][key] = values
		}
	}
	return extra
}

// scrubProtectedAccountFields keeps storage-only digests and ciphertext out of
// JSON/template response rows. Authorized display paths expose only the
// decrypted identifier under its ordinary field name.
func scrubProtectedAccountFields(rows []map[string]interface{}, digestField, cipherField string) {
	for _, row := range rows {
		delete(row, digestField)
		delete(row, cipherField)
	}
}

// ScrubAccountProtectionInput removes storage-only fields supplied by a
// request. Protected model paths call it before adding server-derived values;
// legacy paths call it as well so disabled deployments cannot be poisoned
// ahead of a migration.
func ScrubAccountProtectionInput(values url.Values) {
	for _, field := range []string{
		"email_hmac", "email_cipher", "login_hmac", "login_cipher",
		"activation_token_digest", "activation_token_expires",
		"reset_token_digest", "reset_token_expires",
	} {
		values.Del(field)
	}
}

func (self *Model) protectedLookupValues(role, value string) ([][]byte, bool, error) {
	protector, enabled, err := accountProtector(self.Storage)
	if err != nil || !enabled {
		return nil, enabled, err
	}
	_, _, _, namespace, normalization, err := accountIdentifierContract(role)
	if err != nil {
		return nil, true, err
	}
	digests, err := protector.LookupDigests(namespace, normalization, value)
	return digests, true, err
}

func (self *Model) Dashboard(extra ...url.Values) error {
	return self.Topics(extra...)
}

func replaceProtectedField(fields []string, plaintext, cipher string) ([]string, bool) {
	out := append([]string(nil), fields...)
	replaced := false
	for index, field := range out {
		if field == plaintext {
			out[index] = cipher
			replaced = true
		}
	}
	return out, replaced
}

func removeField(fields []string, removed string) []string {
	out := make([]string, 0, len(fields))
	for _, field := range fields {
		if field != removed {
			out = append(out, field)
		}
	}
	return out
}

func replaceProtectedHash(fields map[string]string, plaintext, cipher, cipherOutput string) (map[string]string, bool) {
	out := make(map[string]string, len(fields))
	replaced := false
	for source, output := range fields {
		if source == plaintext {
			out[cipher] = cipherOutput
			replaced = true
			continue
		}
		out[source] = output
	}
	return out, replaced
}

func (self *Model) Topics(extra ...url.Values) error {
	field, _, cipherField, _, _, contractErr := accountIdentifierContract(self.CurrentTable)
	_, enabled, err := accountProtector(self.Storage)
	if err != nil {
		return err
	}
	if !enabled || contractErr != nil {
		return self.Model.Topics(extra...)
	}
	originalPars, originalHash := self.TopicsPars, self.TopicsHashpars
	originalSort := ""
	if self.SORTBY != "" {
		originalSort = self.ARGS.Get(self.SORTBY)
		if originalSort == field || originalSort == "p."+field {
			self.ARGS.Set(self.SORTBY, self.CurrentKey)
		}
	}
	originalRequestedFields := append([]string(nil), self.ARGS[self.FIELD]...)
	if self.FIELD != "" {
		for index, requested := range self.ARGS[self.FIELD] {
			if requested == field {
				self.ARGS[self.FIELD][index] = cipherField
			}
		}
	}
	selected := false
	if self.TopicsHashpars != nil {
		self.TopicsHashpars, selected = replaceProtectedHash(self.TopicsHashpars, "p."+field, "p."+cipherField, cipherField)
	} else {
		self.TopicsPars, selected = replaceProtectedField(self.TopicsPars, field, cipherField)
	}
	defer func() {
		self.TopicsPars, self.TopicsHashpars = originalPars, originalHash
		if self.SORTBY != "" {
			if originalSort == "" {
				self.ARGS.Del(self.SORTBY)
			} else {
				self.ARGS.Set(self.SORTBY, originalSort)
			}
		}
		if self.FIELD != "" {
			if originalRequestedFields == nil {
				self.ARGS.Del(self.FIELD)
			} else {
				self.ARGS[self.FIELD] = originalRequestedFields
			}
		}
	}()
	if err := self.Model.Topics(extra...); err != nil {
		return err
	}
	if selected {
		return DecryptAccountRows(self.Storage, self.CurrentTable, cipherField, field, *self.LISTS)
	}
	return nil
}

func (self *Model) Insert(extra ...url.Values) error {
	if !Grep(addressTables, self.CurrentTable) {
		return self.Model.Insert(extra...)
	}
	ScrubAccountProtectionInput(self.ARGS)
	var protected url.Values
	var err error
	if self.CurrentTable == "adv" || self.CurrentTable == "pub" {
		if err := EnsureAccountIdentifierAvailable(self.Context, self.DB, self.Storage, self.CurrentTable, self.ARGS.Get("email"), ""); err != nil {
			return err
		}
		protected, err = ProtectAccountIdentifier(self.Storage, self.CurrentTable, self.ARGS.Get("email"))
		if err != nil {
			return err
		}
	}
	if protected != nil {
		self.ARGS.Set("email", protected.Get("_normalized_identifier"))
		extra = mergeAccountExtra(extra, protected)
	}

	err = self.CallOnce(map[string]interface{}{"model": "address", "action": "insert"})
	if err != nil {
		return err
	}
	other := *self.OTHER
	data := other["address_insert"].([]map[string]interface{})
	extra[0].Set("address_id", data[0]["address_id"].(string))
	originalInsertPars := self.InsertPars
	retired, err := AccountPlaintextRetired(self.Storage)
	if err != nil {
		return err
	}
	if retired {
		self.InsertPars = removeField(self.InsertPars, "email")
		defer func() { self.InsertPars = originalInsertPars }()
	}
	err = self.Model.Insert(extra...)
	if err != nil {
		return err
	}
	if protected != nil {
		scrubProtectedAccountFields(*self.LISTS, "email_hmac", "email_cipher")
	}

	lists := *self.LISTS
	for _, field := range []string{"company", "street", "city", "state_id", "zip", "country_id", "contact", "contact_email", "phone", "fax", "url"} {
		lists[0][field] = data[0][field]
	}
	return nil
}

func (self *Model) Edit(extra ...url.Values) error {
	field, _, cipherField, _, _, contractErr := accountIdentifierContract(self.CurrentTable)
	_, enabled, protectionErr := accountProtector(self.Storage)
	if protectionErr != nil {
		return protectionErr
	}
	originalPars := self.EditPars
	selected := false
	if enabled && contractErr == nil {
		self.EditPars, selected = replaceProtectedField(self.EditPars, field, cipherField)
		defer func() { self.EditPars = originalPars }()
	}

	err := self.Model.Edit(extra...)
	if err != nil {
		return err
	}
	if enabled && contractErr == nil && selected {
		if err := DecryptAccountRows(self.Storage, self.CurrentTable, cipherField, field, *self.LISTS); err != nil {
			return err
		}
	}
	if !Grep(addressTables, self.CurrentTable) {
		return nil
	}
	lists := *self.LISTS
	return self.GetSQL(lists[0],
		"SELECT * FROM add_address WHERE address_id=?", lists[0]["address_id"])
}

func (self *Model) Update(extra ...url.Values) error {
	if !Grep(addressTables, self.CurrentTable) {
		return self.Model.Update(extra...)
	}
	if self.CurrentTable == "adv" || self.CurrentTable == "pub" {
		return self.UpdateProtectedAccount(self.CurrentTable, extra...)
	}
	return self.updateAccountAddress(extra...)
}

// UpdateProtectedAccount keeps an advertiser or publisher identifier pair in
// lockstep. Package-specific models pass their logical role when tests or
// adapters use a differently named table.
func (self *Model) UpdateProtectedAccount(role string, extra ...url.Values) error {
	if role != "adv" && role != "pub" {
		return fmt.Errorf("unsupported protected public account role %q", role)
	}
	ScrubAccountProtectionInput(self.ARGS)
	var protected url.Values
	if self.ARGS.Get("email") != "" {
		var err error
		if err := ensureAccountIdentifierAvailable(self.Context, self.DB, self.Storage, role, self.CurrentTable, self.CurrentKey, self.ARGS.Get("email"), self.ARGS.Get(self.CurrentKey)); err != nil {
			return err
		}
		protected, err = ProtectAccountIdentifier(self.Storage, role, self.ARGS.Get("email"))
		if err != nil {
			return err
		}
		if protected != nil {
			self.ARGS.Set("email", protected.Get("_normalized_identifier"))
			self.ARGS.Set("email_hmac", protected.Get("email_hmac"))
			self.ARGS.Set("email_cipher", protected.Get("email_cipher"))
			defer self.ARGS.Del("email_hmac")
			defer self.ARGS.Del("email_cipher")
			retired, err := AccountPlaintextRetired(self.Storage)
			if err != nil {
				return err
			}
			if retired {
				original := self.UpdatePars
				self.UpdatePars = removeField(self.UpdatePars, "email")
				defer func() { self.UpdatePars = original }()
			}
		}
	}
	if Grep(addressTables, self.CurrentTable) {
		if err := self.updateAccountAddressOnly(); err != nil {
			return err
		}
	}
	var err error
	if protected != nil {
		err = self.Model.UpdateWithNulls([]string{
			"activation_token_digest", "activation_token_expires",
			"reset_token_digest", "reset_token_expires",
		}, extra...)
	} else {
		err = self.Model.Update(extra...)
	}
	if err != nil {
		return err
	}
	if protected != nil {
		scrubProtectedAccountFields(*self.LISTS, "email_hmac", "email_cipher")
	}
	return nil
}

func (self *Model) updateAccountAddress(extra ...url.Values) error {
	ScrubAccountProtectionInput(self.ARGS)
	if err := self.updateAccountAddressOnly(); err != nil {
		return err
	}
	return self.Model.Update(extra...)
}

func (self *Model) updateAccountAddressOnly() error {
	hash := make(map[string]interface{})
	err := self.GetSQL(hash,
		`SELECT address_id FROM `+self.CurrentTable+` WHERE `+self.CurrentKey+`=?`,
		self.ARGS.Get(self.CurrentKey))
	if err == nil {
		self.ARGS.Set("address_id", strconv.FormatInt(hash["address_id"].(int64), 10))
		err = self.CallOnce(map[string]interface{}{"model": "address", "action": "update"})
	}
	if err != nil {
		return err
	}
	return nil
}

func (self *Model) Activate(extra ...url.Values) error {
	id := self.CurrentKey
	ARGS := self.ARGS

	enabled, err := ProtectedAccountActionsEnabled(self.Storage)
	if err != nil {
		return err
	}
	if enabled {
		if err := ConsumeAccountActivation(self.Context, self.DB, self.Storage, self.CurrentTable, ARGS.Get(id), ARGS.Get("action_token")); err != nil {
			return err
		}
		ARGS.Del("action_token")
		return nil
	}
	return self.DoSQL(`UPDATE `+self.CurrentTable+` SET active='Yes' WHERE `+id+`=? AND email=?`, ARGS.Get(id), ARGS.Get("email"))
}

func (self *Model) Retrieve(extra ...url.Values) error {
	id := self.CurrentKey
	digests, enabled, err := self.protectedLookupValues(self.CurrentTable, self.ARGS.Get("email"))
	if err != nil {
		return err
	}
	if !enabled {
		return self.SelectSQL(self.LISTS, `SELECT `+id+`, email, firstname, lastname FROM `+self.CurrentTable+`
WHERE email=? AND active IN ("New", "Yes")`, self.ARGS.Get("email"))
	}
	for _, digest := range digests {
		if err := self.SelectSQL(self.LISTS, `SELECT `+id+`, email_cipher, firstname, lastname FROM `+self.CurrentTable+`
WHERE email_hmac=? AND active IN ("New", "Yes")`, digest); err != nil {
			return err
		}
		if len(*self.LISTS) > 0 {
			protector, _, _ := accountProtector(self.Storage)
			plain, err := protector.DecryptIdentifier(self.CurrentTable+".email", genelet.Interface2String((*self.LISTS)[0]["email_cipher"]))
			if err != nil {
				return err
			}
			(*self.LISTS)[0]["email"] = plain
			delete((*self.LISTS)[0], "email_cipher")
			return nil
		}
	}
	return nil
}

func (self *Model) Resetpass(extra ...url.Values) error {
	id := self.CurrentKey
	ARGS := self.ARGS
	passwd, err := genelet.EnsurePasswordHash(ARGS.Get("passwd"))
	if err != nil {
		return err
	}

	enabled, err := ProtectedAccountActionsEnabled(self.Storage)
	if err != nil {
		return err
	}
	if enabled {
		if err := ConsumeAccountPasswordReset(self.Context, self.DB, self.Storage, self.CurrentTable, ARGS.Get(id), ARGS.Get("action_token"), passwd); err != nil {
			return err
		}
		ARGS.Del("action_token")
		return nil
	}
	return self.DoSQL(`UPDATE `+self.CurrentTable+` SET passwd=?, active='Yes' WHERE `+id+`=? AND email=?`, passwd, ARGS.Get(id), ARGS.Get("email"))
}

func (self *Model) Updatepass(extra ...url.Values) error {
	id := self.CurrentKey
	ARGS := self.ARGS
	if identity, _ := self.Storage["Identity"].(*genelet.IdentityService); identity != nil {
		ctx := self.Context
		if ctx == nil {
			ctx = context.Background()
		}
		return identity.ChangePassword(ctx, genelet.IdentityAccount{Role: ARGS.Get("_grole"), ID: ARGS.Get(id)}, ARGS.Get("passwd_old"), ARGS.Get("passwd"))
	}
	hash := make(map[string]interface{})
	if err := self.GetSQL(hash, `SELECT passwd FROM `+self.CurrentTable+` WHERE `+id+`=?`, ARGS.Get(id)); err != nil {
		return err
	}
	stored, ok := hash["passwd"]
	if !ok || stored == nil {
		return genelet.Err(1031)
	}
	if err := genelet.CheckPasswordHash(ARGS.Get("passwd_old"), genelet.Interface2String(stored)); err != nil {
		return genelet.Err(1031)
	}
	if err := genelet.ValidatePassword(ARGS.Get("passwd")); err != nil {
		return err
	}
	passwd, err := genelet.EnsurePasswordHash(ARGS.Get("passwd"))
	if err != nil {
		return err
	}
	return self.DoSQL(
		`UPDATE  `+self.CurrentTable+` SET passwd=?
WHERE `+id+`=?`,
		passwd, ARGS.Get(id))
}

func (self *Model) CleanupLogin(extra ...url.Values) error {
	digests, enabled, err := self.protectedLookupValues(self.CurrentTable, self.ARGS.Get("email"))
	if err != nil {
		return err
	}
	if enabled {
		for _, digest := range digests {
			if err := self.DoSQL(`DELETE FROM `+self.CurrentTable+`_ip
WHERE email_hmac=? AND ret='fail'
AND (UNIX_TIMESTAMP(updated) >= (UNIX_TIMESTAMP(NOW())-24*3600))`, digest); err != nil {
				return err
			}
		}
		return nil
	}
	return self.DoSQL(
		`DELETE FROM `+self.CurrentTable+`_ip
WHERE email=? AND ret='fail'
AND (UNIX_TIMESTAMP(updated) >= (UNIX_TIMESTAMP(NOW())-24*3600))`,
		self.ARGS.Get("email"))
}

func (self *Model) ChangeEmailAdmin(extra ...url.Values) error {
	id := self.CurrentKey
	ARGS := self.ARGS
	if err := EnsureAccountIdentifierAvailable(self.Context, self.DB, self.Storage, self.CurrentTable, ARGS.Get("email"), ARGS.Get(id)); err != nil {
		return err
	}
	protected, err := ProtectAccountIdentifier(self.Storage, self.CurrentTable, ARGS.Get("email"))
	if err != nil {
		return err
	}
	if protected != nil {
		digest := protected.Get("email_hmac")
		retired, err := AccountPlaintextRetired(self.Storage)
		if err != nil {
			return err
		}
		if retired {
			return self.DoSQL(`UPDATE `+self.CurrentTable+` SET email_hmac=?, email_cipher=?, activation_token_digest=NULL, activation_token_expires=NULL, reset_token_digest=NULL, reset_token_expires=NULL WHERE `+id+`=?`,
				digest, protected.Get("email_cipher"), ARGS.Get(id))
		}
		return self.DoSQL(`UPDATE `+self.CurrentTable+` SET email=?, email_hmac=?, email_cipher=?, activation_token_digest=NULL, activation_token_expires=NULL, reset_token_digest=NULL, reset_token_expires=NULL WHERE `+id+`=?`,
			protected.Get("_normalized_identifier"), digest, protected.Get("email_cipher"), ARGS.Get(id))
	}
	err = self.Existing(self.CurrentTable, "email", ARGS.Get("email"))
	if err != nil {
		return err
	}

	return self.DoSQL(
		`UPDATE `+self.CurrentTable+` SET email=? WHERE `+id+`=?`,
		ARGS.Get("email"), ARGS.Get(id))
}

func (self *Model) ChangePasswdAdmin(extra ...url.Values) error {
	table := self.CurrentTable
	id := self.CurrentKey
	ARGS := self.ARGS
	if err := genelet.ValidatePassword(ARGS.Get("passwd")); err != nil {
		return err
	}
	passwd, err := genelet.EnsurePasswordHash(ARGS.Get("passwd"))
	if err != nil {
		return err
	}

	return self.DoSQL(
		`UPDATE `+table+` SET passwd=? WHERE `+id+`=?`,
		passwd, ARGS.Get(id))
}
