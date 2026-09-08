// Command account-data plans, backfills, verifies, or rotates S07 protected
// account identifiers. It never prints an identifier or key and defaults to a
// read-only status pass.
package main

import (
	"bytes"
	"context"
	"database/sql"
	"errors"
	"flag"
	"fmt"
	"os"
	"os/signal"
	"strings"
	"syscall"

	mysqlDriver "github.com/go-sql-driver/mysql"
	"github.com/guruperl/genelet"
)

type options struct {
	config string
	mode   string
	write  bool
	limit  int
}

type accountTable struct {
	name          string
	idColumn      string
	plainColumn   string
	digestColumn  string
	cipherColumn  string
	namespace     string
	normalization string
}

var accountTables = []accountTable{
	{"adv", "adv_id", "email", "email_hmac", "email_cipher", "adv.email", "email"},
	{"pub", "pub_id", "email", "email_hmac", "email_cipher", "pub.email", "email"},
	{"admin", "admin_id", "login", "login_hmac", "login_cipher", "admin.login", "login"},
	{"agent", "agent_id", "login", "login_hmac", "login_cipher", "agent.login", "login"},
	{"analyst", "analyst_id", "login", "login_hmac", "login_cipher", "analyst.login", "login"},
}

func main() {
	var opts options
	flag.StringVar(&opts.config, "config", os.Getenv("SUMMER"), "Genelet configuration path")
	flag.StringVar(&opts.mode, "mode", "status", "status, backfill, verify, or rotate")
	flag.BoolVar(&opts.write, "write", false, "allow backfill or rotation writes")
	flag.IntVar(&opts.limit, "limit", 1000, "maximum rows per table for a write run")
	flag.Parse()
	ctx, cancel := signal.NotifyContext(context.Background(), os.Interrupt, syscall.SIGTERM)
	defer cancel()
	if err := run(ctx, opts); err != nil {
		fmt.Fprintln(os.Stderr, "account-data:", err)
		os.Exit(1)
	}
}

func run(ctx context.Context, opts options) error {
	if strings.TrimSpace(opts.config) == "" {
		return fmt.Errorf("-config or SUMMER is required")
	}
	if opts.limit <= 0 || opts.limit > 100000 {
		return fmt.Errorf("-limit must be between 1 and 100000")
	}
	switch opts.mode {
	case "status", "verify":
		if opts.write {
			return fmt.Errorf("-write is not valid with %s", opts.mode)
		}
	case "backfill", "rotate":
		if !opts.write {
			return fmt.Errorf("%s requires explicit -write", opts.mode)
		}
	default:
		return fmt.Errorf("unsupported -mode %q", opts.mode)
	}
	config, err := genelet.NewConfig(opts.config)
	if err != nil {
		return err
	}
	protector, err := genelet.NewAccountProtector(config)
	if err != nil {
		return err
	}
	if protector == nil {
		return fmt.Errorf("AccountProtection.Enabled must be true")
	}
	if protector.PlaintextRetired() && opts.mode == "backfill" {
		return fmt.Errorf("backfill is unavailable after plaintext retirement")
	}
	db, err := config.OpenDB()
	if err != nil {
		return safeDatabaseError("open database", err)
	}
	defer db.Close()
	if err := db.PingContext(ctx); err != nil {
		return safeDatabaseError("ping", err)
	}
	if opts.mode == "backfill" {
		for _, table := range accountTables {
			if err := preflightBackfillTable(ctx, db, table); err != nil {
				return fmt.Errorf("%s: %w", table.name, err)
			}
		}
	}
	for _, table := range accountTables {
		var result tableResult
		switch opts.mode {
		case "status":
			result, err = statusTable(ctx, db, table)
			if err == nil && !protector.PlaintextRetired() {
				err = validatePlaintextTable(ctx, db, table)
			}
		case "verify":
			result, err = verifyTable(ctx, db, protector, table, opts.limit)
		case "backfill":
			result, err = writeTable(ctx, db, protector, table, opts.limit, false)
		case "rotate":
			result, err = writeTable(ctx, db, protector, table, opts.limit, true)
		}
		if err != nil {
			return fmt.Errorf("%s: %w", table.name, err)
		}
		fmt.Printf("table=%s total=%d pending=%d processed=%d\n", table.name, result.total, result.pending, result.processed)
	}
	return nil
}

type tableResult struct {
	total     int
	pending   int
	processed int
}

func statusTable(ctx context.Context, db *sql.DB, table accountTable) (tableResult, error) {
	query := fmt.Sprintf("SELECT COUNT(*), COALESCE(SUM(%s IS NULL OR %s IS NULL),0) FROM %s", table.digestColumn, table.cipherColumn, table.name)
	var result tableResult
	err := db.QueryRowContext(ctx, query).Scan(&result.total, &result.pending)
	if err != nil {
		return result, safeDatabaseError("status query", err)
	}
	return result, nil
}

