package ledger

import (
	"database/sql"
	"fmt"
	"os"
	"strings"
	"testing"

	_ "github.com/go-sql-driver/mysql"
)

// TestMarketplaceExperimentSQLAgainstMySQL is an opt-in clean-room syntax and
// result test. Closeout supplies a disposable MySQL DSN; ordinary unit and CI
// runs do not need a database.
func TestMarketplaceExperimentSQLAgainstMySQL(t *testing.T) {
	dsn := os.Getenv("PZDESIGN_TEST_MYSQL_DSN")
	if dsn == "" {
		t.Skip("PZDESIGN_TEST_MYSQL_DSN is not set")
	}
	db, err := sql.Open("mysql", dsn)
	if err != nil {
		t.Fatal(err)
	}
	defer db.Close()
	rows, err := db.Query(marketplaceExperimentsSQL)
	if err != nil {
		t.Fatal(err)
	}
	defer rows.Close()
	columns, err := rows.Columns()
	if err != nil {
		t.Fatal(err)
	}
	if len(columns) != 21 {
		t.Fatalf("experiment report columns = %d, want 21", len(columns))
	}
	found := false
	for rows.Next() {
		values := make([]interface{}, len(columns))
		pointers := make([]interface{}, len(columns))
		for index := range values {
			pointers[index] = &values[index]
		}
		if err := rows.Scan(pointers...); err != nil {
			t.Fatal(err)
		}
		if scannedText(values[12]) == "2" && scannedText(values[14]) == "1" && strings.Contains(scannedText(values[17]), ".") {
			found = true
		}
	}
	if err := rows.Err(); err != nil {
		t.Fatal(err)
	}
	if !found {
		t.Fatal("seeded aggregate with two variants, one exposure, and a decimal primary value was not returned")
	}
	for name, query := range map[string]struct {
		sql  string
		args []interface{}
	}{
		"advertiser summary": {marketplaceAdvertiserSummarySQL, []interface{}{1, "2026-08-01", 1, "2026-08-01", 1, "2026-08-01", 1, "2026-08-01"}},
		"operator summary":   {marketplaceOperatorSummarySQL, []interface{}{"2026-08-01", 1, "2026-08-01", "2026-08-01", 1, "2026-08-01"}},
	} {
		t.Run(name, func(t *testing.T) {
			row := db.QueryRow(query.sql, query.args...)
			var impressions, clicks, actions uint64
			var ctr, cvr, roi, roas float64
			var versions, spend, purchase string
			if err := row.Scan(&versions, &impressions, &clicks, &ctr, &actions, &cvr, &spend, &purchase, &roi, &roas); err != nil {
				t.Fatal(err)
			}
			if versions == "" {
				t.Fatal("summary omitted accounting versions")
			}
		})
	}
	for name, query := range map[string]struct {
		sql  string
		args []interface{}
	}{
		"advertiser detail": {marketplaceAdvertiserSQL, []interface{}{1, "2026-08-01", 1, "2026-08-01", 20}},
		"publisher detail":  {marketplacePublisherSQL, []interface{}{2, "2026-08-01", 1, "2026-08-01", 20}},
		"operator detail":   {marketplaceOperatorSQL, []interface{}{"2026-08-01", 1, "2026-08-01", 20}},
	} {
		t.Run(name, func(t *testing.T) {
			rows, err := db.Query(query.sql, query.args...)
			if err != nil {
				t.Fatal(err)
			}
			defer rows.Close()
			columns, err := rows.Columns()
			if err != nil {
				t.Fatal(err)
			}
			for _, required := range []string{"accounting_version", "inventory_environment", "integration_mode", "refresh_seconds", "seller_type", "seller_id"} {
				if !containsColumn(columns, required) {
					t.Fatalf("columns do not include %s: %v", required, columns)
				}
			}
			if !rows.Next() {
				t.Fatal("seeded supply report returned no row")
			}
		})
	}
}

func containsColumn(columns []string, want string) bool {
	for _, column := range columns {
		if column == want {
			return true
		}
	}
	return false
}

func scannedText(value interface{}) string {
	if bytes, ok := value.([]byte); ok {
		return string(bytes)
	}
	return fmt.Sprint(value)
}
