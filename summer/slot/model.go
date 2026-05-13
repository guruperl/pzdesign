package slot

import (
	"net/url"

	"github.com/guruperl/pzdesign/summer"
)

type Model struct {
	summer.Model
}

func (self *Model) Startnew(extra ...url.Values) error {
	return self.ProcessAfter("startnew", extra...)
}