func validatePlaintextTable(ctx context.Context, db *sql.DB, table accountTable) error {
	query := fmt.Sprintf("SELECT %s, %s FROM %s ORDER BY %s", table.idColumn, table.plainColumn, table.name, table.idColumn)
	rows, err := db.QueryContext(ctx, query)
	if err != nil {
		return safeDatabaseError("source validation query", err)
	}
	defer rows.Close()
	for rows.Next() {
		var id uint64
		var value string
		if err := rows.Scan(&id, &value); err != nil {
			return safeDatabaseError("source validation scan", err)
		}
		if _, err := genelet.NormalizeAccountIdentifier(table.normalization, value); err != nil {
			return fmt.Errorf("account id %d has an invalid source identifier", id)
		}
	}
	if err := rows.Err(); err != nil {
		return safeDatabaseError("source validation rows", err)
	}
	return nil
}

func partialProtectionCount(ctx context.Context, db *sql.DB, table accountTable) (int, error) {
	var partial int
	query := fmt.Sprintf("SELECT COUNT(*) FROM %s WHERE (%s IS NULL) <> (%s IS NULL)", table.name, table.digestColumn, table.cipherColumn)
	if err := db.QueryRowContext(ctx, query).Scan(&partial); err != nil {
		return 0, safeDatabaseError("partial-row query", err)
	}
	return partial, nil
}

func preflightBackfillTable(ctx context.Context, db *sql.DB, table accountTable) error {
	if err := validatePlaintextTable(ctx, db, table); err != nil {
		return err
	}
	partial, err := partialProtectionCount(ctx, db, table)
	if err != nil {
		return err
	}
	if partial != 0 {
		return fmt.Errorf("refusing to overwrite %d partially protected rows", partial)
	}
	return nil
}

func verifyTable(ctx context.Context, db *sql.DB, protector *genelet.AccountProtector, table accountTable, limit int) (tableResult, error) {
	result, err := statusTable(ctx, db, table)
	if err != nil {
		return result, err
	}
	columns := table.idColumn + ", " + table.digestColumn + ", " + table.cipherColumn
	if !protector.PlaintextRetired() {
		columns = table.idColumn + ", " + table.plainColumn + ", " + table.digestColumn + ", " + table.cipherColumn
	}
	query := fmt.Sprintf("SELECT %s FROM %s ORDER BY %s LIMIT ?", columns, table.name, table.idColumn)
	rows, err := db.QueryContext(ctx, query, limit)
	if err != nil {
		return result, safeDatabaseError("verification query", err)
	}
	defer rows.Close()
	for rows.Next() {
		var id uint64
		var legacyPlain string
		var storedDigest, cipherText []byte
		scanTargets := []interface{}{&id, &storedDigest, &cipherText}
		if !protector.PlaintextRetired() {
			scanTargets = []interface{}{&id, &legacyPlain, &storedDigest, &cipherText}
		}
		if err := rows.Scan(scanTargets...); err != nil {
			return result, safeDatabaseError("verification scan", err)
		}
		if len(storedDigest) != sha256Size || len(cipherText) == 0 {
			return result, fmt.Errorf("account id %d is not fully protected", id)
		}
		plain, err := protector.DecryptIdentifier(table.namespace, string(cipherText))
		if err != nil {
			return result, fmt.Errorf("account id %d has invalid ciphertext: %w", id, err)
		}
		digests, err := protector.LookupDigests(table.namespace, table.normalization, plain)
		if err != nil || !bytes.Equal(storedDigest, digests[0]) {
			return result, fmt.Errorf("account id %d does not use the current lookup key", id)
		}
		if !protector.PlaintextRetired() {
			normalizedLegacy, err := genelet.NormalizeAccountIdentifier(table.normalization, legacyPlain)
			if err != nil || normalizedLegacy != plain {
				return result, fmt.Errorf("account id %d does not match its rollback identifier", id)
			}
		}
		result.processed++
	}
	if err := rows.Err(); err != nil {
		return result, safeDatabaseError("verification rows", err)
	}
	if result.processed != result.total {
		return result, fmt.Errorf("verified %d of %d rows; raise -limit before treating parity as complete", result.processed, result.total)
	}
	return result, nil
}

const sha256Size = 32

