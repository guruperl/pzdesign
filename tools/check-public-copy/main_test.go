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
		{name: "Exact static toggle class", language: "en", html: `<a class="nav-link lang-toggle" href="/index.zh.html">中文</a>`},
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

func TestCheckStylesheetRevisions(t *testing.T) {
	t.Parallel()
	for _, test := range []struct {
		name     string
		text     string
		wantFail bool
	}{
		{name: "current revision", text: `<link href="/css/w8m-account.css?v=20260828-1" rel="stylesheet">`},
		{name: "stale revision", text: `<link href="/css/w8m-account.css?v=20260801-3" rel="stylesheet">`, wantFail: true},
		{name: "missing revision", text: `<link href="/admin/dashboard.css" rel="stylesheet">`, wantFail: true},
		{name: "mixed revisions", text: `<link href="/admin/dashboard.css?v=20260828-1"><link href="/admin/dashboard.css?v=old">`, wantFail: true},
		{name: "unrelated stylesheet", text: `<link href="/vendor/bootstrap.css" rel="stylesheet">`},
	} {
		test := test
		t.Run(test.name, func(t *testing.T) {
			t.Parallel()
			failures := checkStylesheetRevisions("fixture.html", test.text)
			if got := len(failures) > 0; got != test.wantFail {
				t.Fatalf("failures = %v, want failure %t", failures, test.wantFail)
			}
		})
	}
}

func TestHasAlternateLinkRequiresExactMetadata(t *testing.T) {
	t.Parallel()
	if !hasAlternateLink(`<link href="/index.zh.html" hreflang="zh-CN" rel="alternate">`, "index.zh.html", "zh-CN") {
		t.Fatal("valid alternate link was not recognized")
	}
	for _, text := range []string{
		`<a href="/index.zh.html" hreflang="zh-CN" rel="alternate">中文</a>`,
		`<link href="/index.zh.html" hreflang="fr" rel="alternate">`,
		`<link href="/other.en.html" hreflang="en" rel="alternate">`,
		`<link href="/evilindex.zh.html" hreflang="zh-CN" rel="alternate">`,
		`<link href="/index.zh.html" hreflang="zh-CN" rel="stylesheet">`,
	} {
		if hasAlternateLink(text, "index.zh.html", "zh-CN") {
			t.Fatalf("invalid alternate link was accepted: %s", text)
		}
	}
}

func TestCheckFrontPageLanguageLinkRequiresLiteralSibling(t *testing.T) {
	t.Parallel()
	for _, test := range []struct {
		name     string
		rel      string
		html     string
		wantFail bool
	}{
		{name: "Chinese to English", rel: "www/index.zh.html", html: `<a class="nav-link lang-toggle" href="/index.html">English</a>`},
		{name: "English to Chinese", rel: "www/index.html", html: `<a class="nav-link lang-toggle" href="/index.zh.html">中文</a>`},
		{name: "Dynamic Chinese target", rel: "www/index.html", html: `<a class="nav-link lang-toggle" href="/goto/web/g/">中文</a>`, wantFail: true},
		{name: "Dynamic English target", rel: "www/index.zh.html", html: `<a class="nav-link lang-toggle" href="/goto/web/e/">English</a>`, wantFail: true},
		{name: "Duplicate toggles", rel: "www/index.zh.html", html: `<a class="lang-toggle" href="/index.html">English</a><a class="lang-toggle" href="/index.html">English</a>`, wantFail: true},
	} {
		t.Run(test.name, func(t *testing.T) {
			t.Parallel()
			failures := checkFrontPageLanguageLink(test.rel, test.html)
			if got := len(failures) > 0; got != test.wantFail {
				t.Fatalf("failures = %v, want failure %t", failures, test.wantFail)
			}
		})
	}
}

func TestCheckFrontPageBrowserSelection(t *testing.T) {
	t.Parallel()
	valid := `<script id="front-language-selection">
if (window.location.pathname !== '/') { return; }
var languages = window.navigator.languages;
var language = languages && languages.length ? languages[0] : window.navigator.language;
if (/^zh(?:[-_]|$)/i.test(language || '')) { window.location.replace('/index.zh.html'); }
</script>`
	for _, test := range []struct {
		name     string
		rel      string
		html     string
		wantFail bool
	}{
		{name: "root selector", rel: "www/index.html", html: valid},
		{name: "missing root guard", rel: "www/index.html", html: strings.Replace(valid, "window.location.pathname !== '/'", "false", 1), wantFail: true},
		{name: "missing selector", rel: "www/index.html", html: `<html></html>`, wantFail: true},
		{name: "Chinese is literal", rel: "www/index.zh.html", html: `<html></html>`},
		{name: "Chinese must not redirect", rel: "www/index.zh.html", html: valid, wantFail: true},
	} {
		t.Run(test.name, func(t *testing.T) {
			t.Parallel()
			failures := checkFrontPageBrowserSelection(test.rel, test.html)
			if got := len(failures) > 0; got != test.wantFail {
				t.Fatalf("failures = %v, want failure %t", failures, test.wantFail)
			}
		})
	}
}
