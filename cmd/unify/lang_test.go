package main

import (
	"io"
	"net/http"
	"net/http/httptest"
	"os"
	"path/filepath"
	"strings"
	"testing"
)

func TestNegotiateLanguage(t *testing.T) {
	tests := []struct {
		name        string
		acceptLang  string
		cookie      string
		wantLang    string
		description string
	}{
		{
			name:        "zh-CN header",
			acceptLang:  "zh-CN",
			cookie:      "",
			wantLang:    "zh",
			description: "Chinese Accept-Language should return zh",
		},
		{
			name:        "en header",
			acceptLang:  "en-US",
			cookie:      "",
			wantLang:    "en",
			description: "English Accept-Language should return en",
		},
		{
			name:        "no header",
			acceptLang:  "",
			cookie:      "",
			wantLang:    "en",
			description: "Missing Accept-Language should return en (default)",
		},
		{
			name:        "cookie overrides header",
			acceptLang:  "zh-CN",
			cookie:      "en",
			wantLang:    "en",
			description: "Cookie should override Accept-Language header",
		},
		{
			name:        "cookie zh overrides en header",
			acceptLang:  "en-US",
			cookie:      "zh",
			wantLang:    "zh",
			description: "Cookie zh should override en header",
		},
		{
			name:        "zh-Hans variant",
			acceptLang:  "zh-Hans",
			cookie:      "",
			wantLang:    "zh",
			description: "Simplified Chinese variant should return zh",
		},
		{
			name:        "zh-TW variant",
			acceptLang:  "zh-TW",
			cookie:      "",
			wantLang:    "zh",
			description: "Traditional Chinese variant should return zh",
		},
		{
			name:        "invalid cookie ignored",
			acceptLang:  "en",
			cookie:      "fr",
			wantLang:    "en",
			description: "Invalid cookie value should be ignored",
		},
		{
			name:        "weighted multi-tag en preferred",
			acceptLang:  "en-US,en;q=0.9,zh;q=0.1",
			cookie:      "",
			wantLang:    "en",
			description: "Multi-tag header with English higher weight should return en",
		},
		{
			name:        "weighted multi-tag zh preferred",
			acceptLang:  "zh-CN,zh;q=0.9,en;q=0.1",
			cookie:      "",
			wantLang:    "zh",
			description: "Multi-tag header with Chinese higher weight should return zh",
		},
		{
			name:        "zero weight is unacceptable",
			acceptLang:  "zh;q=0",
			wantLang:    "en",
			description: "A zero-weight Chinese tag must not select Chinese",
		},
		{
			name:        "malformed weight is ignored",
			acceptLang:  "zh;q=invalid,en;q=0.4",
			wantLang:    "en",
			description: "A malformed Chinese preference must not outrank valid English",
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			req, _ := http.NewRequest("GET", "/", nil)
			if tt.acceptLang != "" {
				req.Header.Set("Accept-Language", tt.acceptLang)
			}
			if tt.cookie != "" {
				req.AddCookie(&http.Cookie{Name: "w8m_lang", Value: tt.cookie})
			}

			got := negotiateLanguage(req)
			if got != tt.wantLang {
				t.Errorf("%s: got %q, want %q", tt.description, got, tt.wantLang)
			}
		})
	}
}

func TestFrontPageWrapperNegotiatesAndVaries(t *testing.T) {
	docRoot := frontPageFixture(t, true)
	handler := frontPageWrapper(http.NotFoundHandler(), docRoot)

	req := httptest.NewRequest(http.MethodGet, "/", nil)
	req.Header.Set("Accept-Language", "en-US,en;q=0.9,zh;q=0.1")
	response := httptest.NewRecorder()
	handler.ServeHTTP(response, req)

	if response.Code != http.StatusOK || response.Body.String() != "english" {
		t.Fatalf("negotiated response = (%d, %q), want (200, english)", response.Code, response.Body.String())
	}
	if got := response.Header().Get("Vary"); got != "Accept-Language, Cookie" {
		t.Fatalf("Vary = %q, want Accept-Language, Cookie", got)
	}
	if got := response.Header().Get("Content-Language"); got != "en" {
		t.Fatalf("Content-Language = %q, want en", got)
	}
	if got := response.Header().Get("Cache-Control"); got != "private, no-cache" {
		t.Fatalf("Cache-Control = %q, want private, no-cache", got)
	}
	if got := response.Header().Get("Set-Cookie"); got != "" {
		t.Fatalf("negotiation must not persist an implicit choice, got Set-Cookie %q", got)
	}
}

func TestFrontPageWrapperCookieOverrideAndFallback(t *testing.T) {
	t.Run("cookie overrides header", func(t *testing.T) {
		handler := frontPageWrapper(http.NotFoundHandler(), frontPageFixture(t, true))
		req := httptest.NewRequest(http.MethodGet, "/index.html", nil)
		req.Header.Set("Accept-Language", "en")
		req.AddCookie(&http.Cookie{Name: languageCookieName, Value: "zh"})
		response := httptest.NewRecorder()
		handler.ServeHTTP(response, req)
		result := response.Result()
		defer result.Body.Close()
		body, err := io.ReadAll(result.Body)
		if err != nil {
			t.Fatal(err)
		}
		if result.StatusCode != http.StatusOK || string(body) != "chinese" {
			t.Fatalf("cookie response = (%d, %q), want (200, chinese)", result.StatusCode, body)
		}
	})

	t.Run("missing English falls back to Chinese", func(t *testing.T) {
		handler := frontPageWrapper(http.NotFoundHandler(), frontPageFixture(t, false))
		req := httptest.NewRequest(http.MethodGet, "/", nil)
		req.Header.Set("Accept-Language", "en")
		response := httptest.NewRecorder()
		handler.ServeHTTP(response, req)
		if response.Code != http.StatusOK || response.Body.String() != "chinese" {
			t.Fatalf("fallback response = (%d, %q), want (200, chinese)", response.Code, response.Body.String())
		}
		if got := response.Header().Get("Content-Language"); got != "zh" {
			t.Fatalf("fallback Content-Language = %q, want zh", got)
		}
	})
}

