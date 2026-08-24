package ledger

import (
	"database/sql"
	"fmt"
	"os"
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
	if !rows.Next() {
		t.Fatal("seeded experiment report returned no row")
	}
	columns, err := rows.Columns()
	if err != nil {
		t.Fatal(err)
	}
	if len(columns) != 22 {
		t.Fatalf("experiment report columns = %d, want 22", len(columns))
	}
	values := make([]interface{}, len(columns))
	pointers := make([]interface{}, len(columns))
	for index := range values {
		pointers[index] = &values[index]
	}
	if err := rows.Scan(pointers...); err != nil {
		t.Fatal(err)
	}
	if scannedText(values[13]) != "2" || scannedText(values[15]) != "1" || scannedText(values[18]) != "1.000000" {
		t.Fatalf("experiment aggregate variants=%s exposures=%s primary_value=%s", values[13], values[15], values[18])
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
			var spend, purchase string
			if err := row.Scan(&impressions, &clicks, &ctr, &actions, &cvr, &spend, &purchase, &roi, &roas); err != nil {
				t.Fatal(err)
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
			for _, required := range []string{"inventory_environment", "integration_mode", "refresh_seconds", "seller_type", "seller_id"} {
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
