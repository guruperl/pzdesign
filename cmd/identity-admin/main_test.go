package main

import (
	"strings"
	"testing"
)

func TestMaintenanceActorRequiresConfiguredUnixUIDBinding(t *testing.T) {
	actor, launcher, err := maintenanceActor(map[string]string{"1001": "42"}, 1001)
	if err != nil {
		t.Fatal(err)
	}
	if actor.Role != "admin" || actor.ID != "42" || launcher != "unix-uid:1001" {
		t.Fatalf("actor=%#v launcher=%q", actor, launcher)
	}
	for name, bindings := range map[string]map[string]string{
		"missing": {}, "zero": {"1001": "0"}, "nonnumeric": {"1001": "operator"},
	} {
		if _, _, err := maintenanceActor(bindings, 1001); err == nil {
			t.Errorf("%s binding accepted", name)
		}
	}
}

func TestMaintenanceReasonAuditsLauncherAndStaysBounded(t *testing.T) {
	reason, err := maintenanceReason("unix-uid:1001", "independent access review")
	if err != nil {
		t.Fatal(err)
	}
	if reason != "launcher=unix-uid:1001; independent access review" {
		t.Fatalf("reason=%q", reason)
	}
	for _, unsafe := range []string{"", "line one\nline two", strings.Repeat("x", 256)} {
		if _, err := maintenanceReason("unix-uid:1001", unsafe); err == nil {
			t.Errorf("unsafe reason accepted: %q", unsafe)
		}
	}
}
