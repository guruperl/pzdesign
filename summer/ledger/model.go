package ledger

import (
	"fmt"
	"net/url"
	"strconv"

	"github.com/guruperl/aofei/advice"
	"github.com/guruperl/pzdesign/summer"
)

type Model struct {
	summer.Model
}

func (self *Model) TopicsPub24Hours(extra ...url.Values) error {
	ARGS := self.ARGS
	//`SELECT DATE_FORMAT(MIN(l.timely), '%Y-%m-%d %H:%i:00') AS hours,
	if err := self.SelectSQL(self.LISTS,
		`SELECT DATE_FORMAT(MIN(l.timely), '%H:%i:00') AS hours,
SUM(p.imps) AS imps, SUM(p.clis) AS clis, SUM(p.spend) AS spend
FROM ledger_pub p
INNER JOIN ledger_log l USING (log_id)
WHERE p.pub_id=? AND (timely BETWEEN DATE_SUB(?, INTERVAL ? DAY) AND ?)
GROUP BY FLOOR(UNIX_TIMESTAMP(timely) / 3600)`,
		ARGS.Get("pub_id"), ARGS.Get("day"), ARGS.Get("idays"), ARGS.Get("day")+" 23:59:59"); err != nil {
		return err
	}

	return self.ProcessAfter("topicsPub24Hours", extra...)
}

func (self *Model) TopicsPubTopSlots(extra ...url.Values) error {
	ARGS := self.ARGS
	return self.SelectSQL(self.LISTS,
		`SELECT p.slot_id, s.slot_name, p.site_id, p.pub_id, p.imps, p.clis, p.spend, (p.spend*1000/p.imps) AS cpm, (p.spend/p.clis) AS cpc, (p.clis/p.imps) AS ctr
FROM daily_pub p
INNER JOIN daily_log l USING (log_id)
INNER JOIN pub_slot s USING (slot_id)
WHERE pub_id=? AND (l.daily BETWEEN DATE_SUB(?, INTERVAL ? DAY) AND ?)
ORDER BY p.spend DESC LIMIT ?`,
		ARGS.Get("pub_id"), ARGS.Get("day"), ARGS.Get("idays"), ARGS.Get("day"), ARGS.Get("top"))
}

func (self *Model) TopicsPubTopCampaigns(extra ...url.Values) error {
	ARGS := self.ARGS
	return self.SelectSQL(self.LISTS,
		`SELECT a.campaign_id, c.campaign_name, ANY_VALUE(a.adv_id) AS adv_id, SUM(pa.spend) AS spend, SUM(pa.imps) AS imps, SUM(pa.clis) AS clis, (SUM(pa.spend)*1000/SUM(pa.imps)) AS cpm, (SUM(pa.spend)/SUM(pa.clis)) AS cpc, (SUM(pa.clis)/SUM(pa.imps)) AS ctr
FROM daily_pub_adv pa
INNER JOIN daily_pub p USING (lp_id)
INNER JOIN daily_log l ON (p.log_id=l.log_id)
INNER JOIN daily_adv a USING (la_id)
INNER JOIN adv_campaign c USING (campaign_id)
WHERE pub_id=? AND (l.daily BETWEEN DATE_SUB(?, INTERVAL ? DAY) AND ?)
GROUP BY a.campaign_id ORDER BY spend DESC LIMIT ?`,
		ARGS.Get("pub_id"), ARGS.Get("day"), ARGS.Get("idays"), ARGS.Get("day"), ARGS.Get("top"))
}

func (self *Model) TopicsAdv24Hours(extra ...url.Values) error {
	ARGS := self.ARGS
	if err := self.SelectSQL(self.LISTS,
		`SELECT DATE_FORMAT(MIN(l.timely), '%H:%i') AS hours,
SUM(a.imps) AS imps, SUM(a.clis) AS clis, SUM(a.spend) AS spend
FROM ledger_adv a
INNER JOIN ledger_log l USING (log_id)
WHERE a.adv_id=? AND (timely BETWEEN DATE_SUB(?, INTERVAL ? DAY) AND ?)
GROUP BY FLOOR(UNIX_TIMESTAMP(timely) / 3600)`,
		ARGS.Get("adv_id"), ARGS.Get("day"), ARGS.Get("idays"), ARGS.Get("day")+" 23:59:59"); err != nil {
		return err
	}
	return self.ProcessAfter("topicsAdv24Hours", extra...)
}

func (self *Model) TopicsAdvTopItems(extra ...url.Values) error {
	ARGS := self.ARGS
	return self.SelectSQL(self.LISTS,
		`SELECT a.item_id, i.item_name, a.campaign_id, a.adv_id, a.imps, a.clis, a.spend, (a.spend*1000/a.imps) AS cpm, (a.spend/a.clis) AS cpc, (a.clis/a.imps) AS ctr
FROM daily_adv a
INNER JOIN daily_log l USING (log_id)
INNER JOIN adv_item i USING (item_id)
WHERE adv_id=? AND (l.daily BETWEEN DATE_SUB(?, INTERVAL ? DAY) AND ?)
ORDER BY a.spend DESC LIMIT ?`,
		ARGS.Get("adv_id"), ARGS.Get("day"), ARGS.Get("idays"), ARGS.Get("day"), ARGS.Get("top"))
}

