package summer

import (
	"net/url"
	"strings"
	"testing"
)

func TestApplyDeliveryFormCampaign(t *testing.T) {
	args := url.Values{
		"delivery_timezone":       {"Asia/Shanghai"},
		"pacing_mode":             {"Even"},
		"weekly_schedule_enabled": {"1"},
		"weekly_hour":             {"0", "167"},
		"startx":                  {"2026-08-01 00:00:00"},
		"endx":                    {"2026-08-02 00:00:00"},
	}
	if err := ApplyDeliveryForm(args, true); err != nil {
		t.Fatal(err)
	}
	if got := args.Get("delivery_timezone"); got != "Asia/Shanghai" {
		t.Fatalf("delivery_timezone = %q", got)
	}
	if got := args.Get("weekly_schedule"); len(got) != deliveryHoursPerWeek || got[0] != '1' || got[167] != '1' || strings.Count(got, "1") != 2 {
		t.Fatalf("weekly_schedule = %q", got)
	}
	if args.Has("weekly_hour") || args.Has("weekly_schedule_enabled") {
		t.Fatalf("form-only delivery fields were not removed: %#v", args)
	}
}

func TestApplyDeliveryFormDefaultsAndValidation(t *testing.T) {
	args := url.Values{}
	if err := ApplyDeliveryForm(args, true); err != nil {
		t.Fatal(err)
	}
	if args.Get("delivery_timezone") != "UTC" || args.Get("pacing_mode") != "Fast" || args.Get("weekly_schedule") != "" {
		t.Fatalf("unexpected defaults: %#v", args)
	}

	for name, bad := range map[string]url.Values{
		"timezone": {"delivery_timezone": {"Not/AZone"}},
		"pacing":   {"pacing_mode": {"Adaptive"}},
		"hour":     {"weekly_schedule_enabled": {"1"}, "weekly_hour": {"168"}},
		"no hours": {"weekly_schedule_enabled": {"1"}},
		"range":    {"startx": {"2026-08-02"}, "endx": {"2026-08-01"}},
	} {
		t.Run(name, func(t *testing.T) {
			if err := ApplyDeliveryForm(bad, true); err == nil {
				t.Fatalf("ApplyDeliveryForm(%#v) succeeded", bad)
			}
		})
	}
}

func TestDeliveryScheduleRows(t *testing.T) {
	schedule := strings.Repeat("0", deliveryHoursPerWeek)
	schedule = "1" + schedule[1:167] + "1"
	rows := DeliveryScheduleRows(schedule, true)
	if len(rows) != 7 || len(rows[0].Hours) != 24 {
		t.Fatalf("schedule dimensions = %d x %d", len(rows), len(rows[0].Hours))
	}
	if rows[0].Label != "星期一" || !rows[0].Hours[0].Selected || !rows[6].Hours[23].Selected || rows[0].Hours[1].Selected {
		t.Fatalf("unexpected schedule rows: %#v %#v", rows[0], rows[6])
	}
}

func TestValidateBalanceLimits(t *testing.T) {
	if err := ValidateBalanceLimits(url.Values{"limit_spend": {"1.25"}, "daily_imp": {"10"}}); err != nil {
		t.Fatal(err)
	}
	for _, args := range []url.Values{
		{"limit_spend": {"-1"}},
		{"limit_spend": {"NaN"}},
		{"limit_spend": {"+Inf"}},
		{"daily_cli": {"1.5"}},
	} {
		if err := ValidateBalanceLimits(args); err == nil {
			t.Fatalf("ValidateBalanceLimits(%#v) succeeded", args)
		}
	}
}
