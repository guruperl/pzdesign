// Package slot describes slot.
package slot

import (
	"fmt"
	"html"
	"math"
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
		floorText := strings.TrimSpace(ARGS.Get("bidfloor"))
		if floorText == "" {
			floorText = "0"
		}
		floor, err := strconv.ParseFloat(floorText, 64)
		if err != nil || floor < 0 || math.IsNaN(floor) || math.IsInf(floor, 0) {
			return fmt.Errorf("bidfloor must be a finite non-negative USD CPM value")
		}
		ARGS.Set("bidfloor", strconv.FormatFloat(floor, 'f', 6, 64))
		if action == "insert" || hasAnySlotSupplyField(ARGS) {
			refreshSeconds, err := strconv.ParseUint(defaultSupplyValue(ARGS.Get("refresh_seconds"), "0"), 10, 16)
			if err != nil {
				return fmt.Errorf("refresh_seconds must be an integer")
			}
			supply := acl.SlotSupplyMetadata{
				MediaIntent:       defaultSupplyValue(ARGS.Get("media_intent"), "Unknown"),
				Placement:         defaultSupplyValue(ARGS.Get("placement"), "Unknown"),
				RenderContext:     defaultSupplyValue(ARGS.Get("render_context"), "Unknown"),
				RefreshMode:       defaultSupplyValue(ARGS.Get("refresh_mode"), "Unknown"),
				RefreshSeconds:    uint16(refreshSeconds),
				AdDensity:         defaultSupplyValue(ARGS.Get("ad_density"), "Unknown"),
				TrafficQuality:    defaultSupplyValue(ARGS.Get("traffic_quality"), "Unknown"),
				SourceQuality:     defaultSupplyValue(ARGS.Get("source_quality"), "Unknown"),
				ManagementControl: defaultSupplyValue(ARGS.Get("management_control"), "Unknown"),
			}
			if err := supply.Validate(); err != nil {
				return fmt.Errorf("invalid slot supply metadata: %w", err)
			}
			ARGS.Set("refresh_seconds", strconv.FormatUint(refreshSeconds, 10))
		}

		qaSlot := summer.GetSlotScoreArgs(ARGS)
		ARGS.Set("qa_slot", strconv.FormatUint(uint64(qaSlot), 10))
		flItem := summer.GetItemScoreArgs(ARGS)
		ARGS.Set("fl_item", strconv.FormatUint(uint64(flItem), 10))
		for _, name := range []string{"fl_mime", "fl_creative", "fl_expnd"} {
			if ARGS.Get(name) != "" {
				ARGS.Set(name, strings.Join(ARGS[name], ","))
			}
		}
		err = summer.SetSizeID(ARGS)
		if err != nil {
			return err
		}
	}

	return nil
}

func hasAnySlotSupplyField(values url.Values) bool {
	for _, name := range []string{
		"media_intent", "placement", "render_context", "refresh_mode", "refresh_seconds",
		"ad_density", "traffic_quality", "source_quality", "management_control",
	} {
		if _, ok := values[name]; ok {
			return true
		}
	}
	return false
}

func defaultSupplyValue(value, fallback string) string {
	value = strings.TrimSpace(value)
	if value == "" {
		return fallback
	}
	return value
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
		if err := normalizeSlotBidFloor(item); err != nil {
			return err
		}
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
		siteType := strings.TrimSpace(ARGS.Get("site_type"))
		if model.DB != nil {
			if err := model.DB.QueryRow(`SELECT site_type FROM pub_site WHERE site_id = ?`, ARGS.Get("site_id")).Scan(&siteType); err != nil {
				return err
			}
		}
		if siteType != "App" {
			siteType = "Web"
		}
		ARGS.Set("site_type", siteType)
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
			if err := normalizeSlotBidFloor(item); err != nil {
				return err
			}
			sizeID := uint32(item["size_id"].(int64))
			summer.SetWH(item)
			item["slot_str"], err = acl.PackDirectToken(slotID, sizeID)
			if err != nil {
				return err
			}
			item["code"] = slotDOMID(slotID)
			item["mediaTypes"] = mimeFormat(item)
			if siteType == "Web" {
				item["browser_code"] = browserSample(serverURL, siteStr, item)
				item["api_code"] = ""
			} else {
				item["browser_code"] = ""
				item["api_code"] = apiSample(serverURL+"/pz", siteStr, item)
			}
			if created := item["created"]; created != nil {
				item["created"] = summer.DateDisplay(created)
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

func normalizeSlotBidFloor(item map[string]interface{}) error {
	if item == nil {
		return fmt.Errorf("slot is nil")
	}
	var floor float64
	switch raw := item["bidfloor"].(type) {
	case nil:
		floor = 0
	case float64:
		floor = raw
	case float32:
		floor = float64(raw)
	case int64:
		floor = float64(raw)
	case int:
		floor = float64(raw)
	case string:
		parsed, err := strconv.ParseFloat(strings.TrimSpace(raw), 64)
		if err != nil {
			return fmt.Errorf("invalid stored bidfloor %q", raw)
		}
		floor = parsed
	default:
		return fmt.Errorf("invalid stored bidfloor type %T", raw)
	}
	if floor < 0 || math.IsNaN(floor) || math.IsInf(floor, 0) {
		return fmt.Errorf("stored bidfloor must be a finite non-negative USD CPM value")
	}
	item["bidfloor"] = floor
	return nil
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
	"responseFormat": "json",
	"site": "%s",
	"app": {
		"name": "Example App"
	},
	"adUnits": [{
		"code": "%s",
		"slot": "%s",
		"mediaTypes": {
%s
		}
	}]
}

Response:
[{
	"filled": true,
	"adm": "<iframe ...></iframe>",
	"impressionUrl": "https://aofei.example/imp?...",
	"clickUrl": "https://aofei.example/clk?...",
	"price": 1.2,
	"currency": "USD",
	"adId": "10000",
	"campaignId": "10",
	"creativeId": "10000",
	"width": 300,
	"height": 250
}]

This is a contextual example and intentionally omits user/device identifiers.
Propagate applicable regs, user.consent, GPP/US Privacy, COPPA, GPC/DNT/LMT
signals from an approved privacy flow; never invent a consent grant.

Set "responseFormat": "openrtb" for an OpenRTB BidResponse.`, endpoint, siteStr, code, slot, mimeFormat(item))
}