func (self *Model) TopicsAdvTopSlots(extra ...url.Values) error {
	ARGS := self.ARGS
	return self.SelectSQL(self.LISTS,
		`SELECT p.slot_id, s.slot_name, ANY_VALUE(p.site_id) AS site_id, ANY_VALUE(p.pub_id) AS pub_id, SUM(pa.spend) AS spend, SUM(pa.imps) AS imps, SUM(pa.clis) AS clis, (SUM(pa.spend)*1000/SUM(pa.imps)) AS cpm, (SUM(pa.spend)/SUM(pa.clis)) AS cpc, (SUM(pa.clis)/SUM(pa.imps)) AS ctr
FROM daily_pub_adv pa
INNER JOIN daily_adv a USING (la_id)
INNER JOIN daily_log l ON (a.log_id=l.log_id)
INNER JOIN daily_pub p USING (lp_id)
INNER JOIN pub_slot s USING (slot_id)
WHERE adv_id=? AND (l.daily BETWEEN DATE_SUB(?, INTERVAL ? DAY) AND ?)
GROUP BY p.slot_id ORDER BY spend DESC LIMIT ?`,
		ARGS.Get("adv_id"), ARGS.Get("day"), ARGS.Get("idays"), ARGS.Get("day"), ARGS.Get("top"))
}

// TopicsAdvActions reconciles analytical action facts with delivery reporting
// for the authenticated advertiser. Actions are intentionally not added to
// spend or any billable total.
func (self *Model) TopicsAdvActions(extra ...url.Values) error {
	args := self.ARGS
	if err := self.SelectSQL(self.LISTS, `
SELECT DATE(a.occurred_at) AS daily,
COUNT(*) AS actions,
SUM(a.attribution_type='click') AS click_actions,
SUM(a.attribution_type='view') AS view_actions,
SUM(a.attribution_type='unattributed') AS unattributed_actions,
SUM(a.late) AS late_actions,
COALESCE(SUM(a.value_usd),0) AS purchase_value_usd,
COALESCE((SELECT SUM(da.imps) FROM daily_adv da INNER JOIN daily_log dl USING (log_id)
  WHERE da.adv_id=a.adv_id AND dl.daily=DATE(a.occurred_at)),0) AS imps,
COALESCE((SELECT SUM(da.clis) FROM daily_adv da INNER JOIN daily_log dl USING (log_id)
  WHERE da.adv_id=a.adv_id AND dl.daily=DATE(a.occurred_at)),0) AS clis,
COALESCE((SELECT SUM(da.spend) FROM daily_adv da INNER JOIN daily_log dl USING (log_id)
  WHERE da.adv_id=a.adv_id AND dl.daily=DATE(a.occurred_at)),0) AS spend
FROM measurement_action a
WHERE a.adv_id=? AND DATE(a.occurred_at) BETWEEN DATE_SUB(?, INTERVAL ? DAY) AND ?
GROUP BY a.adv_id, DATE(a.occurred_at)
ORDER BY daily DESC`, args.Get("adv_id"), args.Get("day"), args.Get("idays"), args.Get("day")); err != nil {
		return err
	}
	return self.CallOnce(map[string]interface{}{"model": "ledger", "action": "topicsAdvActionBreakdown"}, make(url.Values))
}

func (self *Model) TopicsAdvActionBreakdown(extra ...url.Values) error {
	args := self.ARGS
	return self.SelectSQL(self.LISTS, `
SELECT event_type, COALESCE(action_name,'') AS action_name, attribution_type,
COUNT(*) AS actions, SUM(late) AS late_actions, COALESCE(SUM(value_usd),0) AS purchase_value_usd
FROM measurement_action
WHERE adv_id=? AND DATE(occurred_at) BETWEEN DATE_SUB(?, INTERVAL ? DAY) AND ?
GROUP BY event_type, action_name, attribution_type
ORDER BY actions DESC, event_type, action_name, attribution_type`,
		args.Get("adv_id"), args.Get("day"), args.Get("idays"), args.Get("day"))
}

