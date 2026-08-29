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

func TestMissingRoleFragmentTwin(t *testing.T) {
	tmpdir := t.TempDir()

	gFile := filepath.Join(tmpdir, "tmpls", "role", "header.g")
	if err := os.MkdirAll(filepath.Dir(gFile), 0755); err != nil {
		t.Fatal(err)
	}
	if err := os.WriteFile(gFile, []byte("header"), 0644); err != nil {
		t.Fatal(err)
	}
	exemptFile := filepath.Join(tmpdir, "exempt.txt")
	if err := os.WriteFile(exemptFile, nil, 0644); err != nil {
		t.Fatal(err)
	}

	failures, err := check(tmpdir, exemptFile)
	if err != nil {
		t.Fatalf("check failed: %v", err)
	}
	if len(failures) != 1 || !contains(failures[0], "tmpls/role/header.g") {
		t.Fatalf("role-fragment failures = %v", failures)
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

func TestHiddenActionMismatch(t *testing.T) {
	tmpdir := t.TempDir()
	testdir := filepath.Join(tmpdir, "tmpls", "role", "object")
	if err := os.MkdirAll(testdir, 0755); err != nil {
		t.Fatal(err)
	}

	gFile := filepath.Join(testdir, "example.g")
	eFile := filepath.Join(testdir, "example.e")
	if err := os.WriteFile(gFile, []byte(`<form><input value=insert type=hidden name=action><input name=company></form>`), 0644); err != nil {
		t.Fatal(err)
	}
	if err := os.WriteFile(eFile, []byte(`<form><input name="action" type="hidden" value="update"><input name="company"></form>`), 0644); err != nil {
		t.Fatal(err)
	}

	exemptFile := filepath.Join(tmpdir, "exempt.txt")
	if err := os.WriteFile(exemptFile, nil, 0644); err != nil {
		t.Fatal(err)
	}

	failures, err := check(tmpdir, exemptFile)
	if err != nil {
		t.Fatalf("check failed: %v", err)
	}
	found := false
	for _, failure := range failures {
		if contains(failure, "hidden action values") {
			found = true
		}
	}
	if !found {
		t.Fatalf("hidden action mismatch failures = %v", failures)
	}
}

func TestStructureAllowsTranslatedCopyAndEditionRoutes(t *testing.T) {
	g := `<html lang="zh"><head><meta name="keyword" content="广告"></head><body><a href="/goto/adv/g/campaign" aria-label="广告活动"><span class="name">广告活动</span></a><a class="lang-toggle" data-chartag-toggle="e">English</a>{{if .Error}}错误{{end}}</body></html>`
	e := `<html lang="en"><head><meta content="advertising" name="keyword"></head><body><a aria-label="Campaign" href="/goto/adv/e/campaign"><span class="name">Campaign</span></a><a class="lang-toggle" data-chartag-toggle="g">中文</a>{{ if .Error }}Error{{ end }}</body></html>`
	gStructure, err := extractStructure(g)
	if err != nil {
		t.Fatal(err)
	}
	eStructure, err := extractStructure(e)
	if err != nil {
		t.Fatal(err)
	}
	if !slicesEqual(gStructure, eStructure) {
		t.Fatalf("translated structures differ:\n%v\n%v", gStructure, eStructure)
	}
}

func TestStructureRejectsLegacyLayout(t *testing.T) {
	gStructure, err := extractStructure(`<main><section class="account"><form method="post"><input name="email"></form></section></main>`)
	if err != nil {
		t.Fatal(err)
	}
	eStructure, err := extractStructure(`<div class="legacy"><form method="post"><input name="email"></form></div>`)
	if err != nil {
		t.Fatal(err)
	}
	if slicesEqual(gStructure, eStructure) {
		t.Fatal("different page layouts were accepted")
	}
}

func TestFormContractsIgnoreAttributeQuotingAndOrder(t *testing.T) {
	gNames, gActions, err := extractFormContracts(`<input value=insert type=hidden name=action><input required name=company>`)
	if err != nil {
		t.Fatal(err)
	}
	eNames, eActions, err := extractFormContracts(`<input name="company" required><input name="action" type="hidden" value="insert">`)
	if err != nil {
		t.Fatal(err)
	}
	if !setsEqual(gNames, eNames) || !setsEqual(gActions, eActions) {
		t.Fatalf("equivalent form contracts differ: names=%v/%v actions=%v/%v", gNames, eNames, gActions, eActions)
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

func TestStaleExemptionFails(t *testing.T) {
	tmpdir := t.TempDir()
	testdir := filepath.Join(tmpdir, "tmpls", "role", "object")
	if err := os.MkdirAll(testdir, 0755); err != nil {
		t.Fatal(err)
	}

	for _, extension := range []string{"g", "e"} {
		path := filepath.Join(testdir, "example."+extension)
		if err := os.WriteFile(path, []byte(`<p>copy</p>`), 0644); err != nil {
			t.Fatal(err)
		}
	}
	exemptFile := filepath.Join(tmpdir, "exempt.txt")
	if err := os.WriteFile(exemptFile, []byte("tmpls/role/object/example.g structure\n"), 0644); err != nil {
		t.Fatal(err)
	}

	failures, err := check(tmpdir, exemptFile)
	if err != nil {
		t.Fatalf("check failed: %v", err)
	}
	found := false
	for _, failure := range failures {
		if contains(failure, "stale parity exemption") {
			found = true
		}
	}
	if !found {
		t.Fatalf("stale exemption failures = %v", failures)
	}
}

func TestEnglishCopyRejectsHanOutsideLanguageToggle(t *testing.T) {
	for _, test := range []struct {
		name string
		text string
		want bool
	}{
		{name: "English copy", text: `<p>Account</p>`},
		{name: "Chinese remnant", text: `<p>账户</p>`, want: true},
		{name: "Chinese attribute remnant", text: `<input placeholder="账户">`, want: true},
		{name: "Chinese language toggle", text: `<a class="lang-toggle" data-chartag-toggle="g" title="中文">中文</a>`},
		{name: "Unmarked Chinese chartag link", text: `<a data-chartag-toggle="g" title="中文">中文</a>`, want: true},
	} {
		t.Run(test.name, func(t *testing.T) {
			got, err := containsUnexpectedHan(test.text)
			if err != nil {
				t.Fatal(err)
			}
			if got != test.want {
				t.Fatalf("containsUnexpectedHan() = %t, want %t", got, test.want)
			}
		})
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
