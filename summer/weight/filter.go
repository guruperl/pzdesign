// Package weight Description: weight filter.
package weight

import (
	"net/url"

	"github.com/guruperl/pzdesign/summer"
)

type Filter struct {
	summer.Filter
}

func (self *Filter) Preset() error {
	return self.Filter.Preset()
}

func (self *Filter) Before(model *Model, extra url.Values, nextextra url.Values) error {
	return self.Filter.Before(&model.Model, extra, nextextra)
}

func (self *Filter) After(model *Model) error {
	return self.Filter.After(&model.Model)
}
