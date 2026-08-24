package item

import (
	"fmt"
	"net/url"
	"strconv"
	"strings"

	"github.com/guruperl/aofei/accounting"
	"github.com/guruperl/aofei/match"
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

	if who == "adv" {
		ARGS.Set("entitytype_id", "42")
	}

	if who == "adv" && (action == "insert" || action == "update") {
		if ARGS.Get("cost_type") != "CPM" {
			return fmt.Errorf("W8M v1 only supports reviewed USD CPM pricing; legacy ROI, CPC, and CPA records must be migrated explicitly")
		}
		cost, err := accounting.ParseCPM(ARGS.Get("cost"))
		if err != nil || cost <= 0 {
			return fmt.Errorf("cost must be an exact positive USD CPM value with at most six decimal places")
		}
		ARGS.Set("cost", cost.String())
		if err := validateCommercialURL("landing", ARGS.Get("item_click")); err != nil {
			return err
		}
		for _, field := range []string{"imp_url", "click_url"} {
			for _, raw := range strings.Split(ARGS.Get(field), ",") {
				if strings.TrimSpace(raw) == "" {
					continue
				}
				if err := validateCommercialURL(field, raw); err != nil {
					return err
				}
			}
		}
		if err := summer.ApplyDeliveryForm(ARGS, false); err != nil {
			return err
		}
		if err := summer.ValidateBalanceLimits(ARGS); err != nil {
			return err
		}
		slot := summer.GetSlotScoreArgs(ARGS)
		ARGS.Set("fl_slot", strconv.FormatUint(uint64(slot), 10))
		item := summer.GetItemScoreArgs(ARGS)
		ARGS.Set("qa_item", strconv.FormatUint(uint64(item), 10))
		if ARGS.Get("page_cap") != "" {
			i, err := strconv.Atoi(ARGS.Get("page_cap"))
			if err != nil {
				return err
			}
			if i > 255 {
				return fmt.Errorf("page_cap should be less than 256")
			}
		}
		for _, v := range []string{"cpc_fc", "cpm_fc"} {
			if ARGS.Get(v) != "" {
				i, err := strconv.Atoi(ARGS.Get(v))
				if err != nil {
					return err
				}
				if i > 65535 {
					return fmt.Errorf("%s should be less than 65536", v)
				}
			}
		}
		for _, name := range []string{"fl_language", "fl_device", "fl_position"} {
			if ARGS.Get(name) != "" {
				ARGS.Set(name, strings.Join(ARGS[name], ","))
			}
		}
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
	activating := ARGS.Get("active") == "Yes" || ARGS.Get("active") == "Pass2"
	if activating && ((who == "admin" && action == "update") || (who == "agent" && action == "authen")) {
		commercial := make(map[string]interface{})
		if err := model.GetSQL(commercial,
			"SELECT cost_type, cost FROM adv_item WHERE item_id=?", ARGS.Get("item_id")); err != nil {
			return fmt.Errorf("load item pricing before activation: %w", err)
		}
		costType := strings.TrimSpace(genelet.Interface2String(commercial["cost_type"]))
		cost, err := accounting.ParseCPM(genelet.Interface2String(commercial["cost"]))
		if costType != "CPM" || err != nil || cost <= 0 {
			return fmt.Errorf("item cannot be activated until its legacy or invalid price is reviewed and saved as an exact positive USD CPM value")
		}
		if err := match.DBValidateItemCreativesForActivation(self.R.Context(), model.DB, ARGS.Get("item_id")); err != nil {
			return fmt.Errorf("item cannot be activated until its active creatives pass validation: %w", err)
		}
	}

	if who == "admin" && action == "topics" {
		if ARGS.Get("campaign_id") != "" {
			extra.Set("campaign_id", ARGS.Get("campaign_id"))
		}
	} else if who == "agent" && action == "topics" {
		if ARGS.Get("agent_level") == "1" {
			extra["active"] = []string{"Yes", "New"}
		} else {
			extra["active"] = []string{"Yes", "New", "Pass2"}
		}
	} else if who == "pub" && action == "topics" {
		extra["active"] = []string{"Yes", "Pass2", "New"}
	} else if action == "topics" {
		extra["active"] = []string{"Yes", "Pass2", "New", "Pause", "Prepare"}
	} else if who == "adv" && action == "insert" {
		model.CurrentTable = "adv_balance"
		if err := self.BalanceBefore(&model.Model); err != nil {
			return err
		}
		model.CurrentTable = "adv_item"
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
	if ARGS.Get("_gadmin") == "1" {
		who = "admin"
	}
	lists := *model.LISTS
	other := *model.OTHER

	if action == "startnew" {
		other["commercial_cost_type"] = "CPM"
		other["delivery_schedule_rows"] = summer.DeliveryScheduleRows(nil, true)
		other["delivery_schedule_rows_en"] = summer.DeliveryScheduleRows(nil, false)
		other["delivery_schedule_enabled"] = false
		other["delivery_has_timezone"] = false
		other["delivery_pacing"] = "Fast"
		for _, name := range []string{"language", "device", "position"} {
			other["fl_"+name] = summer.LargeOptions(name)
			summer.TranslateOne(other["fl_"+name], "label", "label_chinese")
		}
		for _, name := range []string{"mime", "creative", "expnd"} {
			other["qa_"+name] = summer.LargeOptions(name)
			summer.TranslateOne(other["qa_"+name], "label", "label_chinese")
		}
	} else if action == "edit" {
		item := lists[0]
		item["legacy_cost_type"] = item["cost_type"] != "CPM"
		other["commercial_cost_type"] = "CPM"
		other["delivery_schedule_rows"] = summer.DeliveryScheduleRows(item["weekly_schedule"], true)
		other["delivery_schedule_rows_en"] = summer.DeliveryScheduleRows(item["weekly_schedule"], false)
		item["delivery_schedule_enabled"] = summer.DeliveryScheduleEnabled(item["weekly_schedule"])
		other["delivery_schedule_enabled"] = item["delivery_schedule_enabled"]
		other["delivery_has_timezone"] = false
		other["delivery_pacing"] = item["pacing_mode"]
		campItem := summer.UnpackItem((uint32(item["qa_item"].(int64))))
		for k, v := range campItem.InHash() {
			item[k] = v
		}
		slot := summer.UnpackSlot((uint32(item["fl_slot"].(int64))))
		for k, v := range slot.InHash() {
			item[k] = v
		}
		for _, name := range []string{"language", "device", "position"} {
			str := ""
			if item["fl_"+name] != nil {
				str = item["fl_"+name].(string)
			}
			other["fl_"+name] = self.AfterItemSet(name, str)
			summer.TranslateOne(other["fl_"+name], "label", "label_chinese")
		}
		for _, name := range []string{"mime", "creative", "expnd"} {
			str := ""
			if item["qa_"+name] != nil {
				str = item["qa_"+name].(string)
			}
			other["qa_"+name] = self.AfterItemSet(name, str)
			summer.TranslateOne(other["qa_"+name], "label", "label_chinese")
		}
	} else if action == "topics" {
		for _, item := range lists {
			if item["startx"] != nil {
				item["startx"] = summer.MonthDayDisplay(item["startx"])
			}
			if item["endx"] != nil {
				item["endx"] = summer.MonthDayDisplay(item["endx"])
			}
		}
		summer.TranslateOne(lists, "qa_mime", "qa_chinese")
	} else if (who == "admin" || who == "agent") && action == "update" {
		// this is to recalculate the weight of active creatives, after an update
		// to ensure the weights are normalized to 1.0
		err := model.DoSQL(`
UPDATE adv_creative r
INNER JOIN (
	SELECT SUM(weight) AS weight
	FROM adv_creative
	WHERE item_id=? AND active="Yes"
) AS t ON r.item_id = ?
SET r.weight= r.weight/t.weight`, ARGS.Get("item_id"), ARGS.Get("item_id"))
		if err != nil {
			return fmt.Errorf("failed to recalculate weight: %s", err.Error())
		}
	}

	return nil
}

func validateCommercialURL(name, raw string) error {
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
