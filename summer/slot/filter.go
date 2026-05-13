// Package slot describes slot.
package slot

import (
	"fmt"
	"html"
	"net/url"
	"strconv"
	"strings"

	"github.com/guruperl/aofei/acl"
	"github.com/guruperl/pzdesign/summer"
)

const defaultSlotSizeID uint32 = 4194368

type Filter struct {
	summer.Filter
}

func (self *Filter) Preset() error {
	if err := self.Filter.Preset(); err != nil {
		return err
	}

	ARGS := self.R.Form
	action := self.Action
	//	who := self.RoleValue

	if action == "insert" || action == "update" {
		qaSlot := summer.GetSlotScoreArgs(ARGS)
		ARGS.Set("qa_slot", strconv.FormatUint(uint64(qaSlot), 10))
		flItem := summer.GetItemScoreArgs(ARGS)
		ARGS.Set("fl_item", strconv.FormatUint(uint64(flItem), 10))
		for _, name := range []string{"fl_mime", "fl_creative", "fl_expnd"} {
			if ARGS.Get(name) != "" {
				ARGS.Set(name, strings.Join(ARGS[name], ","))
			}
		}
		err := summer.SetSizeID(ARGS)
		if err != nil {
			return err
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
	//who := self.RoleValue

	if action == "topics" {
		if siteID := ARGS.Get("site_id"); siteID != "" {
			extra.Set("site_id", siteID)
		}
		extra["active"] = []string{"Yes", "New"}
	}

	return nil
}

func (self *Filter) After(model *Model) error {
	if err := self.Filter.After(&model.Model); err != nil {
		return err
	}

	ARGS := self.R.Form
	action := self.Action
	lists := *model.LISTS
	other := *model.OTHER

	if action == "startnew" {
		for _, name := range []string{"language", "device", "position"} {
			other["qa_"+name] = summer.LargeOptions(name)
			summer.TranslateOne(other["qa_"+name], "label", "label_chinese")
		}
		for _, name := range []string{"mime", "creative", "expnd"} {
			other["fl_"+name] = summer.LargeOptions(name)
			summer.TranslateOne(other["fl_"+name], "label", "label_chinese")
		}
		summer.TranslateOne(other["channel_topics"], "channel_name", "channel_name_g")
	} else if action == "edit" {
		item := lists[0]
		ensureSlotSizeID(item)
		summer.SetWH(item)
		slot := summer.UnpackSlot((uint32(item["qa_slot"].(int64))))
		for k, v := range slot.InHash() {
			item[k] = v
		}
		campItem := summer.UnpackItem((uint32(item["fl_item"].(int64))))
		for k, v := range campItem.InHash() {
			item[k] = v
		}
		for _, name := range []string{"language", "device", "position"} {
			str := ""
			if item["qa_"+name] != nil {
				str = item["qa_"+name].(string)
			}
			other["qa_"+name] = self.AfterItemSet(name, str)
			summer.TranslateOne(other["qa_"+name], "label", "label_chinese")
		}
		for _, name := range []string{"mime", "creative", "expnd"} {
			str := ""
			if item["fl_"+name] != nil {
				str = item["fl_"+name].(string)
			}
			other["fl_"+name] = self.AfterItemSet(name, str)
			summer.TranslateOne(other["fl_"+name], "label", "label_chinese")
		}
		summer.TranslateOne(item["chac_topics"], "channel_name", "channel_name_g")
	} else if action == "topics" {
		summer.TranslateOne(lists, "qa_device", "qa_device_g")
		serverURL := normalizeServerURL("")
		if self.C != nil {
			serverURL = normalizeServerURL(self.C.ServerURL)
		}
		ARGS.Set("serverUrl", serverURL)
		ARGS.Set("serverScript", serverURL+"/pz")
		pubID, err := strconv.ParseUint(ARGS.Get("pub_id"), 10, 32)
		if err != nil {
			return err
		}
		siteID, err := strconv.ParseUint(ARGS.Get("site_id"), 10, 32)
		if err != nil {
			return err
		}
		siteStr, err := acl.PackDirectToken(uint32(pubID), uint32(siteID))
		if err != nil {
			return err
		}
		ARGS.Set("site_str", siteStr)
		for _, item := range lists {
			slotID := uint32(item["slot_id"].(int64))
			ensureSlotSizeID(item)
			sizeID := uint32(item["size_id"].(int64))
			summer.SetWH(item)
			item["slot_str"], err = acl.PackDirectToken(slotID, sizeID)
			if err != nil {
				return err
			}
			item["code"] = slotDOMID(slotID)
			item["mediaTypes"] = mimeFormat(item)
			item["browser_code"] = browserSample(serverURL, siteStr, item)
			item["api_code"] = apiSample(serverURL+"/pz", siteStr, item)
			if created := item["created"]; created != nil {
				c := created.(string)
				item["created"] = c[:len(c)-9]
			}
		}
	} else if action == "insert" {
		item := lists[0]
		ARGS.Set("entitytype_id", "32")
		ARGS.Set("entity_id", item["slot_id"].(string))
		ARGS.Set("othertype_id", "4")

		if ARGS.Get("belong_ids") != "" {
			err := model.CallOnce(map[string]interface{}{"model": "chac", "action": "insertBelong"})
			if err != nil {
				return err
			}
		}
		if ARGS.Get("ac_ids") != "" {
			err := model.CallOnce(map[string]interface{}{"model": "chac", "action": "insertAc"})
			if err != nil {
				return err
			}
		}
	} else if action == "update" {
		ARGS.Set("table", "pub_slot")
		ARGS.Set("idname", "slot_id")
		ARGS.Set("entitytype_id", "32")
		ARGS.Set("entity_id", ARGS.Get("slot_id"))
		ARGS.Set("othertype_id", "4")
		err := model.CallOnce(map[string]interface{}{"model": "chac", "action": "update"})
		if err != nil {
			return err
		}
	}

	return nil
}

func mimeFormat(item map[string]interface{}) string {
	w := item["w"].(uint16)
	h := item["h"].(uint16)
	return fmt.Sprintf("\t\t\t\"banner\": {\n\t\t\t\t\"size\": [%d, %d]\n\t\t\t}", w, h)
}

func ensureSlotSizeID(item map[string]interface{}) {
	sizeID := defaultSlotSizeID
	switch raw := item["size_id"].(type) {
	case int64:
		if raw > 0 {
			sizeID = uint32(raw)
		}
	case int:
		if raw > 0 {
			sizeID = uint32(raw)
		}
	case uint32:
		if raw > 0 {
			sizeID = raw
		}
	case uint64:
		if raw > 0 {
			sizeID = uint32(raw)
		}
	case string:
		if parsed, err := strconv.ParseUint(raw, 10, 32); err == nil && parsed > 0 {
			sizeID = uint32(parsed)
		}
	}
	item["size_id"] = int64(sizeID)
}

func normalizeServerURL(raw string) string {
	raw = strings.TrimSpace(raw)
	if raw == "" {
		raw = "http://localhost"
	}
	return strings.TrimRight(raw, "/")
}

func slotDOMID(slotID uint32) string {
	return "pz-slot-" + strconv.FormatUint(uint64(slotID), 10)
}

func browserSample(serverURL, siteStr string, item map[string]interface{}) string {
	code := item["code"].(string)
	slot := item["slot_str"].(string)
	w := item["w"].(uint16)
	h := item["h"].(uint16)
	return fmt.Sprintf(`<!doctype html>
<html>
<head>
<meta charset="utf-8">
<script src="%s/js/ads.js"></script>
</head>
<body>
<div id="%s" style="width:%dpx;height:%dpx"></div>
<script>
pzLoadAds({
	"platform": "browser",
	"site": "%s",
	"adUnits": [{
		"code": "%s",
		"slot": "%s",
		"mediaTypes": {
%s
		}
	}]
});
</script>
</body>
</html>`, serverURL, html.EscapeString(code), w, h, siteStr, code, slot, mimeFormat(item))
}

func apiSample(endpoint, siteStr string, item map[string]interface{}) string {
	code := item["code"].(string)
	slot := item["slot_str"].(string)
	return fmt.Sprintf(`POST %s

{
	"platform": "sdk",
	"site": "%s",
	"ua": "ANY_UA_STRING",
	"ip": "ANY_IP_STRING",
	"adUnits": [{
		"code": "%s",
		"slot": "%s",
		"mediaTypes": {
%s
		}
	}]
}

Response:
["<iframe ...></iframe>"]`, endpoint, siteStr, code, slot, mimeFormat(item))
}
