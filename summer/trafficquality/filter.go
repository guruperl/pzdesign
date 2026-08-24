package trafficquality

import (
	"crypto/sha256"
	"encoding/hex"
	"fmt"
	"net/url"
	"strconv"
	"strings"
	"time"

	quality "github.com/guruperl/aofei/trafficquality"
	"github.com/guruperl/genelet"
	"github.com/guruperl/pzdesign/summer"
)

type Filter struct{ summer.Filter }

var qualityPermissions = []string{
	quality.PermissionEvidenceRead, quality.PermissionRuleDraft,
	quality.PermissionRuleActivate, quality.PermissionReviewResolve,
	quality.PermissionAppealSubmit, quality.PermissionAppealResolve,
	quality.PermissionEnforcementActivate, quality.PermissionEnforcementRollback,
	quality.PermissionBillingRecommend, quality.PermissionBillingApprove,
	quality.PermissionRetentionPrune,
}

func (f *Filter) Before(model *Model, _, _ url.Values) error {
	service, _ := model.Storage["TrafficQuality"].(*quality.Service)
	if service == nil {
		return genelet.Err(503, "流量质量审查尚未启用")
	}
	actor, scope, err := qualityActor(f)
	if err != nil {
		return err
	}
	args := f.R.Form
	other := *f.OTHER
	other["QualityScope"] = scope
	other["QualityIsAdmin"] = actor.Role == "admin"
	other["QualityCanAppeal"] = actor.Role == "adv" || actor.Role == "pub"
	other["CSRFInput"] = f.CSRFInput()

	switch f.Action {
	case "createRule":
		rule, err := qualityRuleFromForm(args)
		if err != nil {
			return err
		}
		created, err := service.CreateRule(f.R.Context(), actor, rule, args.Get("reason"))
		if err != nil {
			return err
		}
		other["QualityMessage"] = fmt.Sprintf("Rule %s version %d was created in Draft mode.", created.Key, created.Version)
		setQualityAudit(args, "QualityRuleCreated", created.ID, "Absent", "Draft")
	case "setMode":
		ruleID, err := positiveUint(args.Get("rule_id"), "rule id")
		if err != nil {
			return err
		}
		canary, err := boundedUint(args.Get("canary_bps"), "canary basis points", 0, 10_000)
		if err != nil {
			return err
		}
		if err := service.SetRuleMode(f.R.Context(), actor, ruleID,
			quality.RuleMode(args.Get("expected_mode")), quality.RuleMode(args.Get("next_mode")),
			uint16(canary), args.Get("reason")); err != nil {
			return err
		}
		other["QualityMessage"] = "Rule rollout mode was updated."
		setQualityAudit(args, "QualityRuleModeChanged", ruleID, args.Get("expected_mode"), args.Get("next_mode"))
	case "resolve":
		caseID, version, err := caseIdentity(args)
		if err != nil {
			return err
		}
		status := quality.ReviewStatus(args.Get("resolution"))
		if err := service.ResolveCase(f.R.Context(), actor, caseID, uint32(version), status, args.Get("reason")); err != nil {
			return err
		}
		other["QualityMessage"] = "Review case was resolved."
		setQualityAudit(args, "QualityCaseResolved", caseID, "Open", string(status))
	case "appeal":
		caseID, version, err := caseIdentity(args)
		if err != nil {
			return err
		}
		if err := service.AppealCase(f.R.Context(), actor, caseID, uint32(version), args.Get("reason")); err != nil {
			return err
		}
		other["QualityMessage"] = "Appeal was submitted for independent review."
		setQualityAudit(args, "QualityCaseAppealed", caseID, "InvalidTraffic", "Appealed")
	case "resolveAppeal":
		caseID, version, err := caseIdentity(args)
		if err != nil {
			return err
		}
		upheld := args.Get("appeal_result") == "upheld"
		if args.Get("appeal_result") != "upheld" && args.Get("appeal_result") != "denied" {
			return fmt.Errorf("appeal result is invalid")
		}
		if err := service.ResolveAppeal(f.R.Context(), actor, caseID, uint32(version), upheld, args.Get("reason")); err != nil {
			return err
		}
		other["QualityMessage"] = "Appeal was resolved."
		setQualityAudit(args, "QualityAppealResolved", caseID, "Appealed", args.Get("appeal_result"))
	case "enforce":
		decisionID, err := positiveUint(args.Get("decision_id"), "decision id")
		if err != nil {
			return err
		}
		canary, err := boundedUint(args.Get("canary_bps"), "canary basis points", 0, 10_000)
		if err != nil {
			return err
		}
		hours, err := boundedUint(args.Get("ttl_hours"), "enforcement lifetime hours", 1, 720)
		if err != nil {
			return err
		}
		id, err := service.ActivateEnforcement(f.R.Context(), actor, decisionID,
			quality.Action(args.Get("enforcement_action")), uint16(canary),
			time.Duration(hours)*time.Hour, args.Get("reason"))
		if err != nil {
			return err
		}
		other["QualityMessage"] = fmt.Sprintf("Enforcement %d was activated and will enter the next cache refresh.", id)
		setQualityAudit(args, "QualityEnforcementActivated", id, "Absent", "Active")
	case "rollback":
		id, err := positiveUint(args.Get("enforcement_id"), "enforcement id")
		if err != nil {
			return err
		}
		if err := service.RollbackEnforcement(f.R.Context(), actor, id, args.Get("reason")); err != nil {
			return err
		}
		other["QualityMessage"] = "Enforcement was rolled back."
		setQualityAudit(args, "QualityEnforcementRolledBack", id, "Active", "RolledBack")
	case "recommendBilling":
		decisionID, err := positiveUint(args.Get("decision_id"), "decision id")
		if err != nil {
			return err
		}
		statementID, err := positiveUint(args.Get("statement_id"), "statement id")
		if err != nil {
			return err
		}
		id, err := service.RecommendBilling(f.R.Context(), actor, decisionID, statementID,
			args.Get("billable_key"), quality.BillingDisposition(args.Get("disposition")), args.Get("reason"))
		if err != nil {
			return err
		}
		other["QualityMessage"] = fmt.Sprintf("Billing recommendation %d awaits an independent checker.", id)
		setQualityAudit(args, "QualityBillingRecommended", id, "Absent", "Recommended")
	case "approveBilling":
		id, err := positiveUint(args.Get("billing_id"), "billing id")
		if err != nil {
			return err
		}
		approve := args.Get("approve") == "yes"
		if args.Get("approve") != "yes" && args.Get("approve") != "no" {
			return fmt.Errorf("billing approval is invalid")
		}
		if err := service.ApproveBilling(f.R.Context(), actor, id, approve, args.Get("reason")); err != nil {
			return err
		}
		other["QualityMessage"] = "Billing recommendation was reviewed."
		setQualityAudit(args, "QualityBillingReviewed", id, "Recommended", args.Get("approve"))
	}

	if actor.Role == "admin" {
		rules, err := service.ListRules(f.R.Context(), actor)
		if err != nil {
			return err
		}
		other["QualityRules"] = rules
		health, err := service.RuleHealth(f.R.Context(), actor, time.Now().UTC().Add(-24*time.Hour))
		if err != nil {
			return err
		}
		other["QualityHealth"] = health
	}
	if scope.Type != quality.ScopeGlobal {
		cases, err := service.ListCases(f.R.Context(), actor, scope, 200)
		if err != nil {
			return err
		}
		enforcements, err := service.ListEnforcements(f.R.Context(), actor, scope, 200)
		if err != nil {
			return err
		}
		other["QualityCases"] = cases
		other["QualityEnforcements"] = enforcements
	}
	return nil
}

