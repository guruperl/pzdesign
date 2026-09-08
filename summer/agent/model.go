package agent

import (
	"net/url"

	"github.com/guruperl/pzdesign/summer"
)

type Model struct {
	summer.Model
}

func (self *Model) Insert(extra ...url.Values) error {
	return self.withProtectedLogin("insert", extra...)
}

func (self *Model) Update(extra ...url.Values) error {
	return self.withProtectedLogin("update", extra...)
}

func (self *Model) withProtectedLogin(action string, extra ...url.Values) error {
	summer.ScrubAccountProtectionInput(self.ARGS)
	if self.ARGS.Get("login") != "" {
		excludeID := ""
		if action == "update" {
			excludeID = self.ARGS.Get(self.CurrentKey)
		}
		if err := summer.EnsureAccountIdentifierAvailable(self.Context, self.DB, self.Storage, "agent", self.ARGS.Get("login"), excludeID); err != nil {
			return err
		}
		protected, err := summer.ProtectAccountIdentifier(self.Storage, "agent", self.ARGS.Get("login"))
		if err != nil {
			return err
		}
		if protected != nil {
			self.ARGS.Set("login", protected.Get("_normalized_identifier"))
			self.ARGS.Set("login_hmac", protected.Get("login_hmac"))
			self.ARGS.Set("login_cipher", protected.Get("login_cipher"))
			defer self.ARGS.Del("login_hmac")
			defer self.ARGS.Del("login_cipher")
			retired, err := summer.AccountPlaintextRetired(self.Storage)
			if err != nil {
				return err
			}
			if retired {
				if action == "insert" {
					original := self.InsertPars
					self.InsertPars = removeLoginField(self.InsertPars)
					defer func() { self.InsertPars = original }()
				} else {
					original := self.UpdatePars
					self.UpdatePars = removeLoginField(self.UpdatePars)
					defer func() { self.UpdatePars = original }()
				}
			}
		}
	}
	var err error
	if action == "insert" {
		err = self.Model.Insert(extra...)
	} else {
		err = self.Model.Update(extra...)
	}
	if err != nil {
		return err
	}
	for _, row := range *self.LISTS {
		delete(row, "login_hmac")
		delete(row, "login_cipher")
		delete(row, "passwd")
	}
	return nil
}

func removeLoginField(fields []string) []string {
	out := make([]string, 0, len(fields))
	for _, field := range fields {
		if field != "login" {
			out = append(out, field)
		}
	}
	return out
}
