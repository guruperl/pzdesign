package adv

import (
	"context"
	"net/url"

	"github.com/guruperl/genelet"
	"github.com/guruperl/pzdesign/summer"
)

type Model struct {
	summer.Model
}

func (self *Model) Resetpass(extra ...url.Values) error {
	identity, _ := self.Storage["Identity"].(*genelet.IdentityService)
	if identity == nil {
		return self.Model.Resetpass(extra...)
	}
	ctx := self.Context
	if ctx == nil {
		ctx = context.Background()
	}
	args := self.ARGS
	return identity.ResetPassword(ctx, genelet.IdentityAccount{Role: "adv", ID: args.Get("adv_id")}, args.Get("email"), args.Get("passwd"), args.Get("recovery_code"))
}

func (self *Model) Dashboard(extra ...url.Values) error {
	return self.Edit(extra...)
}

func (self *Model) Takedown(extra ...url.Values) error {
	ARGS := self.ARGS
	return self.DoSQL("UPDATE adv SET active=? WHERE adv_id=?", ARGS.Get("active"), ARGS.Get("adv_id"))
}
