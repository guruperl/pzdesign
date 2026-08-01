package adv

import (
	"net/url"
	"strconv"

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
	if err := summer.RequireAccountEmail(self.C, who, action); err != nil {
		return err
	}

	if (who == "pub" && action == "updatepass") || (who == "web" && (action == "insert" || action == "resetpass")) {
		if ARGS.Get("firstname") == "" {
			ARGS.Set("firstname", ARGS.Get("lastname"))
		}
		if ARGS.Get("passwd") == ARGS.Get("confirm") {
			hash, err := genelet.HashPassword(ARGS.Get("passwd"))
			if err != nil {
				return err
			}
			ARGS.Set("passwd", hash)
			ARGS.Del("confirm")
		} else {
			return genelet.Err(3102)
		}
	}

	if who == "web" && (action == "activate" || action == "startreset" || action == "resetpass") {
		if ARGS.Get("md5") != genelet.Digest(self.C.Secret, ARGS.Get("adv_id"), ARGS.Get("email"), ARGS.Get("stamp"), ARGS.Get("firstname"), ARGS.Get("lastname")) {
			return genelet.Err(3102)
		}
	} else if ARGS.Get("_gadmin") != "1" && action == "update" {
		if ARGS.Get("active") != "" {
			ARGS.Del("active")
		}
	} else if ARGS.Get("_gadmin") == "1" && action == "topics" {
		ARGS.Set("sortby", "created")
		ARGS.Set("sortreverse", "1")
	}

	return nil
}

func (self *Filter) Before(model *Model, extra url.Values, nextextra url.Values) error {
	if err := self.Filter.Before(&model.Model, extra, nextextra); err != nil {
		return err
	}

	action := self.Action
	who := self.RoleValue

	if who == "agent" && action == "topics" {
		extra.Set("active", "Yes")
	} else if who == "web" && action == "insert" {
		if err := model.Randomid("adv", "adv_id", 0, 16777216, 10); err != nil {
			return err
		}
	}

	return nil
}

func (self *Filter) After(model *Model) error {
	if err := self.Filter.After(&model.Model); err != nil {
		return err
	}

	action := self.Action
	who := self.RoleValue
	ARGS := self.R.Form
	lists := *model.LISTS
	other := *model.OTHER

	if action == "topics" {
		for _, item := range lists {
			item["created"] = summer.DateDisplay(item["created"])
		}
	} else if who == "web" && action == "insert" {
		email := ARGS.Get("email")
		ARGS.Set("stamp", ARGS.Get("_gtime"))
		ARGS.Set("md5", genelet.Digest(self.C.Secret, ARGS.Get("adv_id"), email, ARGS.Get("stamp"), ARGS.Get("firstname"), ARGS.Get("lastname")))
		ARGS.Set("serverUrl", self.C.ServerURL)
		other["_gmail"] = map[string]interface{}{
			"To":      email,
			"Subject": "W8M 广告主账户邮箱验证",
			"file":    self.C.Template + "/" + who + "/adv/insert.mail." + self.ChartagValue}
	} else if who == "web" && action == "retrieve" && len(lists) > 0 {
		item := lists[0]
		email := item["email"].(string)
		adv_id := strconv.FormatInt(item["adv_id"].(int64), 10)
		ARGS.Set("stamp", ARGS.Get("_gtime"))
		ARGS.Set("md5", genelet.Digest(self.C.Secret, adv_id, email, ARGS.Get("stamp"), item["firstname"].(string), item["lastname"].(string)))
		ARGS.Set("serverUrl", self.C.ServerURL)
		other["_gmail"] = map[string]interface{}{
			"To":      email,
			"Subject": "W8M 广告主账户密码重置",
			"file":    self.C.Template + "/" + who + "/adv/retrieve.mail." + self.ChartagValue}
	}

	return nil
}
