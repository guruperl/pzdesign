package pub

import (
	"crypto/sha256"
	"encoding/hex"
	"fmt"
	"net/url"
	"strconv"
	"strings"

	"github.com/guruperl/aofei/acl"
	"github.com/guruperl/aofei/adminapi"
	"github.com/guruperl/genelet"
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
	who := self.RoleValue
	if ARGS.Get("_gadmin") == "1" {
		who = "admin"
	}
	if err := summer.RequireAccountEmail(self.C, who, action); err != nil {
		return err
	}

	if (who == "pub" && action == "updatepass") ||
		(who == "web" && (action == "insert" || action == "resetpass")) {
		if ARGS.Get("firstname") == "" {
			ARGS.Set("firstname", ARGS.Get("lastname"))
		}
		if ARGS.Get("passwd") == ARGS.Get("confirm") {
			if err := genelet.ValidatePassword(ARGS.Get("passwd")); err != nil {
				return err
			}
			if !(who == "pub" && action == "updatepass" && self.Identity != nil) {
				hash, err := genelet.HashPassword(ARGS.Get("passwd"))
				if err != nil {
					return err
				}
				ARGS.Set("passwd", hash)
			}
			ARGS.Del("confirm")
		} else {
			return genelet.Err(3102)
		}
	}

	if who == "web" && (action == "activate" || action == "startreset" || action == "resetpass") {
		if ARGS.Get("md5") != genelet.Digest(self.C.Secret, ARGS.Get("pub_id"), ARGS.Get("email"), ARGS.Get("stamp"), ARGS.Get("firstname"), ARGS.Get("lastname")) {
			return genelet.Err(3102)
		}
		if self.Identity != nil && (action == "startreset" || action == "resetpass") {
			if err := self.Identity.ValidateRecoveryTimestamp(ARGS.Get("stamp")); err != nil {
				return genelet.Err(3102)
			}
		}
	} else if who == "admin" && action == "insert" {
		// needed for validation but not actually passed to the db
		for _, str := range []string{"email", "passwd", "firstname", "lastname", "address_id", "active", "access_order"} {
			ARGS.Set(str, "1")
		}
	} else if who != "admin" && action == "update" {
		if ARGS.Get("active") != "" {
			ARGS.Del("active")
		}
	}
	if action == "update" && hasAnySellerField(ARGS) {
		seller := acl.SellerMetadata{
			ID:         strings.TrimSpace(ARGS.Get("seller_id")),
			Type:       strings.TrimSpace(ARGS.Get("seller_type")),
			ASI:        strings.TrimSpace(ARGS.Get("seller_asi")),
			Name:       strings.TrimSpace(ARGS.Get("seller_name")),
			Domain:     strings.TrimSpace(ARGS.Get("seller_domain")),
			Authorized: who == "admin" && ARGS.Get("seller_authorized") == "Yes",
		}
		if err := seller.Validate(); err != nil {
			return fmt.Errorf("invalid seller transparency metadata: %w", err)
		}
		if who != "admin" {
			ARGS.Set("seller_authorized", "No")
		}
		for key, value := range map[string]string{
			"seller_id": seller.ID, "seller_type": seller.Type, "seller_asi": seller.ASI,
			"seller_name": seller.Name, "seller_domain": seller.Domain,
		} {
			ARGS.Set(key, value)
		}
	}

	return nil
}

func hasAnySellerField(values url.Values) bool {
	for _, name := range []string{"seller_id", "seller_type", "seller_asi", "seller_name", "seller_domain", "seller_authorized"} {
		if _, ok := values[name]; ok {
			return true
		}
	}
	return false
}