// TopicsMarketplace is the R02 account-scoped analytical surface. It reads
// derived reporting facts only; financial statements and delivery controls are
// separate authorities.
func (self *Model) TopicsMarketplace(extra ...url.Values) error {
	args := self.ARGS
	role, _, _, err := marketplaceScope(args)
	if err != nil {
		return err
	}
	switch role {
	case "admin", "analyst":
		err = self.SelectSQL(self.LISTS, marketplaceOperatorSQL,
			args.Get("day"), args.Get("idays"), args.Get("day"), args.Get("top"))
	case "adv":
		err = self.SelectSQL(self.LISTS, marketplaceAdvertiserSQL,
			args.Get("adv_id"), args.Get("day"), args.Get("idays"), args.Get("day"), args.Get("top"))
	case "pub":
		err = self.SelectSQL(self.LISTS, marketplacePublisherSQL,
			args.Get("pub_id"), args.Get("day"), args.Get("idays"), args.Get("day"), args.Get("top"))
	}
	if err != nil {
		return err
	}
	decorateMarketplaceRows(*self.LISTS)
	(*self.OTHER)["marketplace_contract"] = map[string]interface{}{
		"currency": "USD", "timezone": "UTC", "accounting_version": "usd-cpm-impression-v2",
		"from": args.Get("day"), "lookback_days": args.Get("idays"),
	}
	if err := self.CallOnce(map[string]interface{}{"model": "ledger", "action": "topicsMarketplaceFreshness"}, make(url.Values)); err != nil {
		return err
	}
	if role == "adv" || role == "admin" {
		if err := self.CallOnce(map[string]interface{}{"model": "ledger", "action": "topicsMarketplaceSummary"}, make(url.Values)); err != nil {
			return err
		}
		return self.CallOnce(map[string]interface{}{"model": "ledger", "action": "topicsMarketplaceActions"}, make(url.Values))
	}
	return nil
}

func (self *Model) TopicsMarketplaceSummary(extra ...url.Values) error {
	args := self.ARGS
	role, _, _, err := marketplaceScope(args)
	if err != nil {
		return err
	}
	if role == "admin" {
		return self.SelectSQL(self.LISTS, marketplaceOperatorSummarySQL,
			args.Get("day"), args.Get("idays"), args.Get("day"),
			args.Get("day"), args.Get("idays"), args.Get("day"))
	}
	if role != "adv" {
		return fmt.Errorf("marketplace analytical summary is unavailable for role %q", role)
	}
	return self.SelectSQL(self.LISTS, marketplaceAdvertiserSummarySQL,
		args.Get("adv_id"), args.Get("day"), args.Get("idays"), args.Get("day"),
		args.Get("adv_id"), args.Get("day"), args.Get("idays"), args.Get("day"))
}

const marketplaceSummarySelect = `
SELECT d.impressions, d.clicks,
       COALESCE(d.clicks/NULLIF(d.impressions,0),0) AS ctr,
       a.actions,
       COALESCE(a.actions/NULLIF(d.clicks,0),0) AS cvr,
       d.spend_usd, a.purchase_value_usd,
       COALESCE((a.purchase_value_usd-d.spend_usd)/NULLIF(d.spend_usd,0),0) AS roi,
       COALESCE(a.purchase_value_usd/NULLIF(d.spend_usd,0),0) AS roas
FROM (`

const marketplaceAdvertiserSummarySQL = marketplaceSummarySelect + `
  SELECT COALESCE(SUM(imps),0) AS impressions,
         COALESCE(SUM(clis),0) AS clicks,
         CAST(COALESCE(SUM(spend_usd),0) AS DECIMAL(20,6)) AS spend_usd
  FROM report_delivery
  WHERE adv_id=? AND timely>=DATE_SUB(?, INTERVAL ? DAY) AND timely<DATE_ADD(?, INTERVAL 1 DAY)
) d CROSS JOIN (
  SELECT COUNT(*) AS actions,
         CAST(COALESCE(SUM(value_usd),0) AS DECIMAL(20,6)) AS purchase_value_usd
  FROM measurement_action
  WHERE adv_id=? AND occurred_at>=DATE_SUB(?, INTERVAL ? DAY) AND occurred_at<DATE_ADD(?, INTERVAL 1 DAY)
) a`

const marketplaceOperatorSummarySQL = marketplaceSummarySelect + `
  SELECT COALESCE(SUM(imps),0) AS impressions,
         COALESCE(SUM(clis),0) AS clicks,
         CAST(COALESCE(SUM(spend_usd),0) AS DECIMAL(20,6)) AS spend_usd
  FROM report_delivery
  WHERE timely>=DATE_SUB(?, INTERVAL ? DAY) AND timely<DATE_ADD(?, INTERVAL 1 DAY)
) d CROSS JOIN (
  SELECT COUNT(*) AS actions,
         CAST(COALESCE(SUM(value_usd),0) AS DECIMAL(20,6)) AS purchase_value_usd
  FROM measurement_action
  WHERE occurred_at>=DATE_SUB(?, INTERVAL ? DAY) AND occurred_at<DATE_ADD(?, INTERVAL 1 DAY)
) a`

