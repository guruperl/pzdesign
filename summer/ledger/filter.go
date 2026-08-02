package ledger

import (
	"fmt"
	"net/url"
	"strconv"
	"strings"
	"time"

	"github.com/guruperl/genelet"
	"github.com/guruperl/pzdesign/summer"
)

type Filter struct {
	summer.Filter
}

func (self *Filter) GetAll() (map[string][]string, []string) {
	switch self.RoleValue {
	case "pub":
		self.Fks = map[string][]string{"pub": {"pub_id", ""}}
	case "adv":
		self.Fks = map[string][]string{"adv": {"adv_id", ""}}
	default:
		self.Fks = nil
	}

	return self.Filter.GetAll()
}

func (self *Filter) Preset() error {
	if err := self.Filter.Preset(); err != nil {
		return err
	}

	ARGS := self.R.Form
	action := self.Action
	//who := self.RoleValue

	if summer.Grep([]string{
		"topicsAdv24Hours", "topicsAdvTopItems", "topicsAdvTopSlots",
		"topicsAdvActions", "topicsAdvActionBreakdown",
		"topicsPub24Hours", "topicsPubTopSlots", "topicsPubTopCampaigns",
		"topicsMid24Hours", "topicsMidTopBidders", "topicsMidTopSlots",
		"topicsMidTopRoutes", "topicsMidTopPublishers",
		"topicsMarketplace", "topicsMarketplaceFreshness", "topicsMarketplaceActions",
		"topicsMarketplaceSummary",
	}, action) {
		if ARGS.Get("day") == "" {
			ARGS.Set("day", time.Now().UTC().AddDate(0, 0, -1).Format("2006-01-02"))
		}
		if ARGS.Get("idays") == "" {
			ARGS.Set("idays", "0")
		}
		if ARGS.Get("top") == "" {
			ARGS.Set("top", "200")
		}
		if err := validateReportWindow(ARGS, time.Now().UTC()); err != nil {
			return err
		}
	}

	return nil
}

func validateReportWindow(args url.Values, now time.Time) error {
	day, err := time.Parse("2006-01-02", args.Get("day"))
	if err != nil || day.Before(time.Date(2000, 1, 1, 0, 0, 0, 0, time.UTC)) || day.After(time.Date(now.UTC().Year(), now.UTC().Month(), now.UTC().Day(), 0, 0, 0, 0, time.UTC)) {
		return fmt.Errorf("report day must be a UTC date from 2000-01-01 through today")
	}
	idays, err := strconv.Atoi(args.Get("idays"))
	if err != nil || idays < 0 || idays > 90 {
		return fmt.Errorf("report lookback must be between 0 and 90 days")
	}
	top, err := strconv.Atoi(args.Get("top"))
	if err != nil || top < 1 || top > 200 {
		return fmt.Errorf("report row limit must be between 1 and 200")
	}
	args.Set("day", day.Format("2006-01-02"))
	args.Set("idays", strconv.Itoa(idays))
	args.Set("top", strconv.Itoa(top))
	return nil
}

func (self *Filter) Before(model *Model, extra url.Values, nextextra url.Values) error {
	if strings.HasPrefix(self.Action, "topicsAdvAction") && !summer.ActionReportingEnabled(model.Storage) {
		return genelet.Err(503, "转化与归因报表尚未在当前环境启用")
	}
	if strings.HasPrefix(self.Action, "topicsMarketplace") && !summer.MarketplaceReportingEnabled(model.Storage) {
		return genelet.Err(503, "市场分析尚未在当前环境启用")
	}
	return self.Filter.Before(&model.Model, extra, nextextra)
}

func (self *Filter) After(model *Model) error {
	return self.Filter.After(&model.Model)
}
