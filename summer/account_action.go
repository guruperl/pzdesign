package summer

import (
	"context"
	"crypto/rand"
	"database/sql"
	"encoding/base64"
	"fmt"
	"io"
	"strconv"
	"time"

	"github.com/guruperl/genelet"
)

const (
	accountActivationTTL = 24 * time.Hour
	accountResetTTL      = time.Hour
)

type accountActionContract struct {
	table        string
	idColumn     string
	digestColumn string
	expiryColumn string
}

// ProtectedAccountActionsEnabled reports whether the current request must use
// opaque activation and reset proofs instead of identifier-bearing links.
func ProtectedAccountActionsEnabled(storage map[string]interface{}) (bool, error) {
	return AccountProtectionEnabled(storage)
}

func accountActionColumns(role, purpose string) (accountActionContract, error) {
	contract := accountActionContract{table: role, idColumn: role + "_id"}
	if role != "adv" && role != "pub" {
		return contract, fmt.Errorf("unsupported account-action role")
	}
	switch purpose {
	case "activate":
		contract.digestColumn = "activation_token_digest"
		contract.expiryColumn = "activation_token_expires"
	case "reset":
		contract.digestColumn = "reset_token_digest"
		contract.expiryColumn = "reset_token_expires"
	default:
		return contract, fmt.Errorf("unsupported account-action purpose")
	}
	return contract, nil
}

func accountActionTTL(purpose string) (time.Duration, error) {
	switch purpose {
	case "activate":
		return accountActivationTTL, nil
	case "reset":
		return accountResetTTL, nil
	default:
		return 0, fmt.Errorf("unsupported account-action purpose")
	}
}

func parseAccountActionID(raw string) (uint64, error) {
	id, err := strconv.ParseUint(raw, 10, 32)
	if err != nil || id == 0 {
		return 0, fmt.Errorf("invalid account-action account ID")
	}
	return id, nil
}

func accountActionContext(ctx context.Context) context.Context {
	if ctx == nil {
		return context.Background()
	}
	return ctx
}

// IssueAccountActionToken replaces any prior unused token for the same
// account and purpose. The random token is returned only to the mail path;
// MySQL stores its deployment-keyed digest.
func IssueAccountActionToken(ctx context.Context, db *sql.DB, storage map[string]interface{}, role, accountID, purpose, identifier string) (string, error) {
	if db == nil {
		return "", fmt.Errorf("account-action database is unavailable")
	}
	protector, enabled, err := accountProtector(storage)
	if err != nil {
		return "", err
	}
	if !enabled {
		return "", fmt.Errorf("account protection is disabled")
	}
	contract, err := accountActionColumns(role, purpose)
	if err != nil {
		return "", err
	}
	id, err := parseAccountActionID(accountID)
	if err != nil {
		return "", err
	}
	_, identifierDigestColumn, _, identifierNamespace, identifierNormalization, err := accountIdentifierContract(role)
	if err != nil {
		return "", err
	}
	identifierDigests, err := protector.LookupDigests(identifierNamespace, identifierNormalization, identifier)
	if err != nil {
		return "", err
	}
	ttl, err := accountActionTTL(purpose)
	if err != nil {
		return "", err
	}
	raw := make([]byte, 32)
	if _, err := io.ReadFull(rand.Reader, raw); err != nil {
		return "", fmt.Errorf("generate account-action token: %w", err)
	}
	token := base64.RawURLEncoding.EncodeToString(raw)
	digests, err := protector.AccountActionTokenDigests(role, purpose, token)
	if err != nil {
		return "", err
	}
	statePredicate := `active IN ('New','Yes')`
	if purpose == "activate" {
		statePredicate = `active='New'`
	}
	query := `UPDATE ` + contract.table + ` SET ` + contract.digestColumn + `=?, ` + contract.expiryColumn + `=? WHERE ` + contract.idColumn + `=? AND ` + identifierDigestColumn + `=? AND ` + statePredicate
	expires := time.Now().UTC().Add(ttl)
	for _, identifierDigest := range identifierDigests {
		result, err := db.ExecContext(accountActionContext(ctx), query, digests[0], expires, id, identifierDigest)
		if err != nil {
			return "", err
		}
		rows, err := result.RowsAffected()
		if err != nil {
			return "", err
		}
		if rows == 1 {
			return token, nil
		}
	}
	return "", fmt.Errorf("account-action target was not found")
}