const marketplaceAdvertiserSQL = `
SELECT r.demand_source, r.campaign_id, c.campaign_name, r.item_id, i.item_name,
       r.creative_id, v.creative_name, r.pub_id, r.site_id, r.slot_id,
       COALESCE(s.slot_name,'') AS slot_name,
       r.country_id, COALESCE(dc.country_name,'') AS country_name,
       r.state_id, COALESCE(ds.state_name,'') AS state_name,
       r.device_os, r.device_type,
       r.inventory_environment, r.integration_mode, r.media_intent, r.placement,
       r.render_context, r.refresh_mode, r.refresh_seconds, r.ad_density, r.traffic_quality,
       r.source_quality, r.management_control, r.seller_type, r.seller_id,
       SUM(r.imps) AS imps, SUM(r.clis) AS clis,
       CAST(SUM(r.spend_usd) AS DECIMAL(20,6)) AS spend_usd,
       COALESCE(SUM(r.clis)/NULLIF(SUM(r.imps),0),0) AS ctr,
       COALESCE(SUM(r.spend_usd)*1000/NULLIF(SUM(r.imps),0),0) AS effective_cpm
FROM report_delivery r
LEFT JOIN adv_campaign c USING (campaign_id)
LEFT JOIN adv_item i USING (item_id)
LEFT JOIN adv_creative v USING (creative_id)
LEFT JOIN pub_slot s USING (slot_id)
LEFT JOIN def_country dc USING (country_id)
LEFT JOIN def_state ds USING (state_id)
WHERE r.adv_id=? AND r.timely>=DATE_SUB(?, INTERVAL ? DAY) AND r.timely<DATE_ADD(?, INTERVAL 1 DAY)
GROUP BY r.demand_source, r.campaign_id, c.campaign_name, r.item_id, i.item_name,
         r.creative_id, v.creative_name, r.pub_id, r.site_id, r.slot_id, s.slot_name,
         r.country_id, dc.country_name, r.state_id, ds.state_name, r.device_os, r.device_type,
         r.inventory_environment, r.integration_mode, r.media_intent, r.placement,
         r.render_context, r.refresh_mode, r.refresh_seconds, r.ad_density, r.traffic_quality,
         r.source_quality, r.management_control, r.seller_type, r.seller_id
ORDER BY spend_usd DESC, r.campaign_id, r.item_id, r.creative_id LIMIT ?`

const marketplacePublisherSQL = `
SELECT r.demand_source, r.pub_id, r.site_id, ps.site_name, r.slot_id,
       sl.slot_name, r.country_id, COALESCE(dc.country_name,'') AS country_name,
       r.state_id, COALESCE(ds.state_name,'') AS state_name,
       r.device_os, r.device_type,
       r.inventory_environment, r.integration_mode, r.media_intent, r.placement,
       r.render_context, r.refresh_mode, r.refresh_seconds, r.ad_density, r.traffic_quality,
       r.source_quality, r.management_control, r.seller_type, r.seller_id,
       SUM(r.imps) AS imps, SUM(r.clis) AS clis,
       CAST(SUM(r.revenue_usd) AS DECIMAL(20,6)) AS revenue_usd,
       COALESCE(SUM(r.clis)/NULLIF(SUM(r.imps),0),0) AS ctr,
       COALESCE(SUM(r.revenue_usd)*1000/NULLIF(SUM(r.imps),0),0) AS effective_cpm
FROM report_delivery r
LEFT JOIN pub_site ps USING (site_id)
LEFT JOIN pub_slot sl USING (slot_id)
LEFT JOIN def_country dc USING (country_id)
LEFT JOIN def_state ds USING (state_id)
WHERE r.pub_id=? AND r.timely>=DATE_SUB(?, INTERVAL ? DAY) AND r.timely<DATE_ADD(?, INTERVAL 1 DAY)
GROUP BY r.demand_source, r.pub_id, r.site_id, ps.site_name, r.slot_id, sl.slot_name,
         r.country_id, dc.country_name, r.state_id, ds.state_name, r.device_os, r.device_type,
         r.inventory_environment, r.integration_mode, r.media_intent, r.placement,
         r.render_context, r.refresh_mode, r.refresh_seconds, r.ad_density, r.traffic_quality,
         r.source_quality, r.management_control, r.seller_type, r.seller_id
ORDER BY revenue_usd DESC, r.site_id, r.slot_id LIMIT ?`

const marketplaceOperatorSQL = `
SELECT r.demand_source, r.adv_id, r.campaign_id, r.item_id, r.creative_id,
       r.bidder_id, COALESCE(b.bidder_name,'') AS bidder_name,
       r.group_id, COALESCE(g.group_name,'') AS group_name,
       r.route_bidder_id, r.target_id, r.pub_id, r.site_id, r.slot_id,
       r.country_id, COALESCE(dc.country_name,'') AS country_name,
       r.state_id, COALESCE(ds.state_name,'') AS state_name,
       r.device_os, r.device_type,
       r.inventory_environment, r.integration_mode, r.media_intent, r.placement,
       r.render_context, r.refresh_mode, r.refresh_seconds, r.ad_density, r.traffic_quality,
       r.source_quality, r.management_control, r.seller_type, r.seller_id,
       SUM(r.wins) AS wins, SUM(r.losses) AS losses,
       SUM(r.imps) AS imps, SUM(r.clis) AS clis,
       CAST(SUM(r.spend_usd) AS DECIMAL(20,6)) AS spend_usd,
       CAST(SUM(r.revenue_usd) AS DECIMAL(20,6)) AS revenue_usd,
       CAST(SUM(r.cost_usd) AS DECIMAL(20,6)) AS cost_usd,
       CAST(SUM(r.margin_usd) AS DECIMAL(20,6)) AS margin_usd,
       COALESCE(SUM(r.margin_usd)/NULLIF(SUM(r.revenue_usd),0),0) AS margin_rate,
       COALESCE(SUM(r.downstream_cpm_sum)/NULLIF(SUM(r.imps),0),0) AS downstream_cpm,
       COALESCE(SUM(r.returned_cpm_sum)/NULLIF(SUM(r.imps),0),0) AS returned_cpm,
       SUM(r.callback_errors) AS callback_errors
FROM report_delivery r
LEFT JOIN adv_bidder b USING (bidder_id)
LEFT JOIN mid_route_group g USING (group_id)
LEFT JOIN def_country dc USING (country_id)
LEFT JOIN def_state ds USING (state_id)
WHERE r.timely>=DATE_SUB(?, INTERVAL ? DAY) AND r.timely<DATE_ADD(?, INTERVAL 1 DAY)
GROUP BY r.demand_source, r.adv_id, r.campaign_id, r.item_id, r.creative_id,
         r.bidder_id, b.bidder_name, r.group_id, g.group_name,
         r.route_bidder_id, r.target_id, r.pub_id, r.site_id, r.slot_id,
         r.country_id, dc.country_name, r.state_id, ds.state_name, r.device_os, r.device_type,
         r.inventory_environment, r.integration_mode, r.media_intent, r.placement,
         r.render_context, r.refresh_mode, r.refresh_seconds, r.ad_density, r.traffic_quality,
         r.source_quality, r.management_control, r.seller_type, r.seller_id
ORDER BY revenue_usd DESC, r.adv_id, r.pub_id LIMIT ?`

