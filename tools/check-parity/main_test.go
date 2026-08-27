package main

import (
	"os"
	"path/filepath"
	"testing"
)

func TestMissingEtwin(t *testing.T) {
	tmpdir := t.TempDir()

	gFile := filepath.Join(tmpdir, "tmpls", "role", "object", "example.g")
	os.MkdirAll(filepath.Dir(gFile), 0755)
	os.WriteFile(gFile, []byte("test"), 0644)

	exemptFile := filepath.Join(tmpdir, "exempt.txt")
	os.WriteFile(exemptFile, []byte(""), 0644)

	failures, err := check(tmpdir, exemptFile)
	if err != nil {
		t.Fatalf("check failed: %v", err)
	}
	if len(failures) == 0 {
		t.Errorf("expected missing twin failure, got none")
	}
	found := false
	for _, f := range failures {
		if contains(f, "tmpls/role/object/example.g") && contains(f, "missing") {
			found = true
			break
		}
	}
	if !found {
		t.Errorf("did not find expected missing twin error, got: %v", failures)
	}
}

func TestFormFieldMismatch(t *testing.T) {
	tmpdir := t.TempDir()
	testdir := filepath.Join(tmpdir, "tmpls", "role", "object")
	os.MkdirAll(testdir, 0755)

	gFile := filepath.Join(testdir, "example.g")
	eFile := filepath.Join(testdir, "example.e")

	os.WriteFile(gFile, []byte(`<form><input name="field1" /></form>`), 0644)
	os.WriteFile(eFile, []byte(`<form><input name="field2" /></form>`), 0644)

	exemptFile := filepath.Join(tmpdir, "exempt.txt")
	os.WriteFile(exemptFile, []byte(""), 0644)

	failures, err := check(tmpdir, exemptFile)
	if err != nil {
		t.Fatalf("check failed: %v", err)
	}
	found := false
	for _, f := range failures {
		if contains(f, "example.g") && contains(f, "form field names") {
			found = true
			break
		}
	}
	if !found {
		t.Errorf("did not find expected form field mismatch error, got: %v", failures)
	}
}

func TestExemptionSkipsMismatch(t *testing.T) {
	tmpdir := t.TempDir()
	testdir := filepath.Join(tmpdir, "tmpls", "role", "object")
	os.MkdirAll(testdir, 0755)

	gFile := filepath.Join(testdir, "example.g")
	eFile := filepath.Join(testdir, "example.e")

	os.WriteFile(gFile, []byte(`<form><input name="field1" /></form>`), 0644)
	os.WriteFile(eFile, []byte(`<form><input name="field2" /></form>`), 0644)

	exemptFile := filepath.Join(tmpdir, "exempt.txt")
	os.WriteFile(exemptFile, []byte("tmpls/role/object/example.g form-fields\n"), 0644)

	failures, err := check(tmpdir, exemptFile)
	if err != nil {
		t.Fatalf("check failed: %v", err)
	}
	for _, f := range failures {
		if contains(f, "tmpls/role/object/example.g") && contains(f, "form field names") {
			t.Errorf("exemption did not skip error: %s", f)
		}
	}
}

func TestSetsEqual(t *testing.T) {
	a := map[string]bool{"x": true, "y": true}
	b := map[string]bool{"y": true, "x": true}
	c := map[string]bool{"x": true, "z": true}

	if !setsEqual(a, b) {
		t.Errorf("sets with same elements should be equal")
	}
	if setsEqual(a, c) {
		t.Errorf("sets with different elements should not be equal")
	}
}

func contains(s, substr string) bool {
	return len(s) > 0 && len(substr) > 0 && (s[len(s)-len(substr):] == substr || s[:len(substr)] == substr || indexOf(s, substr) >= 0)
}

func indexOf(s, substr string) int {
	for i := 0; i <= len(s)-len(substr); i++ {
		if s[i:i+len(substr)] == substr {
			return i
		}
	}
	return -1
}