func (self *Filter) Before(model *Model, extra url.Values, nextextra url.Values) error {
	if err := self.Filter.Before(&model.Model, extra, nextextra); err != nil {
		return err
	}

	action := self.Action
	who := self.RoleValue
	ARGS := self.R.Form
	if ARGS.Get("_gadmin") == "1" {
		who = "admin"
	}
	if action == "update" && hasAnySellerField(ARGS) {
		if who == "admin" && strings.TrimSpace(ARGS.Get("reason")) == "" {
			return fmt.Errorf("seller authorization requires an audited reason")
		}
		prior := make(map[string]interface{})
		if err := model.GetSQL(prior, `SELECT seller_id, seller_type, seller_asi, seller_name, seller_domain, seller_authorized FROM pub WHERE pub_id=?`, ARGS.Get("pub_id")); err != nil {
			return err
		}
		(*model.OTHER)["security_seller_prior"] = prior
	}

	if who == "admin" && action == "insert" {
		p, err := adminapi.AddPub(model.DB, ARGS.Get("domain"))
		if err != nil {
			return err
		}
		ARGS.Set("pub_id", strconv.FormatInt(int64(p.PubID), 10))
		dbi := genelet.DBI{DB: model.DB}
		err = dbi.DoSQL(`
INSERT INTO adv_balance (limit_imp, created) VALUES (?, NOW())`, ARGS.Get("limit_imp"))
		if err != nil {
			return err
		}
		ARGS.Set("total_balance_id", strconv.FormatInt(dbi.LastID, 10))
	} else if who == "web" && action == "insert" {
		if err := model.Randomid("pub", "pub_id", 0, 16777216, 10); err != nil {
			return err
		}
	} else if who != "admin" && action == "update" {
		model.CurrentTable = "adv_balance"
		if err := self.BalanceBefore(&model.Model); err != nil {
			return err
		}
		model.CurrentTable = "pub"
	}

	return nil
}

func (self *Filter) After(model *Model) error {
	if err := self.Filter.After(&model.Model); err != nil {
		return err
	}

	ARGS := self.R.Form
	action := self.Action
	who := self.RoleValue
	lists := *model.LISTS
	other := *model.OTHER
	if action == "update" {
		if prior, ok := other["security_seller_prior"].(map[string]interface{}); ok {
			current := make(map[string]interface{})
			if err := model.GetSQL(current, `SELECT seller_id, seller_type, seller_asi, seller_name, seller_domain, seller_authorized FROM pub WHERE pub_id=?`, ARGS.Get("pub_id")); err != nil {
				return err
			}
			priorAuthorization := genelet.Interface2String(prior["seller_authorized"])
			currentAuthorization := genelet.Interface2String(current["seller_authorized"])
			ARGS.Set("_gaudit_prior_state", "SellerAuthorized="+priorAuthorization)
			ARGS.Set("_gaudit_new_state", "SellerAuthorized="+currentAuthorization)
			ARGS.Set("_gaudit_object_hash", sellerTupleHash(current))
			if who == "admin" {
				ARGS.Set("_gaudit_event", "SellerAuthorizationReviewed")
				ARGS.Set("_gaudit_reason", strings.TrimSpace(ARGS.Get("reason")))
			} else {
				ARGS.Set("_gaudit_event", "PublisherSupplyMetadataProposed")
				ARGS.Set("_gaudit_reason", "Publisher supply metadata proposal")
			}
			delete(other, "security_seller_prior")
		}
	}

	if action == "topics" {
		for _, item := range lists {
			item["created"] = summer.DateDisplay(item["created"])
		}
	} else if who == "web" && action == "insert" {
		email := ARGS.Get("email")
		ARGS.Set("stamp", ARGS.Get("_gtime"))
		ARGS.Set("md5", genelet.Digest(self.C.Secret, ARGS.Get("pub_id"), email, ARGS.Get("stamp"), ARGS.Get("firstname"), ARGS.Get("lastname")))
		ARGS.Set("serverUrl", self.C.ServerURL)
		other["_gmail"] = map[string]interface{}{
			"To":      email,
			"Subject": "W8M 流量方账户邮箱验证",
			"file":    self.C.Template + "/" + who + "/pub/insert.mail." + self.ChartagValue}
	} else if who == "web" && action == "retrieve" && len(lists) > 0 {
		item := lists[0]
		email := item["email"].(string)
		pubID := strconv.FormatInt(item["pub_id"].(int64), 10)
		ARGS.Set("stamp", ARGS.Get("_gtime"))
		ARGS.Set("md5", genelet.Digest(self.C.Secret, pubID, email, ARGS.Get("stamp"), item["firstname"].(string), item["lastname"].(string)))
		ARGS.Set("serverUrl", self.C.ServerURL)
		other["_gmail"] = map[string]interface{}{
			"To":      email,
			"Subject": "W8M 流量方账户密码重置",
			"file":    self.C.Template + "/" + who + "/pub/retrieve.mail." + self.ChartagValue}
	}

	return nil
}

func sellerTupleHash(values map[string]interface{}) string {
	parts := make([]string, 0, 5)
	for _, key := range []string{"seller_id", "seller_type", "seller_asi", "seller_name", "seller_domain"} {
		parts = append(parts, genelet.Interface2String(values[key]))
	}
	digest := sha256.Sum256([]byte(strings.Join(parts, "\x00")))
	return hex.EncodeToString(digest[:])
}
