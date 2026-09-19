package campaign

import (
	"net/http"
	"net/http/httptest"
	"net/url"
	"os"
	"path/filepath"
	"reflect"
	"strings"
	"testing"

	"github.com/DATA-DOG/go-sqlmock"
	"github.com/guruperl/genelet"
	"go.uber.org/zap"
)

// Exercise the native action selection and rendering path, with only the DB
// replaced. Forwarded identity is synthetic input from the legacy auth boundary;
// this fixture does not perform a login or start an external service.
func campaignController(t *testing.T) (*genelet.Controller, sqlmock.Sqlmock) {
	t.Helper()
	configPath := filepath.Join(t.TempDir(), "summer.json")
	if err := os.WriteFile(configPath, []byte(`{
		"ConnectArray":["mysql","unused"],
		"Secret":"synthetic-fixture-only",
		"Roles":{
			"adv":{"Id_name":"adv_id","Attributes":["adv_id","a_company","a_email"]},
			"agent":{"Id_name":"agent_id","Attributes":["agent_id"]}
		}
	}`), 0600); err != nil {
		t.Fatal(err)
	}
	config, err := genelet.NewConfig(configPath)
	if err != nil {
		t.Fatal(err)
	}
	config.Template, err = filepath.Abs("../../tmpls")
	if err != nil {
		t.Fatal(err)
	}
	component, err := genelet.LoadComponent("component.json")
	if err != nil {
		t.Fatal(err)
	}
	db, mock, err := sqlmock.New()
	if err != nil {
		t.Fatal(err)
	}
	t.Cleanup(func() { _ = db.Close() })
	t.Cleanup(func() {
		if err := mock.ExpectationsWereMet(); err != nil {
			t.Error(err)
		}
	})
	controller := genelet.NewController(config, db, zap.NewNop())
	controller.ModelFactories["campaign"] = func() interface{} {
		model := &Model{}
		model.Initialize(component, zap.NewNop())
		return model
	}
	controller.FilterFactories["campaign"] = func() interface{} {
		filter := &Filter{}
		filter.Initialize(component, zap.NewNop())
		return filter
	}
	return controller, mock
}

func TestCampaignDashboardRendersTopics(t *testing.T) {
	for _, edition := range []struct{ tag, heading string }{
		{"g", "活动管理"}, {"e", "Campaign Management"},
	} {
		for _, query := range []string{"", "?action=dashboard", "?adv_id=999"} {
			t.Run(edition.tag+query, func(t *testing.T) {
				controller, mock := campaignController(t)
				// Anchoring the WHERE suffix also guards against silently adopting
				// topics-only active-state filtering or pagination for dashboard.
				mock.ExpectPrepare(`SELECT .* FROM adv_campaign .* WHERE \(c\.adv_id =\?\) ORDER BY c\.campaign_id$`).ExpectQuery().
					WithArgs("101").WillReturnRows(sqlmock.NewRows([]string{"campaign_id"}))
				request := httptest.NewRequest(http.MethodGet, "/goto/adv/"+edition.tag+"/campaign"+query, nil)
				if err := request.ParseForm(); err != nil {
					t.Fatal(err)
				}
				request.Header.Set("X-Forwarded-User", "101")
				request.Header.Set("X-Forwarded-Group", "Fixture Company|advertiser@example.test")
				response := httptest.NewRecorder()
				err := controller.Handle("campaign", genelet.Base{
					C: controller.C, R: request, W: response, RoleValue: "adv", ChartagValue: edition.tag,
				}, http.MethodGet)
				if err != nil {
					t.Fatal(err)
				}
				if response.Code != http.StatusOK || !strings.Contains(response.Body.String(), edition.heading) {
					t.Fatalf("campaign page missing: status %d", response.Code)
				}
				if request.Form.Get("_action") != "dashboard" || request.Form.Get("_gpermission") != "campaign.dashboard" {
					t.Fatal("template mapping changed action or permission")
				}
			})
		}
	}
}

func TestCampaignDashboardAndTopicsFilterSemantics(t *testing.T) {
	for _, test := range []struct {
		action, rowcount string
		active           []string
	}{
		{action: "dashboard"},
		{action: "topics", rowcount: "100", active: []string{"Yes", "New", "Pass2", "Pause"}},
	} {
		t.Run(test.action, func(t *testing.T) {
			request := httptest.NewRequest(http.MethodGet, "/goto/adv/e/campaign", nil)
			request.Form = url.Values{}
			filter := &Filter{}
			filter.SetAll(genelet.Base{R: request, RoleValue: "adv"}, test.action, "campaign", nil)
			if err := filter.Preset(); err != nil {
				t.Fatal(err)
			}
			extra := url.Values{"adv_id": {"101"}}
			if err := filter.Before(&Model{}, extra, url.Values{}); err != nil {
				t.Fatal(err)
			}
			if request.Form.Get("rowcount") != test.rowcount || !reflect.DeepEqual(extra["c.active"], test.active) {
				t.Fatalf("unexpected %s filter behavior: args=%v extra=%v", test.action, request.Form, extra)
			}
			if extra.Get("adv_id") != "101" {
				t.Fatal("filter changed account scope")
			}
		})
	}
}

func TestCampaignDashboardRetainsAccessChecks(t *testing.T) {
	for _, test := range []struct{ role, identity string }{{"adv", ""}, {"agent", "202"}} {
		t.Run(test.role, func(t *testing.T) {
			controller, _ := campaignController(t)
			request := httptest.NewRequest(http.MethodGet, "/goto/"+test.role+"/e/campaign", nil)
			if err := request.ParseForm(); err != nil {
				t.Fatal(err)
			}
			request.Header.Set("X-Forwarded-User", test.identity)
			response := httptest.NewRecorder()
			err := controller.Handle("campaign", genelet.Base{
				C: controller.C, R: request, W: response, RoleValue: test.role, ChartagValue: "e",
			}, http.MethodGet)
			if failure, ok := err.(genelet.Gerror); !ok || failure.Code != http.StatusUnauthorized {
				t.Fatalf("access rejection = %v", err)
			}
			if response.Body.Len() != 0 {
				t.Fatal("rejected request rendered a page")
			}
		})
	}
}