func decorateMarketplaceRows(rows []map[string]interface{}) {
	for _, row := range rows {
		osCode, _ := strconv.ParseInt(fmt.Sprint(row["device_os"]), 10, 8)
		deviceCode, _ := strconv.ParseInt(fmt.Sprint(row["device_type"]), 10, 8)
		row["device_os_name"] = advice.DeviceOS(osCode).String()
		row["device_type_name"] = advice.DeviceType(deviceCode).String()
	}
}

func (self *Model) TopicsMarketplaceActions(extra ...url.Values) error {
	args := self.ARGS
	role, _, _, err := marketplaceScope(args)
	if err != nil {
		return err
	}
	if role == "admin" {
		return self.SelectSQL(self.LISTS, `
SELECT a.adv_id, a.campaign_id, a.item_id, a.creative_id, a.event_type,
       a.attribution_type, COUNT(*) AS actions, SUM(a.late) AS late_actions,
       CAST(COALESCE(SUM(a.value_usd),0) AS DECIMAL(20,6)) AS purchase_value_usd
FROM measurement_action a
WHERE DATE(a.occurred_at) BETWEEN DATE_SUB(?, INTERVAL ? DAY) AND ?
GROUP BY a.adv_id, a.campaign_id, a.item_id, a.creative_id, a.event_type, a.attribution_type
ORDER BY actions DESC, a.adv_id, a.campaign_id LIMIT ?`,
			args.Get("day"), args.Get("idays"), args.Get("day"), args.Get("top"))
	}
	if role != "adv" {
		return fmt.Errorf("marketplace action report is unavailable for role %q", role)
	}
	return self.SelectSQL(self.LISTS, `
SELECT a.adv_id, a.campaign_id, a.item_id, a.creative_id, a.event_type,
       a.attribution_type, COUNT(*) AS actions, SUM(a.late) AS late_actions,
       CAST(COALESCE(SUM(a.value_usd),0) AS DECIMAL(20,6)) AS purchase_value_usd
FROM measurement_action a
WHERE a.adv_id=? AND DATE(a.occurred_at) BETWEEN DATE_SUB(?, INTERVAL ? DAY) AND ?
GROUP BY a.adv_id, a.campaign_id, a.item_id, a.creative_id, a.event_type, a.attribution_type
ORDER BY actions DESC, a.campaign_id, a.item_id LIMIT ?`,
		args.Get("adv_id"), args.Get("day"), args.Get("idays"), args.Get("day"), args.Get("top"))
}

func (self *Model) TopicsMarketplaceFreshness(extra ...url.Values) error {
	query, parameters, err := marketplaceFreshnessQuery(self.ARGS)
	if err != nil {
		return err
	}
	return self.SelectSQL(self.LISTS, query, parameters...)
}

func marketplaceScope(args url.Values) (role, scopeColumn, scopeValue string, err error) {
	role = args.Get("_grole")
	switch role {
	case "admin", "analyst":
		return role, "", "", nil
	case "adv":
		if args.Get("adv_id") == "" {
			return "", "", "", fmt.Errorf("advertiser report requires its authenticated account id")
		}
		return role, "adv_id", args.Get("adv_id"), nil
	case "pub":
		if args.Get("pub_id") == "" {
			return "", "", "", fmt.Errorf("publisher report requires its authenticated account id")
		}
		return role, "pub_id", args.Get("pub_id"), nil
	default:
		return "", "", "", fmt.Errorf("marketplace report requires an authenticated advertiser, publisher, operator, or delegated analyst role")
	}
}

