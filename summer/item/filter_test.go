package item

import (
	"net/http/httptest"
	"net/url"
	"strings"
	"testing"

	"github.com/DATA-DOG/go-sqlmock"
	"github.com/guruperl/aofei/match"
	"github.com/guruperl/genelet"
)

func itemFilterForPreset(values url.Values) *Filter {
	req := httptest.NewRequest("POST", "/item", nil)
	req.Form = values
	filter := &Filter{}
	filter.Action = "insert"
	filter.Component = "item"
	filter.RoleValue = "adv"
	filter.R = req
	return filter
}

func TestPresetAcceptsOnlyFinitePositiveUSDCPM(t *testing.T) {
	filter := itemFilterForPreset(url.Values{
		"cost_type": {"CPM"}, "cost": {" 1.25 "},
		"item_click": {"https://advertiser.example/landing"},
	})
	if err := filter.Preset(); err != nil {
		t.Fatal(err)
	}
	if got := filter.R.Form.Get("cost"); got != "1.250000" {
		t.Fatalf("normalized cost = %q", got)
	}
	if got := filter.R.Form.Get("cost_type"); got != "CPM" {
		t.Fatalf("cost type = %q", got)
	}
}

func TestPresetRejectsLegacyPricingWithoutConversion(t *testing.T) {
	for _, costType := range []string{"ROI", "CPC", "CPA", ""} {
		filter := itemFilterForPreset(url.Values{
			"cost_type": {costType}, "cost": {"1"},
			"item_click": {"https://advertiser.example/landing"},
		})
		if err := filter.Preset(); err == nil || !strings.Contains(err.Error(), "only supports reviewed USD CPM") {
			t.Fatalf("cost type %q error = %v", costType, err)
		}
	}
	for _, cost := range []string{"0", "-1", "NaN", "+Inf", "invalid"} {
		filter := itemFilterForPreset(url.Values{
			"cost_type": {"CPM"}, "cost": {cost},
			"item_click": {"https://advertiser.example/landing"},
		})
		if err := filter.Preset(); err == nil || !strings.Contains(err.Error(), "finite positive") {
			t.Fatalf("cost %q error = %v", cost, err)
		}
	}
}

func TestPresetRejectsUnsafeLandingAndTrackerURLs(t *testing.T) {
	for _, values := range []url.Values{
		{"cost_type": {"CPM"}, "cost": {"1"}, "item_click": {"javascript:alert(1)"}},
		{"cost_type": {"CPM"}, "cost": {"1"}, "item_click": {"https://advertiser.example"}, "imp_url": {"https://ok.example/p, data:text/html,bad"}},
	} {
		if err := itemFilterForPreset(values).Preset(); err == nil || !strings.Contains(err.Error(), "absolute HTTP(S)") {
			t.Fatalf("unsafe URL error = %v", err)
		}
	}
}

func TestBeforeRejectsActivationOfLegacyOrInvalidPricing(t *testing.T) {
	for _, test := range []struct {
		name     string
		role     string
		action   string
		active   string
		costType string
		cost     interface{}
		wantErr  bool
	}{
		{name: "agent rejects legacy", role: "agent", action: "authen", active: "Pass2", costType: "CPC", cost: "1", wantErr: true},
		{name: "admin rejects invalid CPM", role: "admin", action: "update", active: "Yes", costType: "CPM", cost: "0", wantErr: true},
		{name: "agent accepts reviewed CPM", role: "agent", action: "authen", active: "Yes", costType: "CPM", cost: "1.250000"},
		{name: "deactivation does not require pricing", role: "admin", action: "update", active: "No"},
	} {
		t.Run(test.name, func(t *testing.T) {
			db, mock, err := sqlmock.New()
			if err != nil {
				t.Fatal(err)
			}
			defer db.Close()
			if test.active == "Yes" || test.active == "Pass2" {
				mock.ExpectPrepare(`SELECT cost_type, cost FROM adv_item WHERE item_id=\?`).
					ExpectQuery().
					WithArgs("7").
					WillReturnRows(sqlmock.NewRows([]string{"cost_type", "cost"}).AddRow(test.costType, test.cost))
				if !test.wantErr {
					mock.ExpectQuery(`(?s)WHERE r\.active="Yes" AND i\.item_id=\?`).
						WithArgs("7").
						WillReturnRows(sqlmock.NewRows([]string{
							"creative_id", "size_id", "weight", "iurl", "item_click", "imp_url", "click_url",
							"creative_name", "content", "media_type", "mime",
						}).AddRow(9, match.SizeID2To1(300, 250), 1, nil, "https://advertiser.example/landing", nil, nil, "creative", "https://cdn.example/banner.html", "Banner", "text/html"))
				}
			}

			req := httptest.NewRequest("GET", "/item", nil)
			req.Form = url.Values{"item_id": {"7"}, "active": {test.active}, "_gobj": {"item"}}
			if test.role == "admin" {
				req.Form.Set("_gadmin", "1")
			}
			lists := []map[string]interface{}{}
			other := map[string]interface{}{}
			model := &Model{}
			model.SetDefaults(req.Form, &lists, &other, nil)
			model.SetDB(db)
			filter := &Filter{}
			filter.SetAll(genelet.Base{R: req}, test.action, "item", &other)
			filter.RoleValue = test.role
			err = filter.Before(model, url.Values{}, url.Values{})
			if test.wantErr && (err == nil || !strings.Contains(err.Error(), "cannot be activated")) {
				t.Fatalf("activation error = %v", err)
			}
			if !test.wantErr && err != nil {
				t.Fatal(err)
			}
			if err := mock.ExpectationsWereMet(); err != nil {
				t.Fatal(err)
			}
		})
	}
}
