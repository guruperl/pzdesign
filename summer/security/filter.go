package security

import (
	"fmt"
	"net/url"

	"github.com/guruperl/genelet"
	"github.com/guruperl/pzdesign/summer"
)

type Filter struct {
	summer.Filter
}

func (f *Filter) account() (genelet.IdentityAccount, error) {
	args := f.R.Form
	role := args.Get("_grole")
	configRole, ok := f.C.Roles[role]
	if !ok || configRole.Id_name == "" {
		return genelet.IdentityAccount{}, fmt.Errorf("identity role is unavailable")
	}
	account := genelet.IdentityAccount{Role: role, ID: args.Get(configRole.Id_name)}
	if account.ID == "" {
		return genelet.IdentityAccount{}, fmt.Errorf("authenticated identity is unavailable")
	}
	return account, nil
}

func (f *Filter) Before(_ *Model, _, _ url.Values) error {
	if f.Identity == nil {
		return genelet.Err(503, "账户安全功能尚未启用")
	}
	account, err := f.account()
	if err != nil {
		return err
	}
	args := f.R.Form
	other := *f.OTHER
	other["Required"] = f.Identity.RequiredTOTP(account.Role)
	other["CSRFInput"] = f.CSRFInput()
	switch f.Action {
	case "enroll":
		label := args.Get("a_email")
		if label == "" {
			label = args.Get("p_email")
		}
		if label == "" {
			label = args.Get("admin_login")
		}
		if label == "" {
			label = args.Get("agent_login")
		}
		if label == "" {
			label = args.Get("analyst_login")
		}
		enrollment, err := f.Identity.BeginTOTP(f.R.Context(), account, label)
		if err != nil {
			return err
		}
		other["Enrollment"] = enrollment
	case "confirm":
		codes, err := f.Identity.ConfirmTOTP(f.R.Context(), account, args.Get("totp"))
		if err != nil {
			return err
		}
		other["RecoveryCodes"] = codes
	case "rotateRecovery":
		codes, err := f.Identity.RotateRecoveryCodes(f.R.Context(), account, args.Get("totp"))
		if err != nil {
			return err
		}
		other["RecoveryCodes"] = codes
	case "disable":
		if err := f.Identity.DisableTOTP(f.R.Context(), account, args.Get("totp"), args.Get("reason")); err != nil {
			return err
		}
		other["Disabled"] = true
	}
	state, remaining, err := f.Identity.MFAStatus(f.R.Context(), account)
	if err != nil {
		return err
	}
	other["MFAState"] = state
	other["RecoveryRemaining"] = remaining
	return nil
}
