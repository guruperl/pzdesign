// Package campaign has insert:
// 1) into to adv_balance needs to do before action, to get balance_id
// 2) ac, channel - InserAc, channel - InsertBelong after, to get entity_id
package campaign

import (
	"fmt"
	"net/url"
	"strings"

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

	if ARGS.Get("_gadmin") != "1" && (action == "insert" || action == "update") {
		if ARGS.Get("active") != "" {
			ARGS.Del("active")
		}
	}
	if who == "adv" && (action == "insert" || action == "update") {
		ARGS.Set("foreign_id", strings.TrimSpace(ARGS.Get("foreign_id")))
		if raw := strings.TrimSpace(ARGS.Get("iurl")); raw != "" {
			if err := validateCampaignURL("quality image", raw); err != nil {
				return err
			}
			ARGS.Set("iurl", raw)
		}
		if err := summer.ApplyDeliveryForm(ARGS, true); err != nil {
			return err
		}
		if err := summer.ValidateBalanceLimits(ARGS); err != nil {
			return err
		}
	}

	if who == "adv" {
		ARGS.Set("entitytype_id", "41")
	}

	return nil
}

func validateCampaignURL(name, raw string) error {
	u, err := url.Parse(strings.TrimSpace(raw))
	if err != nil {
		return fmt.Errorf("%s URL: %w", name, err)
	}
	scheme := strings.ToLower(u.Scheme)
	if (scheme != "http" && scheme != "https") || u.Hostname() == "" || u.User != nil {
		return fmt.Errorf("%s URL must be an absolute HTTP(S) URL without credentials", name)
	}
	return nil
}

func (self *Filter) Before(model *Model, extra url.Values, nextextra url.Values) error {
	if err := self.Filter.Before(&model.Model, extra, nextextra); err != nil {
		return err
	}

	ARGS := self.R.Form
	action := self.Action
	who := self.RoleValue
	if ARGS.Get("_gadmin") == "1" {
		who = "admin"
	}

	if who == "admin" && action == "topics" {
		if ARGS.Get("adv_id") != "" {
			extra.Set("adv_id", ARGS.Get("adv_id"))
		}
	} else if who == "agent" && action == "topics" {
		if ARGS.Get("agent_level") == "1" {
			extra["c.active"] = []string{"Yes", "New"}
		} else {
			extra["c.active"] = []string{"Yes", "New", "Pass2"}
		}
	} else if action == "topics" {
		extra["c.active"] = []string{"Yes", "New", "Pass2", "Pause"}
	} else if who == "adv" && action == "insert" {
		model.CurrentTable = "adv_balance"
		if err := self.BalanceBefore(&model.Model); err != nil {
			return err
		}
		model.CurrentTable = "adv_campaign"
	}

	return nil
}

func (self *Filter) After(model *Model) error {
	if err := self.Filter.After(&model.Model); err != nil {
		return err
	}

	ARGS := self.R.Form
	action := self.Action
	who := self.RoleValue
	lists := *model.LISTS
	other := *model.OTHER

	if action == "startnew" {
		summer.TranslateOne(other["channel_topics"], "channel_name", "channel_name_g")
		other["delivery_schedule_rows"] = summer.DeliveryScheduleRows(nil, true)
		other["delivery_schedule_rows_en"] = summer.DeliveryScheduleRows(nil, false)
		other["delivery_schedule_enabled"] = false
		other["delivery_has_timezone"] = true
		other["delivery_timezone"] = "UTC"
		other["delivery_pacing"] = "Fast"
	} else if action == "edit" {
		item := lists[0]
		other["delivery_schedule_rows"] = summer.DeliveryScheduleRows(item["weekly_schedule"], true)
		other["delivery_schedule_rows_en"] = summer.DeliveryScheduleRows(item["weekly_schedule"], false)
		item["delivery_schedule_enabled"] = summer.DeliveryScheduleEnabled(item["weekly_schedule"])
		other["delivery_schedule_enabled"] = item["delivery_schedule_enabled"]
		other["delivery_has_timezone"] = true
		other["delivery_timezone"] = item["delivery_timezone"]
		other["delivery_pacing"] = item["pacing_mode"]
		summer.TranslateOne(item, "access_order", "access_order_g")
		summer.TranslateOne(item["chac_topics"], "channel_name", "channel_name_g")
	} else if who == "adv" && action == "insert" {
		item := lists[0]
		ARGS.Set("entity_id", item["campaign_id"].(string))

		if ARGS.Get("belong_ids") != "" {
			err := model.CallOnce(map[string]interface{}{"model": "chac", "action": "insertBelong"})
			if err != nil {
				return err
			}
		}
	} else if action == "update" && who == "adv" {
		ARGS.Set("table", "adv_item")
		ARGS.Set("idname", "campaign_id")
		ARGS.Set("entity_id", ARGS.Get("campaign_id"))
		err := model.CallOnce(map[string]interface{}{"model": "chac", "action": "update"})
		if err != nil {
			return err
		}
	}

	return nil
}
