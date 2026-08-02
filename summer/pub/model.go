package pub

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
	return identity.ResetPassword(ctx, genelet.IdentityAccount{Role: "pub", ID: args.Get("pub_id")}, args.Get("email"), args.Get("passwd"), args.Get("recovery_code"))
}

func (self *Model) Dashboard(extra ...url.Values) error {
	return self.Edit(extra...)
}

func (self *Model) Takedown(extra ...url.Values) error {
	ARGS := self.ARGS
	return self.DoSQL(`
UPDATE pub SET active=? WHERE pub_id=?`, ARGS.Get("active"), ARGS.Get("pub_id"))
}

func (self *Model) Insert(extra ...url.Values) error {
	ARGS := self.ARGS
	if ARGS.Get("_gadmin") == "1" {
		return self.DoSQL(`
UPDATE pub SET total_balance_id=? WHERE pub_id=?`, ARGS.Get("total_balance_id"), ARGS.Get("pub_id"))
	}
	return self.Model.Insert(extra...)
}
