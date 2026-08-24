// Command identity-admin performs audited, operator-only identity bootstrap and
// recovery operations. It is not an HTTP service and never accepts passwords
// or encryption keys as command-line flags.
package main

import (
	"context"
	"flag"
	"fmt"
	"os"
	"os/signal"
	"strconv"
	"strings"
	"syscall"

	_ "github.com/go-sql-driver/mysql"
	"github.com/guruperl/aofei/managementapi"
	"github.com/guruperl/genelet"
)

type options struct {
	config       string
	action       string
	subjectRole  string
	subjectID    string
	login        string
	permission   string
	resourceRole string
	resourceID   string
	reason       string
	limit        int
}

func main() {
	var opts options
	flag.StringVar(&opts.config, "config", os.Getenv("SUMMER"), "Genelet configuration path")
	flag.StringVar(&opts.action, "action", "", "create-analyst, grant, revoke, reset-totp, prune-audit, or prune-api-audit")
	flag.StringVar(&opts.subjectRole, "subject-role", "", "adv, pub, agent, admin, or analyst")
	flag.StringVar(&opts.subjectID, "subject-id", "", "subject account id")
	flag.StringVar(&opts.login, "login", "", "new analyst login")
	flag.StringVar(&opts.permission, "permission", "", "closed permission name")
	flag.StringVar(&opts.resourceRole, "resource-role", "", "grant resource type")
	flag.StringVar(&opts.resourceID, "resource-id", "0", "grant resource id")
	flag.StringVar(&opts.reason, "reason", "", "single-line audited reason")
	flag.IntVar(&opts.limit, "limit", 1000, "bounded prune row limit")
	flag.Parse()
	ctx, cancel := signal.NotifyContext(context.Background(), os.Interrupt, syscall.SIGTERM)
	defer cancel()
	if err := run(ctx, opts); err != nil {
		fmt.Fprintln(os.Stderr, "identity-admin:", err)
		os.Exit(1)
	}
}

func run(ctx context.Context, opts options) error {
	if strings.TrimSpace(opts.config) == "" {
		return fmt.Errorf("-config or SUMMER is required")
	}
	config, err := genelet.NewConfig(opts.config)
	if err != nil {
		return err
	}
	actor, launcher, err := maintenanceActor(config.Identity.MaintenanceActors, os.Geteuid())
	if err != nil {
		return err
	}
	reason, err := maintenanceReason(launcher, opts.reason)
	if err != nil {
		return err
	}
	db, err := config.OpenDB()
	if err != nil {
		return err
	}
	defer db.Close()
	if err := db.PingContext(ctx); err != nil {
		return err
	}
	identity, err := genelet.NewIdentityService(config, db)
	if err != nil {
		return err
	}
	if identity == nil {
		return fmt.Errorf("Identity.Enabled must be true")
	}
	subject := genelet.IdentityAccount{Role: opts.subjectRole, ID: opts.subjectID}
	switch opts.action {
	case "create-analyst":
		password := os.Getenv("IDENTITY_NEW_PASSWORD")
		if password == "" {
			return fmt.Errorf("IDENTITY_NEW_PASSWORD is required for create-analyst")
		}
		if err := genelet.ValidatePassword(password); err != nil {
			return err
		}
		hash, err := genelet.HashPassword(password)
		if err != nil {
			return err
		}
		created, err := identity.CreateAnalyst(ctx, actor, opts.login, hash, reason)
		if err != nil {
			return err
		}
		fmt.Printf("created analyst_id=%s; TOTP enrollment is required before report access\n", created.ID)
	case "grant":
		if err := identity.GrantPermission(ctx, actor, subject, opts.permission, opts.resourceRole, opts.resourceID, reason); err != nil {
			return err
		}
		fmt.Println("permission granted")
	case "revoke":
		if err := identity.RevokePermission(ctx, actor, subject, opts.permission, opts.resourceRole, opts.resourceID, reason); err != nil {
			return err
		}
		fmt.Println("permission revoked")
	case "reset-totp":
		if err := identity.ResetTOTPByAdministrator(ctx, actor, subject, reason); err != nil {
			return err
		}
		fmt.Println("TOTP and recovery codes reset; all subject sessions revoked")
	case "prune-audit":
		deleted, err := identity.PruneSecurityEvidence(ctx, actor, opts.limit, reason)
		if err != nil {
			return err
		}
		fmt.Printf("pruned security_audit_rows=%d\n", deleted)
	case "prune-api-audit":
		actorID, err := strconv.ParseUint(actor.ID, 10, 64)
		if err != nil || actorID == 0 {
			return fmt.Errorf("mapped administrator id must be a positive number")
		}
		retentionDays := config.Identity.AuditRetentionDays
		if retentionDays == 0 {
			retentionDays = 400
		}
		deleted, err := managementapi.PruneAudit(ctx, db, managementapi.Actor{Role: "admin", ID: actorID}, retentionDays, opts.limit, reason)
		if err != nil {
			return err
		}
		fmt.Printf("pruned management_api_audit_rows=%d\n", deleted)
	default:
		return fmt.Errorf("unsupported -action %q", opts.action)
	}
	return nil
}

func maintenanceActor(bindings map[string]string, euid int) (genelet.IdentityAccount, string, error) {
	launcher := fmt.Sprintf("unix-uid:%d", euid)
	if euid < 0 {
		return genelet.IdentityAccount{}, launcher, fmt.Errorf("effective Unix UID is invalid")
	}
	actorID := strings.TrimSpace(bindings[strconv.Itoa(euid)])
	if id, err := strconv.ParseUint(actorID, 10, 64); err != nil || id == 0 {
		return genelet.IdentityAccount{}, launcher, fmt.Errorf("Identity.MaintenanceActors must map effective Unix UID %d to a positive administrator id", euid)
	}
	return genelet.IdentityAccount{Role: "admin", ID: actorID}, launcher, nil
}

func maintenanceReason(launcher, reason string) (string, error) {
	reason = strings.TrimSpace(reason)
	combined := "launcher=" + launcher + "; " + reason
	if launcher == "" || reason == "" || len(combined) > 255 || strings.ContainsAny(combined, "\r\n\x00") {
		return "", fmt.Errorf("a single-line maintenance reason of at most 255 bytes, including launcher attribution, is required")
	}
	return combined, nil
}
