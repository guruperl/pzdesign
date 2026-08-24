package midroute

import (
	"fmt"
	"net/url"
	"strconv"
	"strings"

	"github.com/guruperl/aofei/accounting"
	"github.com/guruperl/pzdesign/summer"
)

type Filter struct {
	summer.Filter
}

const (
	defaultRouteTimeoutMS = 100
	maxRouteTimeoutMS     = 5000
	maxSmallintUnsigned   = 65535
)

func (self *Filter) Preset() error {
	if err := self.Filter.Preset(); err != nil {
		return err
	}
	return normalizeActionFields(self.R.Form, self.Action)
}

func normalizeActionFields(form url.Values, action string) error {
	switch action {
	case "insert", "update":
		return normalizeGroupFields(form, action)
	case "insertBidder", "updateBidder":
		return normalizeRouteBidderFields(form, action)
	case "insertTarget", "updateTarget":
		return normalizeRouteTargetFields(form, action)
	default:
		return nil
	}
}

func normalizeGroupFields(form url.Values, action string) error {
	if action == "insert" {
		if form.Get("group_name") == "" {
			return fmt.Errorf("group_name is required")
		}
		if err := normalizeChoice(form, "trigger_mode", "Fallback", "Fallback", "Always"); err != nil {
			return err
		}
		if err := normalizeChoice(form, "active", "Yes", "Yes", "No"); err != nil {
			return err
		}
		if err := normalizeInt(form, "total_timeout_ms", true, defaultRouteTimeoutMS, 1, maxRouteTimeoutMS); err != nil {
			return err
		}
		if err := normalizeDecimal(form, "margin_pct", true, "0", 0, 1); err != nil {
			return err
		}
		return normalizeCPM(form, "min_margin_cpm", true, "0", 100000)
	}
	if form.Has("group_name") && form.Get("group_name") == "" {
		return fmt.Errorf("group_name is required")
	}
	if err := normalizeOptionalChoice(form, "trigger_mode", "Fallback", "Always"); err != nil {
		return err
	}
	if err := normalizeOptionalChoice(form, "active", "Yes", "No"); err != nil {
		return err
	}
	if err := normalizePresentInt(form, "total_timeout_ms", 1, maxRouteTimeoutMS); err != nil {
		return err
	}
	if err := normalizePresentDecimal(form, "margin_pct", 0, 1); err != nil {
		return err
	}
	return normalizePresentCPM(form, "min_margin_cpm", 100000)
}

func normalizeRouteBidderFields(form url.Values, action string) error {
	if action == "insertBidder" {
		if form.Get("bidder_id") == "" {
			return fmt.Errorf("bidder_id is required")
		}
		if err := normalizeChoice(form, "active", "Yes", "Yes", "No"); err != nil {
			return err
		}
		if err := normalizeInt(form, "bidder_id", false, 0, 1, 1<<31-1); err != nil {
			return err
		}
		if err := normalizeInt(form, "priority", true, 100, 1, maxSmallintUnsigned); err != nil {
			return err
		}
		if err := normalizeOptionalInt(form, "timeout_ms", 1, maxRouteTimeoutMS); err != nil {
			return err
		}
		if err := normalizeOptionalDecimal(form, "margin_pct", 0, 1); err != nil {
			return err
		}
		return normalizeOptionalCPM(form, "min_margin_cpm", 100000)
	}
	if form.Has("bidder_id") && form.Get("bidder_id") == "" {
		return fmt.Errorf("bidder_id is required")
	}
	if err := normalizeOptionalChoice(form, "active", "Yes", "No"); err != nil {
		return err
	}
	if err := normalizePresentInt(form, "bidder_id", 1, 1<<31-1); err != nil {
		return err
	}
	if err := normalizePresentInt(form, "priority", 1, maxSmallintUnsigned); err != nil {
		return err
	}
	if err := normalizeOptionalInt(form, "timeout_ms", 1, maxRouteTimeoutMS); err != nil {
		return err
	}
	if err := normalizeOptionalDecimal(form, "margin_pct", 0, 1); err != nil {
		return err
	}
	return normalizeOptionalCPM(form, "min_margin_cpm", 100000)
}

func normalizeRouteTargetFields(form url.Values, action string) error {
	if action == "insertTarget" {
		if err := normalizeChoice(form, "active", "Yes", "Yes", "No"); err != nil {
			return err
		}
		if err := normalizeInt(form, "priority", true, 100, 1, maxSmallintUnsigned); err != nil {
			return err
		}
	} else {
		if err := normalizeOptionalChoice(form, "active", "Yes", "No"); err != nil {
			return err
		}
		if err := normalizePresentInt(form, "priority", 1, maxSmallintUnsigned); err != nil {
			return err
		}
	}
	if err := normalizeOptionalInt(form, "size_id", 1, 1<<31-1); err != nil {
		return err
	}
	if action != "insertTarget" && !form.Has("entitytype_id") && !form.Has("entity_id") {
		return nil
	}
	entityType := form.Get("entitytype_id")
	entityID := form.Get("entity_id")
	if entityType == "" && entityID == "" {
		return nil
	}
	if entityType == "" || entityID == "" {
		return fmt.Errorf("entitytype_id and entity_id must be set together")
	}
	switch entityType {
	case "3", "31", "32":
	default:
		return fmt.Errorf("entitytype_id must be 3, 31, or 32")
	}
	return normalizeOptionalInt(form, "entity_id", 1, 1<<31-1)
}

