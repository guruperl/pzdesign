package agent

import (
	"net/url"

	"github.com/guruperl/genelet"
	"github.com/guruperl/pzdesign/summer"
)

type Filter struct {
	summer.Filter
}

func (self *Filter) Preset() error {
	if err := self.Filter.Preset(); err != nil {
		return err
	}

	ARGS := self.R.Form
	action := self.Action
	who := self.RoleValue
	if ARGS.Get("_gadmin") == "1" {
		who = "admin"
	}

	if who == "admin" && action == "insert" {
		hash, err := genelet.HashPassword(ARGS.Get("passwd"))
		if err != nil {
			return err
		}
		ARGS.Set("passwd", hash)
	}

	return nil
}

func (self *Filter) Before(model *Model, extra url.Values, nextextra url.Values) error {
	if err := self.Filter.Before(&model.Model, extra, nextextra); err != nil {
		return err
	}

	return nil
}

func (self *Filter) After(model *Model) error {
	if err := self.Filter.After(&model.Model); err != nil {
		return err
	}

	return nil
}
