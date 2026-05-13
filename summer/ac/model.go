// Package ac handles access control relationship
//
// NEW
// pub.3, accepts adv.  4
// pub.3, accepts camp  41
// adv.4, accepts pub.  3
// adv.4, accepts site  31
//
//	 1 | admin        | admin_id    |
//	 3 | pub          | pub_id      |
//	 4 | adv          | adv_id      |
//	 5 | anon         | anon_id     |
//	31 | pub_site     | site_id     |
//	32 | pub_slot     | slot_id     |
//	41 | adv_campaign | campaign_id |
//	42 | adv_item     | item_id     |
//
// OLD
// publisher 3, can block advertiser 4
// publisher's site 31, can block advertiser 4
// advertiser 4, can block site 31
// advertiser's campaign 41, can block site 31
package ac

import (
	"database/sql"
	"fmt"
	"net/url"
	"strings"

	"github.com/guruperl/pzdesign/summer"
)

type Model struct {
	summer.Model
}

func uniqueDigits(values []string) []string {
	found := make(map[string]bool)
	out := make([]string, 0, len(values))
	for _, id := range values {
		if found[id] || !summer.IsDigit(id) {
			continue
		}
		found[id] = true
		out = append(out, id)
	}
	return out
}

func placeholders(n int) string {
	if n <= 0 {
		return ""
	}
	return strings.TrimRight(strings.Repeat("?,", n), ",")
}

func appendStrings(out []interface{}, values []string) []interface{} {
	for _, value := range values {
		out = append(out, value)
	}
	return out
}

func (self *Model) accessTarget() (string, string, error) {
	parts, ok := summer.TABLES[self.ARGS.Get("entitytype_id")]
	if !ok || len(parts) != 2 {
		return "", "", fmt.Errorf("unknown entitytype_id %q", self.ARGS.Get("entitytype_id"))
	}
	return parts[0], parts[1], nil
}

func (self *Model) Delete(extra ...url.Values) error {
	ARGS := self.ARGS

	return self.DoSQL(`
DELETE FROM ac
WHERE ac_id=? AND entitytype_id=? AND entity_id=?`,
		ARGS.Get("ac_id"), ARGS.Get("entitytype_id"), ARGS.Get("entity_id"))
}

func (self *Model) Insert(extra ...url.Values) error {
	ARGS := self.ARGS

	var acID int
	err := self.DB.QueryRow(`
SELECT ac_id FROM ac WHERE entitytype_id=? AND entity_id=? AND othertype_id=? AND other_id=?`,
		ARGS.Get("entitytype_id"), ARGS.Get("entity_id"), ARGS.Get("othertype_id"), ARGS.Get("other_id")).Scan(&acID)
	if err == sql.ErrNoRows {
		return self.Model.Model.Insert(extra...)
	}

	return nil
}

func (self *Model) Inserts(extra ...url.Values) error {
	ARGS := self.ARGS

	ads := uniqueDigits(ARGS["adv_ids"])
	campaigns := uniqueDigits(ARGS["campaign_ids"])

	ref := make(map[string]bool)
	if len(ads) > 0 && len(campaigns) > 0 {
		lists := make([]map[string]interface{}, 0)
		args := make([]interface{}, 0, len(campaigns)+len(ads))
		args = appendStrings(args, campaigns)
		args = appendStrings(args, ads)
		err := self.SelectSQL(&lists, `
SELECT campaign_id
FROM adv_campaign
WHERE campaign_id IN (`+placeholders(len(campaigns))+`) AND adv_id IN (`+placeholders(len(ads))+`)`, args...)
		if err != nil {
			return err
		}
		for _, item := range lists {
			ref[fmt.Sprintf("%v", item["campaign_id"])] = true
		}
	}

	values := make([]string, 0, len(ads)+len(campaigns))
	args := make([]interface{}, 0, (len(ads)+len(campaigns))*4)
	for _, advID := range ads {
		values = append(values, "(?, ?, 4, ?)")
		args = append(args, ARGS.Get("entitytype_id"), ARGS.Get("entity_id"), advID)
	}
	for _, campaignID := range campaigns {
		if ref[campaignID] {
			continue
		}
		values = append(values, "(?, ?, 41, ?)")
		args = append(args, ARGS.Get("entitytype_id"), ARGS.Get("entity_id"), campaignID)
	}
	if len(values) == 0 {
		return nil
	}
	err := self.DoSQL(`
DELETE FROM ac WHERE entitytype_id=? AND entity_id=?`, ARGS.Get("entitytype_id"), ARGS.Get("entity_id"))
	if err != nil {
		return err
	}
	return self.DoSQL(`INSERT INTO ac (entitytype_id, entity_id, othertype_id, other_id) VALUES `+strings.Join(values, ","), args...)
}