func marketplaceFreshnessQuery(args url.Values) (string, []interface{}, error) {
	_, scopeColumn, scopeValue, err := marketplaceScope(args)
	if err != nil {
		return "", nil, err
	}
	where, parameters := "", []interface{}{}
	if scopeColumn != "" {
		where = " WHERE " + scopeColumn + "=?"
		parameters = append(parameters, scopeValue)
	}
	actionWhere := ""
	if scopeColumn == "adv_id" {
		actionWhere = " WHERE adv_id=?"
		parameters = append(parameters, scopeValue)
	}
	query := `SELECT
  (SELECT MAX(timely) FROM report_delivery` + where + `) AS report_through,
  CASE
    WHEN (SELECT MAX(timely) FROM report_delivery` + where + `) IS NULL THEN 'unavailable'
    WHEN (SELECT MAX(timely) FROM report_delivery` + where + `) < UTC_TIMESTAMP()-INTERVAL 2 HOUR THEN 'partial'
    ELSE 'current' END AS report_state,
  (SELECT MAX(daily) FROM daily_log) AS daily_through,
  CASE WHEN (SELECT MAX(daily) FROM daily_log) IS NULL THEN 'unavailable'
       WHEN (SELECT MAX(daily) FROM daily_log) < UTC_DATE()-INTERVAL 1 DAY THEN 'partial'
       ELSE 'current' END AS daily_state,
  (SELECT MAX(received_at) FROM measurement_action` + actionWhere + `) AS action_received_through,
  `
	if scopeColumn == "pub_id" {
		query += `'not_applicable' AS action_state, 0 AS callback_backlog`
	} else {
		query += `CASE WHEN (SELECT MAX(received_at) FROM measurement_action` + actionWhere + `) IS NULL THEN 'unknown' ELSE 'current' END AS action_state,
  (SELECT COUNT(*) FROM mid_callback_retry WHERE status IN ('Pending','Retrying','Processing')) AS callback_backlog`
	}
	// Repeated scoped subqueries need one parameter each in textual order.
	if scopeColumn != "" {
		parameters = []interface{}{scopeValue, scopeValue, scopeValue}
		if scopeColumn == "adv_id" {
			parameters = append(parameters, scopeValue, scopeValue)
		}
	}
	return query, parameters, nil
}

func (self *Model) TopicsExperiments(extra ...url.Values) error {
	return self.SelectSQL(self.LISTS, marketplaceExperimentsSQL)
}

const marketplaceExperimentsSQL = `
SELECT e.experiment_id, e.owner_type, e.adv_id, e.experiment_name,
       e.experiment_version, e.assignment_algorithm_version, e.status, e.primary_metric, e.guardrail_metric,
       e.retention_hours, e.starts_at, e.ends_at, e.stop_reason,
       COALESCE(s.variants,0) AS variants,
       COALESCE(s.allocation_basis_points,0) AS allocation_basis_points,
       COALESCE(s.exposures,0) AS exposures,
       s.last_exposure_at,
       COALESCE(s.primary_outcomes,0) AS primary_outcomes,
       CAST(COALESCE(s.primary_value,0) AS DECIMAL(20,6)) AS primary_value,
       COALESCE(s.guardrail_outcomes,0) AS guardrail_outcomes,
       CAST(COALESCE(s.guardrail_value,0) AS DECIMAL(20,6)) AS guardrail_value,
       COALESCE(s.variant_results,'') AS variant_results
FROM report_experiment e
LEFT JOIN (
  SELECT q.experiment_id, q.experiment_version,
         COUNT(*) AS variants,
         SUM(q.allocation_basis_points) AS allocation_basis_points,
         SUM(q.exposures) AS exposures,
         MAX(q.last_exposure_at) AS last_exposure_at,
         SUM(q.primary_outcomes) AS primary_outcomes,
         SUM(q.primary_value) AS primary_value,
         SUM(q.guardrail_outcomes) AS guardrail_outcomes,
         SUM(q.guardrail_value) AS guardrail_value,
         GROUP_CONCAT(CONCAT(q.variant_key, ': ', q.allocation_basis_points,
           ' bp / ', q.exposures, ' exposures / ', q.primary_outcomes,
           ' primary=', CAST(q.primary_value AS DECIMAL(20,6)), ' / ',
           q.guardrail_outcomes, ' guardrail=',
           CAST(q.guardrail_value AS DECIMAL(20,6)))
           ORDER BY q.variant_key SEPARATOR '; ') AS variant_results
  FROM (
    SELECT v.experiment_id, v.experiment_version, v.variant_key,
           v.allocation_basis_points,
           COUNT(DISTINCT x.exposure_id) AS exposures,
           MAX(x.exposed_at) AS last_exposure_at,
           COUNT(DISTINCT CASE WHEN o.metric_name=e2.primary_metric THEN o.outcome_id END) AS primary_outcomes,
           COALESCE(SUM(CASE WHEN o.metric_name=e2.primary_metric THEN o.metric_value ELSE 0 END),0) AS primary_value,
           COUNT(DISTINCT CASE WHEN o.metric_name=e2.guardrail_metric THEN o.outcome_id END) AS guardrail_outcomes,
           COALESCE(SUM(CASE WHEN o.metric_name=e2.guardrail_metric THEN o.metric_value ELSE 0 END),0) AS guardrail_value
    FROM report_experiment_variant v
    INNER JOIN report_experiment e2
      ON (e2.experiment_id=v.experiment_id AND e2.experiment_version=v.experiment_version)
    LEFT JOIN report_exposure x
      ON (x.experiment_id=v.experiment_id AND x.experiment_version=v.experiment_version
          AND x.variant_key=v.variant_key)
    LEFT JOIN report_experiment_outcome o USING (exposure_id)
    GROUP BY v.experiment_id, v.experiment_version, v.variant_key,
             v.allocation_basis_points, e2.primary_metric, e2.guardrail_metric
  ) q
  GROUP BY q.experiment_id, q.experiment_version
) s ON (s.experiment_id=e.experiment_id AND s.experiment_version=e.experiment_version)
ORDER BY e.experiment_id DESC`

