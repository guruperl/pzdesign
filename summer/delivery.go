package summer

import (
	"fmt"
	"net/url"
	"strconv"
	"strings"
	"time"

	"github.com/guruperl/aofei/accounting"
	"github.com/guruperl/genelet"
)

const deliveryHoursPerWeek = 7 * 24

type DeliveryHour struct {
	Index    int
	Hour     int
	Selected bool
}

type DeliveryDay struct {
	Label string
	Hours []DeliveryHour
}

func ApplyDeliveryForm(args url.Values, campaign bool) error {
	if args == nil {
		return fmt.Errorf("delivery form is missing")
	}
	if campaign {
		timezone := strings.TrimSpace(args.Get("delivery_timezone"))
		if timezone == "" {
			timezone = "UTC"
		}
		if len(timezone) >= 64 {
			return fmt.Errorf("投放时区名称过长")
		}
		if _, err := time.LoadLocation(timezone); err != nil {
			return fmt.Errorf("投放时区无效：%s", timezone)
		}
		args.Set("delivery_timezone", timezone)
	}
	pacing := strings.TrimSpace(args.Get("pacing_mode"))
	if pacing == "" {
		pacing = "Fast"
	}
	if pacing != "Fast" && pacing != "Even" {
		return fmt.Errorf("投放节奏必须为尽快投放或均匀投放")
	}
	args.Set("pacing_mode", pacing)

	if args.Get("weekly_schedule_enabled") != "1" {
		args.Set("weekly_schedule", "")
	} else {
		schedule := []byte(strings.Repeat("0", deliveryHoursPerWeek))
		selected := 0
		for _, raw := range args["weekly_hour"] {
			hour, err := strconv.Atoi(raw)
			if err != nil || hour < 0 || hour >= deliveryHoursPerWeek {
				return fmt.Errorf("每周投放时段编号无效：%q", raw)
			}
			if schedule[hour] == '0' {
				schedule[hour] = '1'
				selected++
			}
		}
		if selected == 0 {
			return fmt.Errorf("启用每周投放时段时，至少选择一个小时")
		}
		args.Set("weekly_schedule", string(schedule))
	}
	args.Del("weekly_hour")
	args.Del("weekly_schedule_enabled")
	return validateDeliveryRange(args)
}

func validateDeliveryRange(args url.Values) error {
	start, hasStart, err := parseDeliveryTime(args.Get("startx"))
	if err != nil {
		return fmt.Errorf("开始时间无效：%w", err)
	}
	end, hasEnd, err := parseDeliveryTime(args.Get("endx"))
	if err != nil {
		return fmt.Errorf("结束时间无效：%w", err)
	}
	if hasStart && hasEnd && end.Before(start) {
		return fmt.Errorf("结束时间不能早于开始时间")
	}
	if hasStart {
		args.Set("startx", start.UTC().Format("2006-01-02 15:04:05"))
	}
	if hasEnd {
		args.Set("endx", end.UTC().Format("2006-01-02 15:04:05"))
	}
	return nil
}

func parseDeliveryTime(value string) (time.Time, bool, error) {
	value = strings.TrimSpace(value)
	if value == "" {
		return time.Time{}, false, nil
	}
	for _, layout := range []string{"2006-01-02 15:04:05", "2006-01-02T15:04", "2006-01-02"} {
		if parsed, err := time.ParseInLocation(layout, value, time.UTC); err == nil {
			return parsed, true, nil
		}
	}
	return time.Time{}, true, fmt.Errorf("请使用 YYYY-MM-DD HH:MM:SS（UTC）")
}

func ValidateBalanceLimits(args url.Values) error {
	for _, name := range []string{"limit_spend", "daily_spend"} {
		value := strings.TrimSpace(args.Get(name))
		if value == "" {
			continue
		}
		amount, err := accounting.ParseNano(value)
		if err != nil || amount < 0 {
			return fmt.Errorf("费用限额必须为最多九位小数的精确非负数")
		}
		args.Set(name, amount.String())
	}
	for _, name := range []string{"limit_imp", "limit_cli", "daily_imp", "daily_cli"} {
		value := strings.TrimSpace(args.Get(name))
		if value == "" {
			continue
		}
		if _, err := strconv.ParseUint(value, 10, 32); err != nil {
			return fmt.Errorf("曝光和点击限额必须为非负整数")
		}
	}
	return nil
}

func DeliveryScheduleRows(value interface{}, chinese bool) []DeliveryDay {
	schedule := strings.TrimSpace(genelet.Interface2String(value))
	configured := len(schedule) == deliveryHoursPerWeek
	labels := []string{"Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"}
	if chinese {
		labels = []string{"星期一", "星期二", "星期三", "星期四", "星期五", "星期六", "星期日"}
	}
	rows := make([]DeliveryDay, 7)
	for day := range rows {
		rows[day].Label = labels[day]
		rows[day].Hours = make([]DeliveryHour, 24)
		for hour := 0; hour < 24; hour++ {
			index := day*24 + hour
			rows[day].Hours[hour] = DeliveryHour{
				Index:    index,
				Hour:     hour,
				Selected: !configured || schedule[index] == '1',
			}
		}
	}
	return rows
}

func DeliveryScheduleEnabled(value interface{}) bool {
	return len(strings.TrimSpace(genelet.Interface2String(value))) == deliveryHoursPerWeek
}