func qualityActor(f *Filter) (quality.Actor, quality.Scope, error) {
	args := f.R.Form
	recentMFA, err := summer.VerifiedSessionState(args)
	if err != nil {
		return quality.Actor{}, quality.Scope{}, err
	}
	role := args.Get("_grole")
	roleConfig, ok := f.C.Roles[role]
	if !ok || roleConfig.Id_name == "" {
		return quality.Actor{}, quality.Scope{}, fmt.Errorf("authenticated quality-review actor is unavailable")
	}
	id := args.Get(roleConfig.Id_name)
	if _, err := positiveUint(id, "actor id"); err != nil {
		return quality.Actor{}, quality.Scope{}, err
	}
	scope, err := qualityScopeForAction(role, id, f.Action, args)
	if err != nil {
		return quality.Actor{}, quality.Scope{}, err
	}
	permissions := make(map[string]bool)
	for _, permission := range qualityPermissions {
		if roleHasPermission(roleConfig.Permissions, permission) {
			permissions[permission] = true
		}
	}
	if roleHasPermission(roleConfig.Permissions, "*") {
		permissions["*"] = true
	}
	actorScope := scope
	if role == "admin" {
		actorScope = quality.Scope{Type: quality.ScopeGlobal}
	}
	return quality.Actor{
		Role: role, ID: id, Scope: actorScope, Permissions: permissions,
		RecentMFA: recentMFA,
	}, scope, nil
}