func (self *Model) UpdateOrder(extra ...url.Values) error {
	ARGS := self.ARGS
	table, idname, err := self.accessTarget()
	if err != nil {
		return err
	}

	err = self.DoSQL(`
DELETE FROM ac
WHERE entitytype_id=? AND entity_id=?`,
		ARGS.Get("entitytype_id"), ARGS.Get("entity_id"))
	if err != nil {
		return err
	}

	return self.DoSQL(`
UPDATE `+table+`
SET access_order=?
WHERE `+idname+`=?`,
		ARGS.Get("access_order"), ARGS.Get("entity_id"))
}

func (self *Model) getAccessOrder() error {
	ARGS := self.ARGS
	table, idname, err := self.accessTarget()
	if err != nil {
		return err
	}
	return self.GetArgs(ARGS, `
SELECT access_order FROM `+table+`
WHERE `+idname+`=?`, ARGS.Get("entity_id"))
}

func (self *Model) Topics(extra ...url.Values) error {
	ARGS := self.ARGS

	if err := self.getAccessOrder(); err != nil {
		return err
	}
	if ARGS.Get("access_order") == "Inherit" {
		return nil
	}

	if ARGS.Get("entitytype_id") == "3" || ARGS.Get("entitytype_id") == "31" {
		return self.SelectSQL(self.LISTS, `
SELECT ac_id, adv.adv_id, a.company, a.url, '*' AS campaign_id, '*' AS campaign_name, a.url
FROM ac
INNER JOIN adv ON (ac.othertype_id=4 AND ac.other_id=adv.adv_id)
INNER JOIN add_address a USING (address_id)
WHERE entitytype_id=? AND entity_id=?
UNION
SELECT ac_id, adv.adv_id, a.company, a.url, c.campaign_id, c.campaign_name, a.url
FROM ac
INNER JOIN adv_campaign c ON (ac.othertype_id=41 AND ac.other_id=c.campaign_id)
INNER JOIN adv USING (adv_id)
INNER JOIN add_address a USING (address_id)
WHERE entitytype_id=? AND entity_id=?`,
			ARGS.Get("entitytype_id"), ARGS.Get("entity_id"),
			ARGS.Get("entitytype_id"), ARGS.Get("entity_id"))
	}

	return self.SelectSQL(self.LISTS, `
SELECT ac_id, pub.pub_id, a.company, a.url, '*' AS site_id, '*' AS site_name, '*' AS site_url
FROM ac
INNER JOIN pub ON (ac.othertype_id=3 AND ac.other_id=pub_id)
INNER JOIN add_address a USING (address_id)
WHERE entitytype_id=? AND entity_id=?
UNION
SELECT ac_id, pub.pub_id, a.company, a.url, s.site_id, s.site_name, s.site_url
FROM ac
INNER JOIN pub_site s ON (ac.othertype_id=31 AND ac.other_id=s.site_id)
INNER JOIN pub USING (pub_id)
INNER JOIN add_address a USING (address_id)
WHERE entitytype_id=? AND entity_id=?`,
		ARGS.Get("entitytype_id"), ARGS.Get("entity_id"),
		ARGS.Get("entitytype_id"), ARGS.Get("entity_id"))
}

func (self *Model) Startnew(extra ...url.Values) error {
	ARGS := self.ARGS

	var err error
	if err = self.getAccessOrder(); err != nil {
		return err
	}
	if ARGS.Get("access_order") == "Inherit" {
		return nil
	}
	_, idname, err := self.accessTarget()
	if err != nil {
		return err
	}

	err = self.SelectSQL(self.LISTS, `
SELECT campaign_id, ANY_VALUE(campaign_name) AS campaign_name,
	ANY_VALUE(adv_id) AS adv_id, ANY_VALUE(adv_name) AS adv_name,
	ANY_VALUE(othertype_id) AS othertype_id, ANY_VALUE(other_id) AS other_id,
	ANY_VALUE(ac_id) AS ac_id
FROM ViewSlotOpen WHERE `+idname+`=?
GROUP BY campaign_id`, ARGS.Get("entity_id"))
	if err != nil {
		return err
	}

	return self.ProcessAfter("startnew", extra...)
}