func normalizeOptionalChoice(form url.Values, name string, allowed ...string) error {
	if !form.Has(name) {
		return nil
	}
	value := form.Get(name)
	for _, candidate := range allowed {
		if value == candidate {
			return nil
		}
	}
	return fmt.Errorf("%s is invalid", name)
}

func normalizeChoice(form url.Values, name, def string, allowed ...string) error {
	value := form.Get(name)
	if value == "" {
		form.Set(name, def)
		return nil
	}
	for _, candidate := range allowed {
		if value == candidate {
			return nil
		}
	}
	return fmt.Errorf("%s is invalid", name)
}

func normalizeInt(form url.Values, name string, required bool, def, min, max int) error {
	value := form.Get(name)
	if value == "" {
		if required {
			form.Set(name, strconv.Itoa(def))
		}
		return nil
	}
	n, err := strconv.Atoi(value)
	if err != nil || n < min || n > max {
		return fmt.Errorf("%s must be between %d and %d", name, min, max)
	}
	form.Set(name, strconv.Itoa(n))
	return nil
}

func normalizePresentInt(form url.Values, name string, min, max int) error {
	if !form.Has(name) {
		return nil
	}
	value := form.Get(name)
	if value == "" {
		return fmt.Errorf("%s is required", name)
	}
	n, err := strconv.Atoi(value)
	if err != nil || n < min || n > max {
		return fmt.Errorf("%s must be between %d and %d", name, min, max)
	}
	form.Set(name, strconv.Itoa(n))
	return nil
}

func normalizeOptionalInt(form url.Values, name string, min, max int) error {
	value := form.Get(name)
	if value == "" {
		return nil
	}
	n, err := strconv.Atoi(value)
	if err != nil || n < min || n > max {
		return fmt.Errorf("%s must be between %d and %d", name, min, max)
	}
	form.Set(name, strconv.Itoa(n))
	return nil
}

func normalizeDecimal(form url.Values, name string, required bool, def string, min, max float64) error {
	value := strings.TrimSpace(form.Get(name))
	if value == "" {
		if required {
			value = def
		} else {
			return nil
		}
	}
	units, err := parseFraction4(value)
	if err != nil || min != 0 || max != 1 {
		return fmt.Errorf("%s must be between %.4f and %.4f", name, min, max)
	}
	form.Set(name, fmt.Sprintf("%d.%04d", units/10000, units%10000))
	return nil
}

func normalizePresentDecimal(form url.Values, name string, min, max float64) error {
	if !form.Has(name) {
		return nil
	}
	value := strings.TrimSpace(form.Get(name))
	if value == "" {
		return fmt.Errorf("%s is required", name)
	}
	units, err := parseFraction4(value)
	if err != nil || min != 0 || max != 1 {
		return fmt.Errorf("%s must be between %.4f and %.4f", name, min, max)
	}
	form.Set(name, fmt.Sprintf("%d.%04d", units/10000, units%10000))
	return nil
}

func normalizeOptionalDecimal(form url.Values, name string, min, max float64) error {
	return normalizeDecimal(form, name, false, "", min, max)
}

func parseFraction4(raw string) (uint64, error) {
	parts := strings.Split(strings.TrimSpace(raw), ".")
	if len(parts) > 2 || parts[0] == "" || len(parts) == 2 && len(parts[1]) > 4 {
		return 0, fmt.Errorf("invalid four-place fraction")
	}
	whole, err := strconv.ParseUint(parts[0], 10, 64)
	if err != nil {
		return 0, err
	}
	fraction := ""
	if len(parts) == 2 {
		fraction = parts[1]
	}
	for len(fraction) < 4 {
		fraction += "0"
	}
	frac := uint64(0)
	if fraction != "" {
		frac, err = strconv.ParseUint(fraction, 10, 64)
		if err != nil {
			return 0, err
		}
	}
	if whole > 1 || whole == 1 && frac != 0 {
		return 0, fmt.Errorf("fraction is outside zero through one")
	}
	return whole*10000 + frac, nil
}

func normalizeCPM(form url.Values, name string, required bool, def string, maxWhole int64) error {
	value := strings.TrimSpace(form.Get(name))
	if value == "" {
		if required {
			value = def
		} else {
			return nil
		}
	}
	cpm, err := accounting.ParseCPM(value)
	if err != nil || cpm > accounting.CPM(maxWhole*accounting.CPMScale) {
		return fmt.Errorf("%s must be an exact USD CPM from 0 through %d with at most six decimal places", name, maxWhole)
	}
	form.Set(name, cpm.String())
	return nil
}

func normalizePresentCPM(form url.Values, name string, maxWhole int64) error {
	if !form.Has(name) {
		return nil
	}
	if strings.TrimSpace(form.Get(name)) == "" {
		return fmt.Errorf("%s is required", name)
	}
	return normalizeCPM(form, name, false, "", maxWhole)
}

func normalizeOptionalCPM(form url.Values, name string, maxWhole int64) error {
	return normalizeCPM(form, name, false, "", maxWhole)
}
