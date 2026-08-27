package main

import (
	"os"
	"path/filepath"
	"strings"
	"testing"
)

func TestCheckEditionLinks(t *testing.T) {
	t.Parallel()
	tests := []struct {
		name     string
		language string
		html     string
		wantFail bool
	}{
		{name: "Chinese own edition", language: "zh", html: `<a href="/goto/web/g/adv?action=startnew">register</a>`},
		{name: "English own edition", language: "en", html: `<a href='/goto/pub/e/site?action=topics'>login</a>`},
		{name: "Chinese bare English link", language: "zh", html: `<a href='/goto/web/e/adv?action=startnew'>register</a>`, wantFail: true},
		{name: "English bare Chinese link", language: "en", html: `<a href="/goto/pub/g/site?action=topics">login</a>`, wantFail: true},
		{name: "Exact toggle class", language: "en", html: `<a class="nav-link lang-toggle" href="/goto/web/g/">中文</a>`},
		{name: "Toggle data attribute", language: "zh", html: `<a href="/goto/web/e/" data-lang-toggle="en">English</a>`},
		{name: "Wrong toggle data attribute", language: "zh", html: `<a href="/goto/web/e/" data-lang-toggle="zh">English</a>`, wantFail: true},
		{name: "Substring class is not toggle", language: "zh", html: `<a class="not-lang-toggle-link" href="/goto/web/e/">English</a>`, wantFail: true},
		{name: "Alternate link", language: "zh", html: `<link href="/goto/web/e/" hreflang="en" rel="stylesheet alternate">`},
		{name: "Stylesheet is not alternate", language: "zh", html: `<link href="/goto/web/e/" rel="stylesheet">`, wantFail: true},
	}
	for _, test := range tests {
		test := test
		t.Run(test.name, func(t *testing.T) {
			t.Parallel()
			failures, err := checkEditionLinks("fixture.html", test.language, test.html)
			if err != nil {
				t.Fatal(err)
			}
			if got := len(failures) > 0; got != test.wantFail {
				t.Fatalf("failures = %v, want failure %t", failures, test.wantFail)
			}
		})
	}
}

func TestCheckCopyAppliesEditionRulesAndRawErrorRule(t *testing.T) {
	t.Parallel()
	tests := []struct {
		name     string
		language string
		text     string
		want     string
	}{
		{name: "English template Chinese remnant", language: "en", text: "继续管理你的账户", want: "继续管理你的"},
		{name: "Chinese template English remnant", language: "zh", text: "Advertiser Workspace", want: "Advertiser Workspace"},
		{name: "English copy is valid English", language: "en", text: "Advertiser Workspace"},
		{name: "Whitespace cannot hide raw error", language: "en", text: "{{ \n .Errstr \t }}", want: "raw framework error"},
		{name: "Pipeline cannot hide raw error", language: "en", text: "{{ .Errorstr | printf \"%s\" }}", want: "raw framework error"},
		{name: "Error condition is not rendering", language: "en", text: "{{if .Errorstr}}fixed message{{end}}"},
	}
	for _, test := range tests {
		test := test
		t.Run(test.name, func(t *testing.T) {
			t.Parallel()
			failures, err := checkCopy("fixture.e", test.language, test.text)
			if err != nil {
				t.Fatal(err)
			}
			joined := strings.Join(failures, "\n")
			if test.want == "" && joined != "" {
				t.Fatalf("unexpected failures: %s", joined)
			}
			if test.want != "" && !strings.Contains(joined, test.want) {
				t.Fatalf("failures %q do not contain %q", joined, test.want)
			}
		})
	}
}

func TestPublicFilesIncludesBothTemplateEditions(t *testing.T) {
	t.Parallel()
	root := t.TempDir()
	for _, rel := range []string{
		"tmpls/web/example.g",
		"tmpls/web/example.e",
	} {
		path := filepath.Join(root, filepath.FromSlash(rel))
		if err := os.MkdirAll(filepath.Dir(path), 0o755); err != nil {
			t.Fatal(err)
		}
		if err := os.WriteFile(path, []byte("fixture"), 0o600); err != nil {
			t.Fatal(err)
		}
	}
	files, err := publicFiles(root)
	if err != nil {
		t.Fatal(err)
	}
	want := map[string]bool{"zh": false, "en": false}
	for _, file := range files {
		if strings.Contains(file.path, "example.") {
			want[file.language] = true
		}
	}
	if !want["zh"] || !want["en"] {
		t.Fatalf("template editions found = %#v, want both", want)
	}
}

func TestHasAlternateLinkRequiresExactMetadata(t *testing.T) {
	t.Parallel()
	if !hasAlternateLink(`<link href="/index.en.html" hreflang="en" rel="alternate">`, "index.en.html", "en") {
		t.Fatal("valid alternate link was not recognized")
	}
	for _, text := range []string{
		`<a href="/index.en.html" hreflang="en" rel="alternate">English</a>`,
		`<link href="/index.en.html" hreflang="fr" rel="alternate">`,
		`<link href="/other.en.html" hreflang="en" rel="alternate">`,
		`<link href="/evilindex.en.html" hreflang="en" rel="alternate">`,
		`<link href="/index.en.html" hreflang="en" rel="stylesheet">`,
	} {
		if hasAlternateLink(text, "index.en.html", "en") {
			t.Fatalf("invalid alternate link was accepted: %s", text)
		}
	}
}
