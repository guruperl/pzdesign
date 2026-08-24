package summer

import (
	"fmt"
	"strings"

	"github.com/guruperl/genelet"
)

// AuthorizedPrincipal returns the server-derived identity and authorization
// facts for this exact component action. Caller-controlled form fields and
// forwarding headers are deliberately insufficient: Genelet is the only
// package that can bind a verified principal to the request.
func (self *Filter) AuthorizedPrincipal() (genelet.VerifiedPrincipal, genelet.Role, error) {
	if self == nil || self.C == nil || self.R == nil || self.Identity == nil {
		return genelet.VerifiedPrincipal{}, genelet.Role{}, fmt.Errorf("database-backed verified identity is required")
	}
	principal, ok := self.VerifiedPrincipal()
	if !ok || !principal.IsVerified() || principal.Role != self.RoleValue || principal.Component != self.Component || principal.Action != self.Action {
		return genelet.VerifiedPrincipal{}, genelet.Role{}, fmt.Errorf("verified request principal is unavailable")
	}
	role, ok := self.C.Roles[principal.Role]
	if !ok || role.Id_name == "" {
		return genelet.VerifiedPrincipal{}, genelet.Role{}, fmt.Errorf("verified request role is unavailable")
	}
	args := self.R.Form
	if strings.TrimSpace(args.Get("_grole")) != principal.Role ||
		strings.TrimSpace(args.Get(role.Id_name)) != principal.AccountID ||
		strings.TrimSpace(args.Get("_gpermission")) != principal.Permission {
		return genelet.VerifiedPrincipal{}, genelet.Role{}, fmt.Errorf("verified request principal no longer matches request dispatch")
	}
	return principal, role, nil
}