func writeTable(ctx context.Context, db *sql.DB, protector *genelet.AccountProtector, table accountTable, limit int, rotate bool) (tableResult, error) {
	result, err := statusTable(ctx, db, table)
	if err != nil {
		return result, err
	}
	where := table.digestColumn + " IS NULL AND " + table.cipherColumn + " IS NULL"
	columns := table.idColumn + ", " + table.plainColumn
	queryArgs := make([]interface{}, 0, 3)
	if rotate {
		prefix, err := protector.CurrentCiphertextPrefix()
		if err != nil {
			return result, err
		}
		where = table.digestColumn + " IS NOT NULL AND " + table.cipherColumn + " IS NOT NULL AND LEFT(" + table.cipherColumn + ", ?)<>?"
		columns = table.idColumn + ", " + table.digestColumn + ", " + table.cipherColumn
		queryArgs = append(queryArgs, len(prefix), prefix)
	} else {
		partial, err := partialProtectionCount(ctx, db, table)
		if err != nil {
			return result, err
		}
		if partial != 0 {
			return result, fmt.Errorf("refusing to overwrite %d partially protected rows", partial)
		}
	}
	query := fmt.Sprintf("SELECT %s FROM %s WHERE %s ORDER BY %s LIMIT ?", columns, table.name, where, table.idColumn)
	queryArgs = append(queryArgs, limit)
	rows, err := db.QueryContext(ctx, query, queryArgs...)
	if err != nil {
		return result, safeDatabaseError("write selection", err)
	}
	type pendingRow struct {
		id     uint64
		digest []byte
		value  string
	}
	pending := make([]pendingRow, 0)
	for rows.Next() {
		var row pendingRow
		var scanErr error
		if rotate {
			scanErr = rows.Scan(&row.id, &row.digest, &row.value)
		} else {
			scanErr = rows.Scan(&row.id, &row.value)
		}
		if scanErr != nil {
			rows.Close()
			return result, safeDatabaseError("write selection scan", scanErr)
		}
		pending = append(pending, row)
	}
	if err := rows.Close(); err != nil {
		return result, safeDatabaseError("write selection close", err)
	}
	if err := rows.Err(); err != nil {
		return result, safeDatabaseError("write selection rows", err)
	}
	tx, err := db.BeginTx(ctx, nil)
	if err != nil {
		return result, safeDatabaseError("begin write transaction", err)
	}
	defer tx.Rollback()
	for _, row := range pending {
		plain := row.value
		if rotate {
			plain, err = protector.DecryptIdentifier(table.namespace, row.value)
			if err != nil {
				return result, fmt.Errorf("account id %d has invalid ciphertext: %w", row.id, err)
			}
			matches, err := lookupDigestMatches(protector, table, plain, row.digest)
			if err != nil {
				return result, fmt.Errorf("account id %d has an invalid protected identifier", row.id)
			}
			if !matches {
				return result, fmt.Errorf("account id %d has inconsistent protected provenance", row.id)
			}
		}
		digest, encrypted, err := protector.ProtectIdentifier(table.namespace, table.normalization, plain)
		if err != nil {
			return result, fmt.Errorf("account id %d cannot be protected: %w", row.id, err)
		}
		updateWhere := where
		updateArgs := []interface{}{digest, encrypted, row.id}
		if rotate {
			updateWhere = table.digestColumn + "=? AND " + table.cipherColumn + "=?"
			updateArgs = append(updateArgs, row.digest, row.value)
		} else {
			updateWhere += " AND " + table.plainColumn + "=?"
			updateArgs = append(updateArgs, row.value)
		}
		update := fmt.Sprintf("UPDATE %s SET %s=?, %s=? WHERE %s=? AND %s", table.name, table.digestColumn, table.cipherColumn, table.idColumn, updateWhere)
		mutation, err := tx.ExecContext(ctx, update, updateArgs...)
		if err != nil {
			return result, safeDatabaseError("protected account update", err)
		}
		affected, err := mutation.RowsAffected()
		if err != nil {
			return result, safeDatabaseError("protected account update result", err)
		}
		if affected != 1 {
			return result, fmt.Errorf("account id %d changed concurrently", row.id)
		}
		result.processed++
	}
	if err := tx.Commit(); err != nil {
		return result, safeDatabaseError("commit write transaction", err)
	}
	return result, nil
}

func lookupDigestMatches(protector *genelet.AccountProtector, table accountTable, plain string, stored []byte) (bool, error) {
	digests, err := protector.LookupDigests(table.namespace, table.normalization, plain)
	if err != nil {
		return false, err
	}
	for _, digest := range digests {
		if bytes.Equal(stored, digest) {
			return true, nil
		}
	}
	return false, nil
}

func safeDatabaseError(operation string, err error) error {
	var mysqlErr *mysqlDriver.MySQLError
	if errors.As(err, &mysqlErr) {
		return fmt.Errorf("%s failed (mysql code %d)", operation, mysqlErr.Number)
	}
	return fmt.Errorf("%s failed", operation)
}
