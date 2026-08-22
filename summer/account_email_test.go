package summer

import (
	"errors"
	"testing"

	"github.com/guruperl/genelet"
)

func TestAccountEmailAvailable(t *testing.T) {
	t.Setenv("SMTPUSER", "")
	t.Setenv("SMTPPASS", "")
	t.Setenv("SMTPHOST", "")
	t.Setenv("GOOGLE_CLIENT_ID", "")
	t.Setenv("GOOGLE_CLIENT_SECRET", "")
	t.Setenv("GOOGLE_REFRESH_TOKEN", "")

	tests := []struct {
		name   string
		config *genelet.Config
		want   bool
	}{
		{name: "nil config"},
		{name: "missing block", config: &genelet.Config{Blks: map[string]map[string]string{}}},
		{
			name: "complete",
			config: &genelet.Config{Blks: map[string]map[string]string{
				"_gmail": {
					"Address":  "smtp.example.test:465",
					"Username": "local-smtp-user",
					"Password": "local-smtp-password",
					"From":     "support@example.test",
				},
			}},
			want: true,
		},
		{
			name: "missing sender",
			config: &genelet.Config{Blks: map[string]map[string]string{
				"_gmail": {
					"Address":  "smtp.example.test:465",
					"Username": "local-smtp-user",
					"Password": "local-smtp-password",
				},
			}},
		},
	}

	for _, test := range tests {
		t.Run(test.name, func(t *testing.T) {
			if got := AccountEmailAvailable(test.config); got != test.want {
				t.Fatalf("AccountEmailAvailable() = %v, want %v", got, test.want)
			}
		})
	}
}

func TestAccountEmailAvailableForGmailAPI(t *testing.T) {
	t.Setenv("GOOGLE_CLIENT_ID", "client-id")
	t.Setenv("GOOGLE_CLIENT_SECRET", "client-secret")
	t.Setenv("GOOGLE_REFRESH_TOKEN", "refresh-token")
	config := &genelet.Config{Blks: map[string]map[string]string{
		"_gmail": {
			"Transport": "gmail-api",
			"Reply-To":  "support@w8m.com",
		},
	}}
	if !AccountEmailAvailable(config) {
		t.Fatal("environment-backed Gmail API configuration should be available")
	}

	t.Setenv("GOOGLE_REFRESH_TOKEN", "")
	if AccountEmailAvailable(config) {
		t.Fatal("Gmail API configuration without a refresh token should be unavailable")
	}
}

func TestAccountEmailAvailableFromEnvironment(t *testing.T) {
	t.Setenv("SMTPUSER", "local-smtp-user")
	t.Setenv("SMTPPASS", "local-smtp-password")
	t.Setenv("SMTPHOST", "smtp.example.test:465")
	config := &genelet.Config{Blks: map[string]map[string]string{
		"_gmail": {"From": "support@example.test"},
	}}
	if !AccountEmailAvailable(config) {
		t.Fatal("environment-backed SMTP configuration should be available")
	}
}

func TestRequireAccountEmail(t *testing.T) {
	config := &genelet.Config{Blks: map[string]map[string]string{}}
	for _, action := range []string{"insert", "retrieve"} {
		err := RequireAccountEmail(config, "web", action)
		if err == nil || err.Error() != "邮件服务暂时停用，请稍后再试或联系技术支持。" {
			t.Fatalf("RequireAccountEmail(web, %s) error = %v", action, err)
		}
	}
	for _, test := range []struct {
		role   string
		action string
	}{
		{role: "web", action: "startnew"},
		{role: "web", action: "activate"},
		{role: "adv", action: "update"},
		{role: "pub", action: "topics"},
	} {
		if err := RequireAccountEmail(config, test.role, test.action); err != nil {
			t.Fatalf("RequireAccountEmail(%s, %s) = %v", test.role, test.action, err)
		}
	}
}

func TestRequireAccountEmailRejectsFailedGmailPreflight(t *testing.T) {
	t.Setenv("GOOGLE_CLIENT_ID", "client-id")
	t.Setenv("GOOGLE_CLIENT_SECRET", "client-secret")
	t.Setenv("GOOGLE_REFRESH_TOKEN", "refresh-token")
	config := &genelet.Config{Blks: map[string]map[string]string{
		"_gmail": {"Transport": "gmail-api"},
	}}
	original := checkAccountEmailCredentials
	checkAccountEmailCredentials = func(*genelet.Config) error {
		return errors.New("invalid grant")
	}
	t.Cleanup(func() { checkAccountEmailCredentials = original })

	err := RequireAccountEmail(config, "web", "insert")
	if err == nil || err.Error() != "邮件服务暂时停用，请稍后再试或联系技术支持。" {
		t.Fatalf("RequireAccountEmail invalid Gmail credential error = %v", err)
	}
}