func qualityScopeForAction(role, actorID, action string, args url.Values) (quality.Scope, error) {
	if role == "adv" {
		args.Set("adv_id", actorID)
		args.Set("scope_type", string(quality.ScopeAdvertiser))
		args.Set("scope_id", actorID)
	}
	if role == "pub" {
		args.Set("pub_id", actorID)
		args.Set("scope_type", string(quality.ScopePublisher))
		args.Set("scope_id", actorID)
	}
	var kind quality.ScopeType
	var rawID string
	switch action {
	case "topicsAdv":
		kind, rawID = quality.ScopeAdvertiser, args.Get("adv_id")
	case "topicsPub":
		kind, rawID = quality.ScopePublisher, args.Get("pub_id")
	case "topicsPartner":
		kind, rawID = quality.ScopePartner, args.Get("partner_id")
	default:
		kind, rawID = quality.ScopeType(args.Get("scope_type")), args.Get("scope_id")
	}
	if kind == "" && role == "admin" {
		return quality.Scope{Type: quality.ScopeGlobal}, nil
	}
	id, err := positiveUint(rawID, "quality scope id")
	if err != nil {
		return quality.Scope{}, err
	}
	scope := quality.Scope{Type: kind, ID: id}
	if err := scope.Validate(); err != nil || scope.Type == quality.ScopeGlobal {
		return quality.Scope{}, fmt.Errorf("quality review scope is invalid")
	}
	return scope, nil
}

func qualityRuleFromForm(args url.Values) (quality.Rule, error) {
	scopeID, err := boundedUint(args.Get("scope_id"), "scope id", 0, ^uint64(0))
	if err != nil {
		return quality.Rule{}, err
	}
	threshold, err := strconv.ParseFloat(args.Get("threshold"), 64)
	if err != nil {
		return quality.Rule{}, fmt.Errorf("threshold is invalid")
	}
	window, err := boundedUint(args.Get("window_seconds"), "window seconds", 1, 2_592_000)
	if err != nil {
		return quality.Rule{}, err
	}
	evidence, err := boundedUint(args.Get("evidence_hours"), "evidence retention hours", 1, 720)
	if err != nil {
		return quality.Rule{}, err
	}
	aggregate, err := boundedUint(args.Get("aggregate_days"), "aggregate retention days", 365, 2555)
	if err != nil {
		return quality.Rule{}, err
	}
	falsePositive, err := boundedUint(args.Get("false_positive_bps"), "false-positive basis points", 0, 10_000)
	if err != nil {
		return quality.Rule{}, err
	}
	return quality.Rule{
		Key: args.Get("rule_key"), Signal: quality.Signal(args.Get("signal")),
		Action: quality.Action(args.Get("rule_action")), Mode: quality.ModeDraft,
		Scope:     quality.Scope{Type: quality.ScopeType(args.Get("scope_type")), ID: scopeID},
		Threshold: threshold, WindowSeconds: uint32(window), ReasonCode: args.Get("reason_code"),
		EvidenceRetentionHrs: uint32(evidence), AggregateRetentionDays: uint32(aggregate),
		FalsePositiveLimitBPS: uint16(falsePositive), CreatedBy: "admin:pending",
	}, nil
}

func caseIdentity(args url.Values) (uint64, uint64, error) {
	id, err := positiveUint(args.Get("case_id"), "case id")
	if err != nil {
		return 0, 0, err
	}
	version, err := positiveUint(args.Get("case_version"), "case version")
	return id, version, err
}

func positiveUint(raw, name string) (uint64, error) {
	return boundedUint(raw, name, 1, ^uint64(0))
}

func boundedUint(raw, name string, min, max uint64) (uint64, error) {
	value, err := strconv.ParseUint(strings.TrimSpace(raw), 10, 64)
	if err != nil || value < min || value > max {
		return 0, fmt.Errorf("%s is invalid", name)
	}
	return value, nil
}

func roleHasPermission(grants []string, required string) bool {
	for _, grant := range grants {
		if grant == "*" || grant == required || strings.HasSuffix(grant, "*") && strings.HasPrefix(required, strings.TrimSuffix(grant, "*")) {
			return true
		}
	}
	return false
}

func setQualityAudit(args url.Values, event string, objectID uint64, prior, next string) {
	digest := sha256.Sum256([]byte("quality:" + strconv.FormatUint(objectID, 10)))
	args.Set("_gaudit_event", event)
	args.Set("_gaudit_reason", args.Get("reason"))
	args.Set("_gaudit_prior_state", prior)
	args.Set("_gaudit_new_state", next)
	args.Set("_gaudit_object_hash", hex.EncodeToString(digest[:]))
}