// ValidateAccountActionToken validates a token without consuming it. It is
// used only to admit the reset form; the password update performs the
// authoritative one-use consume.
func ValidateAccountActionToken(ctx context.Context, db *sql.DB, storage map[string]interface{}, role, accountID, purpose, token string) error {
	if db == nil {
		return fmt.Errorf("account-action database is unavailable")
	}
	protector, enabled, err := accountProtector(storage)
	if err != nil {
		return err
	}
	if !enabled {
		return fmt.Errorf("account protection is disabled")
	}
	contract, err := accountActionColumns(role, purpose)
	if err != nil {
		return err
	}
	id, err := parseAccountActionID(accountID)
	if err != nil {
		return err
	}
	digests, err := protector.AccountActionTokenDigests(role, purpose, token)
	if err != nil {
		return err
	}
	query := `SELECT COUNT(*) FROM ` + contract.table + ` WHERE ` + contract.idColumn + `=? AND ` + contract.digestColumn + `=? AND ` + contract.expiryColumn + `>=?`
	for _, digest := range digests {
		var count int
		if err := db.QueryRowContext(accountActionContext(ctx), query, id, digest, time.Now().UTC()).Scan(&count); err != nil {
			return err
		}
		if count == 1 {
			return nil
		}
	}
	return genelet.Err(3102)
}

func consumeAccountAction(ctx context.Context, db *sql.DB, storage map[string]interface{}, role, accountID, purpose, token string, passwordHash string) error {
	if db == nil {
		return fmt.Errorf("account-action database is unavailable")
	}
	protector, enabled, err := accountProtector(storage)
	if err != nil {
		return err
	}
	if !enabled {
		return fmt.Errorf("account protection is disabled")
	}
	contract, err := accountActionColumns(role, purpose)
	if err != nil {
		return err
	}
	id, err := parseAccountActionID(accountID)
	if err != nil {
		return err
	}
	digests, err := protector.AccountActionTokenDigests(role, purpose, token)
	if err != nil {
		return err
	}
	set := `active='Yes', ` + contract.digestColumn + `=NULL, ` + contract.expiryColumn + `=NULL`
	statePredicate := `active IN ('New','Yes')`
	argsPrefix := make([]interface{}, 0, 1)
	if purpose == "reset" {
		if err := genelet.ValidatePasswordHash(passwordHash); err != nil {
			return err
		}
		set = `passwd=?, ` + set + `, activation_token_digest=NULL, activation_token_expires=NULL`
		argsPrefix = append(argsPrefix, passwordHash)
	} else {
		statePredicate = `active='New'`
	}
	query := `UPDATE ` + contract.table + ` SET ` + set + ` WHERE ` + contract.idColumn + `=? AND ` + contract.digestColumn + `=? AND ` + contract.expiryColumn + `>=? AND ` + statePredicate
	for _, digest := range digests {
		args := append(append([]interface{}{}, argsPrefix...), id, digest, time.Now().UTC())
		result, err := db.ExecContext(accountActionContext(ctx), query, args...)
		if err != nil {
			return err
		}
		rows, err := result.RowsAffected()
		if err != nil {
			return err
		}
		if rows == 1 {
			return nil
		}
	}
	return genelet.Err(3102)
}

func ConsumeAccountActivation(ctx context.Context, db *sql.DB, storage map[string]interface{}, role, accountID, token string) error {
	return consumeAccountAction(ctx, db, storage, role, accountID, "activate", token, "")
}

func ConsumeAccountPasswordReset(ctx context.Context, db *sql.DB, storage map[string]interface{}, role, accountID, token, passwordHash string) error {
	return consumeAccountAction(ctx, db, storage, role, accountID, "reset", token, passwordHash)
}
