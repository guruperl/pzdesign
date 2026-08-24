package publishercredential

import (
	"fmt"
	"net/url"
	"strconv"
	"strings"
	"time"

	"github.com/guruperl/aofei/publisherauth"
	"github.com/guruperl/genelet"
	"github.com/guruperl/pzdesign/summer"
)

var credentialPermissions = []string{
	publisherauth.PermissionCredentialRead,
	publisherauth.PermissionCredentialIssue,
	publisherauth.PermissionCredentialRotate,
	publisherauth.PermissionCredentialRevoke,
}

type Filter struct{ summer.Filter }

func (f *Filter) Before(model *Model, _, _ url.Values) error {
	service, _ := model.Storage["PublisherAuth"].(*publisherauth.Service)
	if service == nil {
		return genelet.Err(503, "发布商请求认证尚未启用")
	}
	principal, roleConfig, err := f.AuthorizedPrincipal()
	if err != nil {
		return fmt.Errorf("publisher credential portal requires a verified identity: %w", err)
	}
	args := f.R.Form
	role := principal.Role
	actorID, err := strconv.ParseUint(principal.AccountID, 10, 64)
	if err != nil || actorID == 0 {
		return fmt.Errorf("authenticated publisher credential actor is invalid")
	}
	pubID, pubErr := strconv.ParseUint(args.Get("pub_id"), 10, 64)
	if role == "pub" {
		pubID = actorID
		pubErr = nil
		args.Set("pub_id", strconv.FormatUint(pubID, 10))
	}
	other := *f.OTHER
	other["CSRFInput"] = f.CSRFInput()
	if role == "admin" && f.Action == "topics" && args.Get("pub_id") == "" {
		other["PublisherCredentials"] = []publisherauth.Credential{}
		return nil
	}
	if pubErr != nil || pubID == 0 {
		return fmt.Errorf("publisher id is required")
	}
	if principal.ResourceRole != "pub" || principal.ResourceID != strconv.FormatUint(pubID, 10) {
		return genelet.Err(403, "publisher credential authorization scope does not match publisher")
	}
	actor := publisherCredentialActor(role, actorID, roleConfig.Permissions, principal.HasRecentMFA(time.Now()))
	other["PublisherCredentialPubID"] = pubID
	privateValueIssued := false
	switch f.Action {
	case "issue":
		siteID, err := strconv.ParseUint(args.Get("site_id"), 10, 64)
		if err != nil || siteID == 0 {
			return fmt.Errorf("app site id is invalid")
		}
		days, err := strconv.Atoi(args.Get("expires_days"))
		if err != nil || days < 1 || days > 365 {
			return fmt.Errorf("credential lifetime must be between 1 and 365 days")
		}
		credential, privateValue, err := service.IssueCredential(
			f.R.Context(), actor, pubID, siteID, args.Get("credential_name"),
			time.Now().UTC().Add(time.Duration(days)*24*time.Hour), args.Get("reason"),
		)
		if err != nil {
			return err
		}
		other["IssuedPublisherCredential"] = credential
		other["IssuedPublisherPrivateValue"] = privateValue
		privateValueIssued = true
	case "rotate":
		credentialID, err := strconv.ParseUint(args.Get("credential_id"), 10, 64)
		if err != nil || credentialID == 0 {
			return fmt.Errorf("credential id is invalid")
		}
		overlapMinutes, err := strconv.Atoi(args.Get("overlap_minutes"))
		if err != nil || overlapMinutes < 0 || overlapMinutes > 7*24*60 {
			return fmt.Errorf("credential overlap must be between 0 and 10080 minutes")
		}
		credential, privateValue, err := service.RotateCredential(
			f.R.Context(), actor, pubID, credentialID,
			time.Duration(overlapMinutes)*time.Minute, args.Get("reason"),
		)
		if err != nil {
			return err
		}
		other["IssuedPublisherCredential"] = credential
		other["IssuedPublisherPrivateValue"] = privateValue
		privateValueIssued = true
	case "revoke":
		credentialID, err := strconv.ParseUint(args.Get("credential_id"), 10, 64)
		if err != nil || credentialID == 0 {
			return fmt.Errorf("credential id is invalid")
		}
		if err := service.RevokeCredential(f.R.Context(), actor, pubID, credentialID, args.Get("reason")); err != nil {
			return err
		}
		other["RevokedPublisherCredentialID"] = credentialID
	}
	credentials, err := service.ListCredentials(f.R.Context(), actor, pubID)
	if err != nil {
		if privateValueIssued {
			other["PublisherCredentials"] = []publisherauth.Credential{}
			other["PublisherCredentialListUnavailable"] = true
			return nil
		}
		return err
	}
	other["PublisherCredentials"] = credentials
	return nil
}

func publisherCredentialActor(role string, id uint64, grants []string, recentMFA bool) publisherauth.Actor {
	permissions := make(map[string]bool)
	for _, permission := range credentialPermissions {
		if hasPermission(grants, permission) {
			permissions[permission] = true
		}
	}
	if hasPermission(grants, "*") {
		permissions["*"] = true
	}
	return publisherauth.Actor{
		Role: role, ID: id, Permissions: permissions,
		RecentMFA: recentMFA,
	}
}

func hasPermission(grants []string, required string) bool {
	for _, grant := range grants {
		if grant == "*" || grant == required || strings.HasSuffix(grant, "*") && strings.HasPrefix(required, strings.TrimSuffix(grant, "*")) {
			return true
		}
	}
	return false
}
