package bidder

import (
	"fmt"
	"net"
	"net/url"
	"strconv"
	"strings"

	"github.com/guruperl/aofei/match"
	"github.com/guruperl/pzdesign/summer"
)

type Filter struct {
	summer.Filter
}

const (
	defaultTimeoutMS = 100
	maxTimeoutMS     = 5000
)

func (self *Filter) Preset() error {
	if err := self.Filter.Preset(); err != nil {
		return err
	}

	if self.RoleValue != "admin" {
		ARGS := self.R.Form
		ARGS.Del("synthetic_campaign_id")
		ARGS.Del("synthetic_item_id")
		ARGS.Del("synthetic_creative_id")
		ARGS.Del("credential_ref")
		ARGS.Del("credential_status")
		ARGS.Del("active")
	}
	return validateEndpointFields(self.R.Form, self.Action)
}

func validateEndpointFields(form url.Values, action string) error {
	if action != "insert" && action != "update" {
		return nil
	}
	if err := validateEndpointURL(form, action); err != nil {
		return err
	}
	if err := normalizeOpenRTBVersion(form, action); err != nil {
		return err
	}
	if err := normalizeSeat(form); err != nil {
		return err
	}
	if err := normalizeCredentialReference(form); err != nil {
		return err
	}
	return normalizeTimeout(form, action)
}

func normalizeCredentialReference(form url.Values) error {
	raw, ok := form["credential_ref"]
	if !ok {
		return nil
	}
	value := ""
	if len(raw) != 0 {
		value = raw[0]
	}
	if value == "" {
		return nil
	}
	if !match.ValidMiddlemanCredentialRefName(value) {
		return fmt.Errorf("credential_ref must be an environment variable name")
	}
	form.Set("credential_ref", value)
	return nil
}

func validateEndpointURL(form url.Values, action string) error {
	raw, ok := form["endpoint_url"]
	if !ok {
		return nil
	}
	endpoint := ""
	if len(raw) > 0 {
		endpoint = raw[0]
	}
	if endpoint == "" {
		if action == "insert" {
			return fmt.Errorf("endpoint_url is required")
		}
		return nil
	}
	parsed, err := url.Parse(endpoint)
	if err != nil || !parsed.IsAbs() || parsed.Host == "" {
		return fmt.Errorf("endpoint_url must be an absolute http or https URL")
	}
	if parsed.Scheme != "http" && parsed.Scheme != "https" {
		return fmt.Errorf("endpoint_url must use http or https")
	}
	if parsed.User != nil {
		return fmt.Errorf("endpoint_url must not contain user info")
	}
	if parsed.Fragment != "" {
		return fmt.Errorf("endpoint_url must not contain a fragment")
	}
	if host := parsed.Hostname(); host == "" {
		return fmt.Errorf("endpoint_url must include a host")
	} else if ip := net.ParseIP(host); ip == nil && !validEndpointHostname(host) {
		return fmt.Errorf("endpoint_url host is invalid")
	}
	return nil
}

func normalizeOpenRTBVersion(form url.Values, action string) error {
	raw, ok := form["openrtb_version"]
	if !ok {
		if action == "insert" {
			form.Set("openrtb_version", "2.5")
		}
		return nil
	}
	version := ""
	if len(raw) != 0 {
		version = strings.TrimSpace(raw[0])
	}
	if version == "" && action == "insert" {
		version = "2.5"
	}
	if version != "2.5" {
		return fmt.Errorf("openrtb_version must be exactly 2.5")
	}
	form.Set("openrtb_version", version)
	return nil
}

func normalizeSeat(form url.Values) error {
	raw, ok := form["seat"]
	if !ok {
		return nil
	}
	seat := ""
	if len(raw) != 0 {
		seat = strings.TrimSpace(raw[0])
	}
	if len(seat) > 128 || strings.IndexFunc(seat, func(r rune) bool { return r < 0x20 || r == 0x7f }) >= 0 {
		return fmt.Errorf("seat must be at most 128 bytes without control characters")
	}
	form.Set("seat", seat)
	return nil
}

func validEndpointHostname(host string) bool {
	for _, r := range host {
		if (r >= 'a' && r <= 'z') || (r >= 'A' && r <= 'Z') ||
			(r >= '0' && r <= '9') || r == '-' || r == '.' {
			continue
		}
		return false
	}
	return true
}

func normalizeTimeout(form url.Values, action string) error {
	raw, ok := form["timeout_ms"]
	if !ok {
		if action == "insert" {
			form.Set("timeout_ms", strconv.Itoa(defaultTimeoutMS))
		}
		return nil
	}
	timeout := ""
	if len(raw) > 0 {
		timeout = raw[0]
	}
	if timeout == "" {
		if action == "insert" {
			form.Set("timeout_ms", strconv.Itoa(defaultTimeoutMS))
		}
		return nil
	}
	n, err := strconv.Atoi(timeout)
	if err != nil || n <= 0 || n > maxTimeoutMS {
		return fmt.Errorf("timeout_ms must be between 1 and %d", maxTimeoutMS)
	}
	form.Set("timeout_ms", strconv.Itoa(n))
	return nil
}

func (self *Filter) Before(model *Model, extra url.Values, nextextra url.Values) error {
	if err := self.Filter.Before(&model.Model, extra, nextextra); err != nil {
		return err
	}

	if self.RoleValue == "adv" {
		advID := self.R.Form.Get("adv_id")
		extra.Set("adv_id", advID)
		if self.Action == "insert" {
			self.R.Form.Set("adv_id", advID)
			self.R.Form.Set("credential_status", "Missing")
			self.R.Form.Set("active", "No")
		}
	}
	return nil
}

func (self *Filter) After(model *Model) error {
	if err := self.Filter.After(&model.Model); err != nil {
		return err
	}
	if self.RoleValue != "admin" {
		for _, item := range *model.LISTS {
			for _, field := range operatorFields {
				delete(item, field)
			}
		}
	}
	return nil
}

var operatorFields = []string{
	"synthetic_campaign_id",
	"synthetic_item_id",
	"synthetic_creative_id",
	"credential_ref",
}