func TestFrontPageWrapperExplicitChoicePersists(t *testing.T) {
	handler := frontPageWrapper(http.NotFoundHandler(), frontPageFixture(t, true))
	for _, test := range []struct {
		path string
		lang string
		body string
	}{
		{path: "/goto/web/e/", lang: "en", body: "english"},
		{path: "/goto/web/g/", lang: "zh", body: "chinese"},
	} {
		t.Run(test.lang, func(t *testing.T) {
			response := httptest.NewRecorder()
			handler.ServeHTTP(response, httptest.NewRequest(http.MethodGet, test.path, nil))
			if response.Code != http.StatusOK || response.Body.String() != test.body {
				t.Fatalf("explicit response = (%d, %q), want (200, %s)", response.Code, response.Body.String(), test.body)
			}
			cookies := response.Result().Cookies()
			if len(cookies) != 1 {
				t.Fatalf("cookies = %d, want 1", len(cookies))
			}
			cookie := cookies[0]
			if cookie.Name != languageCookieName || cookie.Value != test.lang || cookie.Path != "/" || cookie.MaxAge != languageCookieMaxAge || !cookie.HttpOnly || !cookie.Secure || cookie.SameSite != http.SameSiteLaxMode {
				t.Fatalf("unexpected preference cookie: %#v", cookie)
			}
		})
	}
}

func TestLanguageChoiceRedirect(t *testing.T) {
	handler := frontPageWrapper(http.NotFoundHandler(), frontPageFixture(t, true))

	t.Run("valid same-edition return", func(t *testing.T) {
		response := httptest.NewRecorder()
		handler.ServeHTTP(response, httptest.NewRequest(http.MethodGet, "/language/en?return=%2Fgoto%2Fweb%2Fe%2Fadv%3Faction%3Dstartnew%23form", nil))
		if response.Code != http.StatusSeeOther {
			t.Fatalf("status = %d, want 303", response.Code)
		}
		if got := response.Header().Get("Location"); got != "/goto/web/e/adv?action=startnew#form" {
			t.Fatalf("Location = %q", got)
		}
		if got := response.Header().Get("Cache-Control"); got != "private, no-store" {
			t.Fatalf("Cache-Control = %q, want private, no-store", got)
		}
	})

	for _, raw := range []string{
		"https%3A%2F%2Fevil.example%2F",
		"%2Fgoto%2Fweb%2Fg%2Fadv%3Faction%3Dstartnew",
		"%2Fgoto%2Fweb%2Fe%2F..%2F..%2Fadmin",
	} {
		t.Run(raw, func(t *testing.T) {
			response := httptest.NewRecorder()
			handler.ServeHTTP(response, httptest.NewRequest(http.MethodGet, "/language/en?return="+raw, nil))
			if got := response.Header().Get("Location"); got != "/goto/web/e/" {
				t.Fatalf("unsafe return Location = %q, want fallback", got)
			}
		})
	}
}

func TestFrontPageWrapperFallsThrough(t *testing.T) {
	handler := frontPageWrapper(http.HandlerFunc(func(w http.ResponseWriter, _ *http.Request) {
		w.WriteHeader(http.StatusTeapot)
	}), frontPageFixture(t, true))
	response := httptest.NewRecorder()
	handler.ServeHTTP(response, httptest.NewRequest(http.MethodGet, "/goto/web/e/adv?action=startnew", nil))
	if response.Code != http.StatusTeapot {
		t.Fatalf("fallthrough status = %d, want 418", response.Code)
	}
}

func frontPageFixture(t *testing.T, includeEnglish bool) string {
	t.Helper()
	root := t.TempDir()
	if err := os.WriteFile(filepath.Join(root, "index.html"), []byte("chinese"), 0o600); err != nil {
		t.Fatal(err)
	}
	if includeEnglish {
		if err := os.WriteFile(filepath.Join(root, "index.en.html"), []byte("english"), 0o600); err != nil {
			t.Fatal(err)
		}
	}
	return root
}

func TestLanguageReturnTarget(t *testing.T) {
	if got := languageReturnTarget("/goto/web/e/pub?action=startnew", "en"); got != "/goto/web/e/pub?action=startnew" {
		t.Fatalf("valid return = %q", got)
	}
	for _, raw := range []string{"", "//evil.example/path", "/goto/web/g/pub", "/goto/web/e/../admin"} {
		if got := languageReturnTarget(raw, "en"); !strings.HasPrefix(got, "/goto/web/e/") {
			t.Fatalf("unsafe return %q produced %q", raw, got)
		}
	}
}