func (self *Model) TopicsMid24Hours(extra ...url.Values) error {
	ARGS := self.ARGS
	if self.isAdvertiserMiddlemanReport() {
		if err := self.SelectSQL(self.LISTS,
			`SELECT DATE_FORMAT(MIN(l.timely), '%H:%i') AS hours,
SUM(m.imps) AS imps, SUM(m.clis) AS clis, SUM(m.pay_spend) AS spend
FROM ledger_mid m
INNER JOIN ledger_log l USING (log_id)
WHERE m.adv_id=? AND (timely BETWEEN DATE_SUB(?, INTERVAL ? DAY) AND ?)
GROUP BY FLOOR(UNIX_TIMESTAMP(timely) / 3600)`,
			ARGS.Get("adv_id"), ARGS.Get("day"), ARGS.Get("idays"), ARGS.Get("day")+" 23:59:59"); err != nil {
			return err
		}
		return self.processMiddlemanAfter()
	}
	if err := self.SelectSQL(self.LISTS,
		`SELECT DATE_FORMAT(MIN(l.timely), '%H:%i') AS hours,
SUM(m.wins) AS wins, SUM(m.losses) AS losses, SUM(m.imps) AS imps, SUM(m.clis) AS clis,
SUM(m.charge_spend) AS charge_spend, SUM(m.pay_spend) AS pay_spend, SUM(m.margin_spend) AS margin_spend,
COALESCE(SUM(m.margin_spend)/NULLIF(SUM(m.charge_spend),0), 0) AS margin_rate,
SUM(m.forward_ok) AS forward_ok, SUM(m.forward_duplicate) AS forward_duplicate,
SUM(m.forward_missing + m.forward_error + m.forward_http_error + m.forward_invalid) AS forward_errors
FROM ledger_mid m
INNER JOIN ledger_log l USING (log_id)
WHERE timely BETWEEN DATE_SUB(?, INTERVAL ? DAY) AND ?
GROUP BY FLOOR(UNIX_TIMESTAMP(timely) / 3600)`,
		ARGS.Get("day"), ARGS.Get("idays"), ARGS.Get("day")+" 23:59:59"); err != nil {
		return err
	}
	return self.processMiddlemanAfter()
}

func (self *Model) processMiddlemanAfter() error {
	pages := []map[string]interface{}{
		{"model": "ledger", "action": "topicsMidTopBidders"},
	}
	if self.isAdvertiserMiddlemanReport() {
		pages = append(pages, map[string]interface{}{"model": "ledger", "action": "topicsMidTopSlots"})
	} else {
		pages = append(pages,
			map[string]interface{}{"model": "ledger", "action": "topicsMidTopRoutes"},
			map[string]interface{}{"model": "ledger", "action": "topicsMidTopPublishers"},
		)
	}
	for _, page := range pages {
		if err := self.CallOnce(page, make(url.Values)); err != nil {
			return err
		}
	}
	return nil
}

func (self *Model) TopicsMidTopBidders(extra ...url.Values) error {
	ARGS := self.ARGS
	if self.isAdvertiserMiddlemanReport() {
		return self.SelectSQL(self.LISTS,
			`SELECT m.bidder_id, b.bidder_name, m.adv_id,
SUM(m.pay_spend) AS spend, SUM(m.imps) AS imps, SUM(m.clis) AS clis,
COALESCE(SUM(m.pay_spend)*1000/NULLIF(SUM(m.imps),0), 0) AS cpm,
COALESCE(SUM(m.pay_spend)/NULLIF(SUM(m.clis),0), 0) AS cpc,
COALESCE(SUM(m.clis)/NULLIF(SUM(m.imps),0), 0) AS ctr
FROM daily_mid m
INNER JOIN daily_log l USING (log_id)
LEFT JOIN adv_bidder b USING (bidder_id)
WHERE m.adv_id=? AND (l.daily BETWEEN DATE_SUB(?, INTERVAL ? DAY) AND ?)
GROUP BY m.bidder_id, b.bidder_name, m.adv_id
ORDER BY spend DESC LIMIT ?`,
			ARGS.Get("adv_id"), ARGS.Get("day"), ARGS.Get("idays"), ARGS.Get("day"), ARGS.Get("top"))
	}
	return self.SelectSQL(self.LISTS,
		`SELECT m.bidder_id, b.bidder_name, ANY_VALUE(m.adv_id) AS adv_id,
SUM(m.wins) AS wins, SUM(m.losses) AS losses, SUM(m.imps) AS imps, SUM(m.clis) AS clis,
SUM(m.charge_spend) AS charge_spend, SUM(m.pay_spend) AS pay_spend, SUM(m.margin_spend) AS margin_spend,
COALESCE(SUM(m.margin_spend)/NULLIF(SUM(m.charge_spend),0), 0) AS margin_rate,
SUM(m.forward_missing + m.forward_error + m.forward_http_error + m.forward_invalid) AS forward_errors
FROM daily_mid m
INNER JOIN daily_log l USING (log_id)
LEFT JOIN adv_bidder b USING (bidder_id)
WHERE l.daily BETWEEN DATE_SUB(?, INTERVAL ? DAY) AND ?
GROUP BY m.bidder_id, b.bidder_name
ORDER BY margin_spend DESC LIMIT ?`,
		ARGS.Get("day"), ARGS.Get("idays"), ARGS.Get("day"), ARGS.Get("top"))
}

