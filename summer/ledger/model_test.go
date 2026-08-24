package ledger

import (
	"net/url"
	"strings"
	"testing"
	"time"
)

func TestIsAdvertiserMiddlemanReportRequiresAdvertiserRoleArgs(t *testing.T) {
	tests := []struct {
		name string
		args url.Values
		want bool
	}{
		{
			name: "advertiser",
			args: url.Values{"_grole": {"adv"}, "adv_id": {"7"}},
			want: true,
		},
		{
			name: "admin with adv filter",
			args: url.Values{"_grole": {"admin"}, "admin_id": {"1"}, "adv_id": {"7"}},
			want: false,
		},
		{
			name: "admin",
			args: url.Values{"_grole": {"admin"}, "admin_id": {"1"}},
			want: false,
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			model := &Model{}
			model.ARGS = tt.args
			if got := model.isAdvertiserMiddlemanReport(); got != tt.want {
				t.Fatalf("isAdvertiserMiddlemanReport() = %v, want %v", got, tt.want)
			}
		})
	}
}

func TestValidateReportWindowUsesBoundedUTCInputs(t *testing.T) {
	now := time.Date(2026, 8, 1, 12, 0, 0, 0, time.UTC)
	args := url.Values{"day": {"2026-07-31"}, "idays": {"30"}, "top": {"100"}}
	if err := validateReportWindow(args, now); err != nil {
		t.Fatal(err)
	}
	for name, values := range map[string]url.Values{
		"future":   {"day": {"2026-08-02"}, "idays": {"0"}, "top": {"1"}},
		"lookback": {"day": {"2026-08-01"}, "idays": {"91"}, "top": {"1"}},
		"limit":    {"day": {"2026-08-01"}, "idays": {"0"}, "top": {"201"}},
	} {
		t.Run(name, func(t *testing.T) {
			if err := validateReportWindow(values, now); err == nil {
				t.Fatal("invalid report window was accepted")
			}
		})
	}
}

func TestMarketplaceSQLAlwaysContainsAccountScope(t *testing.T) {
	for name, test := range map[string]struct {
		query string
		want  string
	}{
		"advertiser": {marketplaceAdvertiserSQL, "WHERE r.adv_id=?"},
		"publisher":  {marketplacePublisherSQL, "WHERE r.pub_id=?"},
	} {
		t.Run(name, func(t *testing.T) {
			if !strings.Contains(test.query, test.want) {
				t.Fatalf("marketplace query is missing %q", test.want)
			}
		})
	}
}

func TestMarketplaceSummarySQLPreservesAccountScopeAndRatios(t *testing.T) {
	for _, required := range []string{
		"WHERE adv_id=?", "actions/NULLIF(d.clicks,0)",
		"(a.purchase_value_usd-d.spend_usd)/NULLIF(d.spend_usd,0)",
		"a.purchase_value_usd/NULLIF(d.spend_usd,0)",
	} {
		if !strings.Contains(marketplaceAdvertiserSummarySQL, required) {
			t.Errorf("advertiser summary is missing %q", required)
		}
	}
	if strings.Contains(marketplaceAdvertiserSummarySQL, "DATE(timely)") {
		t.Fatal("advertiser summary disables the scoped timely index")
	}
}

func TestMarketplaceExperimentExportIsAggregateAndPrivacySafe(t *testing.T) {
	for _, forbidden := range []string{"assignment_salt", "subject_hash", "idempotency_key", "stop_reason", "audit.reason"} {
		if strings.Contains(marketplaceExperimentsSQL, forbidden) {
			t.Errorf("experiment export selects sensitive field %q", forbidden)
		}
	}
	for _, required := range []string{
		"COUNT(DISTINCT x.exposure_id)",
		"COUNT(DISTINCT CASE WHEN o.metric_name=e2.primary_metric THEN o.outcome_id END)",
		"COUNT(DISTINCT CASE WHEN o.metric_name=e2.guardrail_metric THEN o.outcome_id END)",
	} {
		if !strings.Contains(marketplaceExperimentsSQL, required) {
			t.Errorf("experiment export is missing aggregate %q", required)
		}
	}
}

func TestMarketplaceFreshnessQueryScopesEveryAccountSubquery(t *testing.T) {
	for name, test := range map[string]struct {
		args       url.Values
		whereCount int
		parameters int
	}{
		"advertiser": {url.Values{"_grole": {"adv"}, "adv_id": {"7"}}, 5, 5},
		"publisher":  {url.Values{"_grole": {"pub"}, "pub_id": {"9"}}, 3, 3},
		"operator":   {url.Values{"_grole": {"admin"}, "admin_id": {"1"}}, 0, 0},
	} {
		t.Run(name, func(t *testing.T) {
			query, parameters, err := marketplaceFreshnessQuery(test.args)
			if err != nil {
				t.Fatal(err)
			}
			if got := strings.Count(query, "WHERE adv_id=?") + strings.Count(query, "WHERE pub_id=?"); got != test.whereCount {
				t.Fatalf("scoped subqueries = %d, want %d\n%s", got, test.whereCount, query)
			}
			if len(parameters) != test.parameters {
				t.Fatalf("parameters = %d, want %d", len(parameters), test.parameters)
			}
		})
	}
}

func TestMarketplaceScopeUsesAuthenticatedRoleNotInjectedIdentifiers(t *testing.T) {
	args := url.Values{
		"_grole": {"adv"}, "adv_id": {"7"}, "admin_id": {"1"}, "pub_id": {"9"},
	}
	role, column, value, err := marketplaceScope(args)
	if err != nil {
		t.Fatal(err)
	}
	if role != "adv" || column != "adv_id" || value != "7" {
		t.Fatalf("scope = %q %q %q", role, column, value)
	}
	if _, _, _, err := marketplaceScope(url.Values{"adv_id": {"7"}, "admin_id": {"1"}}); err == nil {
		t.Fatal("request identifiers without an authenticated role were accepted")
	}
}
