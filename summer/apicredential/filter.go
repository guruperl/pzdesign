package apicredential

import (
	"crypto/sha256"
	"encoding/hex"
	"fmt"
	"net/url"
	"strconv"
	"time"

	"github.com/guruperl/aofei/managementapi"
	"github.com/guruperl/genelet"
	"github.com/guruperl/pzdesign/summer"
)

type Filter struct{ summer.Filter }

func (f *Filter) Before(model *Model, _, _ url.Values) error {
	service, _ := model.Storage["ManagementAPI"].(*managementapi.Service)
	if service == nil {
		return genelet.Err(503, "管理 API 尚未启用")
	}
	principal, _, err := f.AuthorizedPrincipal()
	if err != nil {
		return fmt.Errorf("API credential portal requires a verified identity: %w", err)
	}
	args := f.R.Form
	role := principal.Role
	actorID, err := strconv.ParseUint(principal.AccountID, 10, 64)
	if err != nil || actorID == 0 {
		return fmt.Errorf("authenticated API credential actor is invalid")
	}
	other := *f.OTHER
	other["APIScopes"] = []map[string]string{
		{"value": managementapi.ScopeCampaignRead, "label": "Campaign and item read"},
		{"value": managementapi.ScopeCampaignWrite, "label": "Campaign and item write"},
		{"value": managementapi.ScopeCreativeRead, "label": "Creative read"},
		{"value": managementapi.ScopeCreativeWrite, "label": "Creative write"},
		{"value": managementapi.ScopeTargetingRead, "label": "Targeting read"},
		{"value": managementapi.ScopeTargetingWrite, "label": "Targeting write"},
		{"value": managementapi.ScopeReportRead, "label": "Delivery report read"},
	}
	advID, advErr := strconv.ParseUint(args.Get("adv_id"), 10, 64)
	if role == "adv" {
		advID = actorID
		advErr = nil
		args.Set("adv_id", strconv.FormatUint(advID, 10))
	}
	if role == "admin" && f.Action == "topics" && args.Get("adv_id") == "" {
		other["APICredentials"] = []managementapi.Credential{}
		return nil
	}
	if advErr != nil || advID == 0 {
		return fmt.Errorf("advertiser id is required")
	}
	if principal.ResourceRole != "adv" || principal.ResourceID != strconv.FormatUint(advID, 10) {
		return genelet.Err(403, "API credential authorization scope does not match advertiser")
	}
	actor := managementapi.Actor{Role: role, ID: actorID}
	other["APIAdvID"] = advID
	switch f.Action {
	case "issue":
		days, err := strconv.Atoi(args.Get("expires_days"))
		if err != nil || days < 1 || days > 365 {
			return fmt.Errorf("credential lifetime must be between 1 and 365 days")
		}
		credential, token, err := service.IssueCredential(f.R.Context(), actor, advID,
			args.Get("credential_name"), args["scope"], time.Now().UTC().Add(time.Duration(days)*24*time.Hour), args.Get("reason"))
		if err != nil {
			return err
		}
		other["IssuedCredential"] = credential
		other["IssuedToken"] = token
		setAudit(args, "APICredentialIssued", credential.ID, "Absent", "Active")
	case "rotate":
		credentialID, err := strconv.ParseUint(args.Get("credential_id"), 10, 64)
		if err != nil || credentialID == 0 {
			return fmt.Errorf("credential id is invalid")
		}
		credential, token, err := service.RotateCredential(f.R.Context(), actor, advID, credentialID, args.Get("reason"))
		if err != nil {
			return err
		}
		other["IssuedCredential"] = credential
		other["IssuedToken"] = token
		setAudit(args, "APICredentialRotated", credentialID, "Active", "Rotated")
	case "revoke":
		credentialID, err := strconv.ParseUint(args.Get("credential_id"), 10, 64)
		if err != nil || credentialID == 0 {
			return fmt.Errorf("credential id is invalid")
		}
		if err := service.RevokeCredential(f.R.Context(), actor, advID, credentialID, args.Get("reason")); err != nil {
			return err
		}
		other["RevokedCredentialID"] = credentialID
		setAudit(args, "APICredentialRevoked", credentialID, "Active", "Revoked")
	}
	credentials, err := service.ListCredentials(f.R.Context(), advID)
	if err != nil {
		return err
	}
	other["APICredentials"] = credentials
	return nil
}

func setAudit(args url.Values, event string, credentialID uint64, prior, next string) {
	hash := sha256.Sum256([]byte("api-credential:" + strconv.FormatUint(credentialID, 10)))
	args.Set("_gaudit_event", event)
	args.Set("_gaudit_reason", args.Get("reason"))
	args.Set("_gaudit_prior_state", prior)
	args.Set("_gaudit_new_state", next)
	args.Set("_gaudit_object_hash", hex.EncodeToString(hash[:]))
}