func (self *Model) isAdvertiserMiddlemanReport() bool {
	return self.ARGS.Get("_grole") == "adv" && self.ARGS.Get("adv_id") != ""
}

func (self *Model) TopicsMidTopSlots(extra ...url.Values) error {
	ARGS := self.ARGS
	return self.SelectSQL(self.LISTS,
		`SELECT m.slot_id, s.slot_name, ANY_VALUE(m.site_id) AS site_id, ANY_VALUE(m.pub_id) AS pub_id,
SUM(m.pay_spend) AS spend, SUM(m.imps) AS imps, SUM(m.clis) AS clis,
COALESCE(SUM(m.pay_spend)*1000/NULLIF(SUM(m.imps),0), 0) AS cpm,
COALESCE(SUM(m.pay_spend)/NULLIF(SUM(m.clis),0), 0) AS cpc,
COALESCE(SUM(m.clis)/NULLIF(SUM(m.imps),0), 0) AS ctr
FROM daily_mid m
INNER JOIN daily_log l USING (log_id)
LEFT JOIN pub_slot s USING (slot_id)
WHERE m.adv_id=? AND (l.daily BETWEEN DATE_SUB(?, INTERVAL ? DAY) AND ?)
GROUP BY m.slot_id, s.slot_name
ORDER BY spend DESC LIMIT ?`,
		ARGS.Get("adv_id"), ARGS.Get("day"), ARGS.Get("idays"), ARGS.Get("day"), ARGS.Get("top"))
}

func (self *Model) TopicsMidTopRoutes(extra ...url.Values) error {
	ARGS := self.ARGS
	return self.SelectSQL(self.LISTS,
		`SELECT m.group_id, g.group_name, m.route_bidder_id, m.target_id,
SUM(m.wins) AS wins, SUM(m.losses) AS losses, SUM(m.imps) AS imps, SUM(m.clis) AS clis,
SUM(m.charge_spend) AS charge_spend, SUM(m.pay_spend) AS pay_spend, SUM(m.margin_spend) AS margin_spend,
COALESCE(SUM(m.margin_spend)/NULLIF(SUM(m.charge_spend),0), 0) AS margin_rate,
SUM(m.forward_missing + m.forward_error + m.forward_http_error + m.forward_invalid) AS forward_errors
FROM daily_mid m
INNER JOIN daily_log l USING (log_id)
LEFT JOIN mid_route_group g USING (group_id)
WHERE l.daily BETWEEN DATE_SUB(?, INTERVAL ? DAY) AND ?
GROUP BY m.group_id, g.group_name, m.route_bidder_id, m.target_id
ORDER BY margin_spend DESC LIMIT ?`,
		ARGS.Get("day"), ARGS.Get("idays"), ARGS.Get("day"), ARGS.Get("top"))
}

func (self *Model) TopicsMidTopPublishers(extra ...url.Values) error {
	ARGS := self.ARGS
	return self.SelectSQL(self.LISTS,
		`SELECT m.pub_id, p.email AS pub_email, ANY_VALUE(m.site_id) AS site_id, ANY_VALUE(m.slot_id) AS slot_id,
SUM(m.wins) AS wins, SUM(m.losses) AS losses, SUM(m.imps) AS imps, SUM(m.clis) AS clis,
SUM(m.charge_spend) AS charge_spend, SUM(m.pay_spend) AS pay_spend, SUM(m.margin_spend) AS margin_spend,
COALESCE(SUM(m.margin_spend)/NULLIF(SUM(m.charge_spend),0), 0) AS margin_rate,
SUM(m.forward_missing + m.forward_error + m.forward_http_error + m.forward_invalid) AS forward_errors
FROM daily_mid m
INNER JOIN daily_log l USING (log_id)
LEFT JOIN pub p USING (pub_id)
WHERE l.daily BETWEEN DATE_SUB(?, INTERVAL ? DAY) AND ?
GROUP BY m.pub_id, p.email
ORDER BY charge_spend DESC LIMIT ?`,
		ARGS.Get("day"), ARGS.Get("idays"), ARGS.Get("day"), ARGS.Get("top"))
}
