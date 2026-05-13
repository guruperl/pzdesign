package slot

import (
	"net/http/httptest"
	"net/url"
	"strings"
	"testing"

	"github.com/guruperl/aofei/acl"
	"github.com/guruperl/pzdesign/genelet"
)

func TestFilter(t *testing.T) {
	filter := new(Filter)
	comp := genelet.NewComponent("component.json")
	filter.Initialize(comp)
	filter.Action = "insert"
	filter.Component = "slot"

	if !contains(comp.InsertPars, "size_id") || !contains(comp.UpdatePars, "size_id") || !contains(comp.TopicsPars, "size_id") || !contains(comp.EditPars, "size_id") {
		t.Fatalf("slot component parameter lists must include size_id: insert=%v update=%v topics=%v edit=%v", comp.InsertPars, comp.UpdatePars, comp.TopicsPars, comp.EditPars)
	}
	filter.Base.C = testSummerConfig(t)
	fks := filter.Fks
	actions := filter.Actions
	if fks["pub"][0] != "site_id" {
		t.Errorf("%v\n", filter.Fks)
	}
	if actions["edit"]["validate"][0] != "slot_id" {
		t.Errorf("%v\n", filter.Actions)
	}
}

func TestPresetPersistsPackedSlotSize(t *testing.T) {
	req := httptest.NewRequest("POST", "/slot", strings.NewReader(""))
	req.Form = url.Values{
		"w":             {"300"},
		"h":             {"250"},
		"fl_mime":       {"0", "1"},
		"fl_creative":   {"0"},
		"fl_expnd":      {"0", "1"},
		"qa_language":   {"EN"},
		"qa_device":     {"0"},
		"qa_position":   {"0"},
		"channel_order": {"Black"},
	}

	filter := &Filter{}
	filter.Action = "insert"
	filter.Component = "slot"
	filter.R = req
	if err := filter.Preset(); err != nil {
		t.Fatal(err)
	}
	if got := req.Form.Get("size_id"); got != "19661050" {
		t.Fatalf("size_id = %q, want packed 300x250", got)
	}
}

func TestTopicsBuildsDirectSSPTagData(t *testing.T) {
	req := httptest.NewRequest("GET", "/slot", nil)
	req.Form = url.Values{
		"pub_id":  {"7"},
		"site_id": {"11"},
		"_gobj":   {"slot"},
	}
	lists := []map[string]interface{}{{
		"slot_id":       int64(13),
		"site_id":       int64(11),
		"slot_name":     "Leaderboard",
		"size_id":       int64(19661050),
		"qa_device":     "0",
		"fl_mime":       "0,1",
		"created":       "2026-05-13 10:11:12",
		"qa_slot":       int64(0),
		"fl_item":       int64(0),
		"fl_creative":   "0",
		"fl_expnd":      "0,1",
		"qa_language":   "EN",
		"qa_position":   "0",
		"channel_order": "Black",
		"active":        "Yes",
	}}
	other := map[string]interface{}{}
	model := &Model{}
	model.SetDefaults(req.Form, &lists, &other, nil)

	filter := &Filter{}
	filter.SetAll(genelet.Base{C: &genelet.Config{ServerURL: "https://aofei.example/"}, R: req}, "topics", "slot", &other)
	if err := filter.After(model); err != nil {
		t.Fatal(err)
	}

	siteToken, err := acl.PackDirectToken(7, 11)
	if err != nil {
		t.Fatal(err)
	}
	slotToken, err := acl.PackDirectToken(13, 19661050)
	if err != nil {
		t.Fatal(err)
	}
	item := lists[0]
	if got := req.Form.Get("serverScript"); got != "https://aofei.example/pz" {
		t.Fatalf("serverScript = %q", got)
	}
	if got := req.Form.Get("site_str"); got != siteToken {
		t.Fatalf("site_str = %q, want %q", got, siteToken)
	}
	if got := item["slot_str"]; got != slotToken {
		t.Fatalf("slot_str = %q, want %q", got, slotToken)
	}
	if got := item["code"]; got != "pz-slot-13" {
		t.Fatalf("code = %q, want DOM id", got)
	}
	media := item["mediaTypes"].(string)
	if !strings.Contains(media, `"banner"`) || strings.Contains(media, "iframe") || !strings.Contains(media, "[300, 250]") {
		t.Fatalf("mediaTypes = %s", media)
	}
	browser := item["browser_code"].(string)
	for _, want := range []string{`<script src="https://aofei.example/js/ads.js"></script>`, `"site": "` + siteToken + `"`, `"code": "pz-slot-13"`, `"slot": "` + slotToken + `"`} {
		if !strings.Contains(browser, want) {
			t.Fatalf("browser code missing %q:\n%s", want, browser)
		}
	}
	api := item["api_code"].(string)
	if !strings.Contains(api, "POST https://aofei.example/pz") || !strings.Contains(api, `["<iframe ...></iframe>"]`) {
		t.Fatalf("api code = %s", api)
	}
}

func contains(items []string, want string) bool {
	for _, item := range items {
		if item == want {
			return true
		}
	}
	return false
}
