package main

import (
	"net/http"
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
