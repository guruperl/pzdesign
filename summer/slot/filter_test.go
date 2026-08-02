package slot

import (
	"net/http/httptest"
	"net/url"
	"strings"
	"testing"

	"github.com/DATA-DOG/go-sqlmock"
	"github.com/guruperl/aofei/acl"
	"github.com/guruperl/genelet"
)

func TestFilter(t *testing.T) {
	filter := new(Filter)
	comp := genelet.NewComponent("component.json")
	filter.Initialize(comp)
	filter.Action = "insert"
	filter.Component = "slot"

	for _, field := range []string{"size_id", "bidfloor", "media_intent", "placement", "refresh_mode", "traffic_quality"} {
		if !contains(comp.InsertPars, field) || !contains(comp.UpdatePars, field) || !contains(comp.TopicsPars, field) || !contains(comp.EditPars, field) {
			t.Fatalf("slot component parameter lists must include %s: insert=%v update=%v topics=%v edit=%v", field, comp.InsertPars, comp.UpdatePars, comp.TopicsPars, comp.EditPars)
		}
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

func TestPresetValidatesSlotSupplyTaxonomy(t *testing.T) {
	request := httptest.NewRequest("POST", "/slot", nil)
	request.Form = url.Values{
		"w": {"300"}, "h": {"250"}, "bidfloor": {"1.25"},
		"media_intent": {"Banner"}, "placement": {"InFeed"}, "render_context": {"WebPage"},
		"refresh_mode": {"Timed"}, "refresh_seconds": {"30"}, "ad_density": {"Standard"},
		"traffic_quality": {"Reviewed"}, "source_quality": {"OwnedOperated"}, "management_control": {"Publisher"},
	}
	filter := &Filter{}
	filter.Action, filter.Component, filter.R = "insert", "slot", request
	if err := filter.Preset(); err != nil {
		t.Fatal(err)
	}
	request.Form.Set("refresh_seconds", "5")
	if err := filter.Preset(); err == nil || !strings.Contains(err.Error(), "15 and 3600") {
		t.Fatalf("short refresh error = %v", err)
	}
	request.Form.Set("refresh_seconds", "30")
	request.Form.Set("placement", `<script>alert(1)</script>`)
	if err := filter.Preset(); err == nil || !strings.Contains(err.Error(), "supply metadata") {
		t.Fatalf("hostile placement error = %v", err)
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
		"bidfloor":      {" 1.25 "},
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
	if got := req.Form.Get("bidfloor"); got != "1.250000" {
		t.Fatalf("bidfloor = %q, want normalized USD CPM", got)
	}
}

func TestPresetRejectsInvalidBidFloor(t *testing.T) {
	for _, floor := range []string{"-0.01", "NaN", "+Inf", "not-a-price"} {
		t.Run(floor, func(t *testing.T) {
			req := httptest.NewRequest("POST", "/slot", nil)
			req.Form = url.Values{"bidfloor": {floor}}
			filter := &Filter{}
			filter.Action = "insert"
			filter.Component = "slot"
			filter.R = req
			if err := filter.Preset(); err == nil || !strings.Contains(err.Error(), "finite non-negative USD CPM") {
				t.Fatalf("Preset bidfloor %q error = %v", floor, err)
			}
		})
	}
}

func TestPresetDefaultsEmptyBidFloorToZero(t *testing.T) {
	req := httptest.NewRequest("POST", "/slot", nil)
	req.Form = url.Values{"w": {"300"}, "h": {"250"}}
	filter := &Filter{}
	filter.Action = "insert"
	filter.Component = "slot"
	filter.R = req
	if err := filter.Preset(); err != nil {
		t.Fatal(err)
	}
	if got := req.Form.Get("bidfloor"); got != "0.000000" {
		t.Fatalf("bidfloor = %q, want default zero", got)
	}
}

func TestTopicsBuildsDirectSSPTagData(t *testing.T) {
	req := httptest.NewRequest("GET", "/slot", nil)
	req.Form = url.Values{
		"pub_id":    {"7"},
		"site_id":   {"11"},
		"site_type": {"Web"},
		"_gobj":     {"slot"},
	}
	lists := []map[string]interface{}{slotTopicsFixture()}
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
	if api := item["api_code"].(string); api != "" {
		t.Fatalf("Web inventory generated an App API sample: %s", api)
	}
}

func TestTopicsBuildsDirectSSPAppSDKData(t *testing.T) {
	req := httptest.NewRequest("GET", "/slot", nil)
	req.Form = url.Values{
		"pub_id":    {"7"},
		"site_id":   {"11"},
		"site_type": {"App"},
		"_gobj":     {"slot"},
	}
	lists := []map[string]interface{}{slotTopicsFixture()}
	other := map[string]interface{}{}
	model := &Model{}
	model.SetDefaults(req.Form, &lists, &other, nil)
	filter := &Filter{}
	filter.SetAll(genelet.Base{C: &genelet.Config{ServerURL: "https://aofei.example/"}, R: req}, "topics", "slot", &other)
	if err := filter.After(model); err != nil {
		t.Fatal(err)
	}
	item := lists[0]
	if browser := item["browser_code"].(string); browser != "" {
		t.Fatalf("App inventory generated a browser tag: %s", browser)
	}
	api := item["api_code"].(string)
	for _, want := range []string{
		"POST https://aofei.example/pz",
		`"responseFormat": "json"`,
		`"app": {`,
		`"name": "Example App"`,
		`"filled": true`,
		`"impressionUrl": "https://aofei.example/imp?...`,
		`intentionally omits user/device identifiers`,
		`never invent a consent grant`,
		`Set "responseFormat": "openrtb"`,
	} {
		if !strings.Contains(api, want) {
			t.Fatalf("api code missing %q:\n%s", want, api)
		}
	}
	for _, forbidden := range []string{`"ip"`, `"ifa"`, `"user"`} {
		if strings.Contains(api, forbidden) {
			t.Fatalf("api code contains privacy-sensitive example field %q: %s", forbidden, api)
		}
	}
}

func TestTopicsUsesAuthoritativeSiteType(t *testing.T) {
	db, mock, err := sqlmock.New()
	if err != nil {
		t.Fatal(err)
	}
	defer db.Close()
	mock.ExpectQuery(`SELECT site_type FROM pub_site WHERE site_id = \?`).
		WithArgs("11").
		WillReturnRows(sqlmock.NewRows([]string{"site_type"}).AddRow("App"))

	req := httptest.NewRequest("GET", "/slot", nil)
	req.Form = url.Values{
		"pub_id":    {"7"},
		"site_id":   {"11"},
		"site_type": {"Web"},
		"_gobj":     {"slot"},
	}
	lists := []map[string]interface{}{slotTopicsFixture()}
	other := map[string]interface{}{}
	model := &Model{}
	model.SetDefaults(req.Form, &lists, &other, nil)
	model.SetDB(db)
	filter := &Filter{}
	filter.SetAll(genelet.Base{C: &genelet.Config{ServerURL: "https://aofei.example/"}, R: req}, "topics", "slot", &other)
	if err := filter.After(model); err != nil {
		t.Fatal(err)
	}
	if got := req.Form.Get("site_type"); got != "App" {
		t.Fatalf("site_type = %q, want authoritative App", got)
	}
	if lists[0]["browser_code"].(string) != "" || lists[0]["api_code"].(string) == "" {
		t.Fatalf("authoritative App site generated wrong samples: %#v", lists[0])
	}
	if err := mock.ExpectationsWereMet(); err != nil {
		t.Fatal(err)
	}
}

func TestNormalizeSlotBidFloor(t *testing.T) {
	for _, test := range []struct {
		name    string
		value   interface{}
		want    float64
		wantErr bool
	}{
		{name: "database string", value: "1.250000", want: 1.25},
		{name: "driver float", value: float64(2.5), want: 2.5},
		{name: "missing defaults zero", value: nil, want: 0},
		{name: "negative", value: "-1", wantErr: true},
		{name: "not numeric", value: "bad", wantErr: true},
	} {
		t.Run(test.name, func(t *testing.T) {
			item := map[string]interface{}{"bidfloor": test.value}
			err := normalizeSlotBidFloor(item)
			if test.wantErr {
				if err == nil {
					t.Fatal("normalizeSlotBidFloor error = nil")
				}
				return
			}
			if err != nil {
				t.Fatal(err)
			}
			if got := item["bidfloor"].(float64); got != test.want {
				t.Fatalf("bidfloor = %v, want %v", got, test.want)
			}
		})
	}
}

func slotTopicsFixture() map[string]interface{} {
	return map[string]interface{}{
		"slot_id":       int64(13),
		"site_id":       int64(11),
		"slot_name":     "Leaderboard",
		"size_id":       int64(19661050),
		"bidfloor":      float64(1.25),
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
