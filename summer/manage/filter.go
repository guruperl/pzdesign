package manage

import (
	"fmt"
	"net/url"
	"strconv"

	"github.com/guruperl/pzdesign/summer"
)

type Filter struct {
	summer.Filter
}

func (self *Filter) Preset() error {
	if err := self.Filter.Preset(); err != nil {
		return err
	}

	if self.Action != "login_as" {
		return nil
	}
	if self.RoleValue != "admin" {
		return fmt.Errorf("login-as is restricted to administrators")
	}
	args := self.R.Form
	var targetID string
	switch args.Get("role") {
	case "adv":
		targetID = args.Get("adv_id")
	case "pub":
		targetID = args.Get("pub_id")
	case "agent":
		targetID = args.Get("agent_id")
	default:
		return fmt.Errorf("unsupported login-as role")
	}
	id, err := strconv.ParseUint(targetID, 10, 32)
	if err != nil || id == 0 {
		return fmt.Errorf("login-as requires a valid numeric account ID")
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

	action := self.Action
	//who := self.RoleValue
	ARGS := self.R.Form
	//lists := *model.LISTS
	//other := *model.OTHER

	if action == "login_as" {
		role := ARGS.Get("role")
		uri := "/"
		if role == "adv" {
			uri = "/goto/adv/g/campaign?action=topics"
			return self.SetLoginAs(role, ARGS.Get("adv_id"), uri, model.DB)
		} else if role == "pub" {
			uri = "/goto/pub/g/site?action=topics"
			return self.SetLoginAs(role, ARGS.Get("pub_id"), uri, model.DB)
		} else if role == "agent" {
			uri = "/goto/agent/g/adv?action=topics"
			return self.SetLoginAs(role, ARGS.Get("agent_id"), uri, model.DB)
		}
	}

	return nil
}
