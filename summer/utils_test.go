package summer

import (
	"testing"
	"time"
)

func TestDateDisplaysSupportSQLDriverValues(t *testing.T) {
	when := time.Date(2026, time.August, 1, 3, 45, 0, 0, time.UTC)
	tests := []struct {
		name     string
		value    interface{}
		date     string
		monthDay string
	}{
		{name: "time", value: when, date: "2026-08-01", monthDay: "08-01"},
		{name: "string", value: "2026-08-01 03:45:00", date: "2026-08-01", monthDay: "08-01"},
		{name: "bytes", value: []byte("2026-08-01 03:45:00"), date: "2026-08-01", monthDay: "08-01"},
		{name: "short value", value: "unknown", date: "unknown", monthDay: "unknown"},
		{name: "zero time", value: time.Time{}, date: "", monthDay: ""},
	}
	for _, test := range tests {
		t.Run(test.name, func(t *testing.T) {
			if got := DateDisplay(test.value); got != test.date {
				t.Errorf("DateDisplay() = %q, want %q", got, test.date)
			}
			if got := MonthDayDisplay(test.value); got != test.monthDay {
				t.Errorf("MonthDayDisplay() = %q, want %q", got, test.monthDay)
			}
		})
	}
}
