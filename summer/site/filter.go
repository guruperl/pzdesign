// Package site provides a filter for the summer package.
package site

import (
	"fmt"
	"net/url"
	"strings"

	"github.com/guruperl/aofei/acl"
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

	if ARGS.Get("_gadmin") != "1" && (action == "insert" || action == "update") {
		if ARGS.Get("active") != "" {
			ARGS.Del("active")
		}
	}
	if action == "insert" || (action == "update" && hasAnySupplyField(ARGS, "inventory_environment", "canonical_identity", "store_url", "integration_mode")) {
		canonical := strings.TrimSpace(ARGS.Get("canonical_identity"))
		if canonical == "" {
			canonical = strings.TrimSpace(ARGS.Get("foreign_id"))
			ARGS.Set("canonical_identity", canonical)
		}
		metadata := acl.SiteSupplyMetadata{
			Environment:       canonicalSupplyValue(ARGS.Get("inventory_environment")),
			CanonicalIdentity: canonical,
			StoreURL:          strings.TrimSpace(ARGS.Get("store_url")),
			IntegrationMode:   canonicalSupplyValue(ARGS.Get("integration_mode")),
		}
		if err := metadata.Validate(); err != nil {
			return fmt.Errorf("invalid supply metadata: %w", err)
		}
		if metadata.Environment == "Web" && ARGS.Get("site_type") != "Web" {
			return fmt.Errorf("web inventory environment requires Web site type")
		}
		if metadata.Environment == "App" && ARGS.Get("site_type") != "App" {
			return fmt.Errorf("app inventory environment requires App site type")
		}
		if metadata.IntegrationMode == "BrowserTag" && ARGS.Get("site_type") != "Web" {
			return fmt.Errorf("browser tag integration requires Web site type")
		}
		if metadata.IntegrationMode == "SDK" && ARGS.Get("site_type") != "App" {
			return fmt.Errorf("SDK integration requires App site type")
		}
		ARGS.Set("inventory_environment", metadata.Environment)
		ARGS.Set("integration_mode", metadata.IntegrationMode)
		ARGS.Set("store_url", metadata.StoreURL)
	}

	return nil
}

func hasAnySupplyField(values url.Values, names ...string) bool {
	for _, name := range names {
		if _, ok := values[name]; ok {
			return true
		}
	}
	return false
}

func canonicalSupplyValue(value string) string {
	value = strings.TrimSpace(value)
	if value == "" {
		return "Unknown"
	}
	return value
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

	if who == "pub" && action == "topics" {
		extra["active"] = []string{"New", "Yes"}
	} else if who == "admin" && action == "topics" {
		if pubID := ARGS.Get("pub_id"); pubID != "" {
			extra.Set("pub_id", pubID)
		}
	}
	return nil
}

func (self *Filter) After(model *Model) error {
	if err := self.Filter.After(&model.Model); err != nil {
		return err
	}

	//ARGS := self.R.Form
	action := self.Action
	//role  := self.RoleValue
	lists := *model.LISTS

	if action == "edit" {
		item := lists[0]
		summer.TranslateOne(item, "access_order", "access_order_g")
	}

	return nil
}
