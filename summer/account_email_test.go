package summer

import (
	"testing"

	"github.com/guruperl/genelet"
)

func TestAccountEmailAvailable(t *testing.T) {
	t.Setenv("SMTPUSER", "")
	t.Setenv("SMTPPASS", "")
	t.Setenv("SMTPHOST", "")

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
