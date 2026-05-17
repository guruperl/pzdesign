package registry

import (
	"github.com/guruperl/genelet"
	"github.com/guruperl/pzdesign/summer/ac"
	"github.com/guruperl/pzdesign/summer/address"
	"github.com/guruperl/pzdesign/summer/adv"
	"github.com/guruperl/pzdesign/summer/agent"
	"github.com/guruperl/pzdesign/summer/alipay"
	"github.com/guruperl/pzdesign/summer/attrname"
	"github.com/guruperl/pzdesign/summer/balance"
	"github.com/guruperl/pzdesign/summer/bidder"
	"github.com/guruperl/pzdesign/summer/campaign"
	"github.com/guruperl/pzdesign/summer/cc"
	"github.com/guruperl/pzdesign/summer/chac"
	"github.com/guruperl/pzdesign/summer/channel"
	"github.com/guruperl/pzdesign/summer/cheque"
	"github.com/guruperl/pzdesign/summer/creative"
	"github.com/guruperl/pzdesign/summer/item"
	"github.com/guruperl/pzdesign/summer/ledger"
	"github.com/guruperl/pzdesign/summer/manage"
	"github.com/guruperl/pzdesign/summer/midroute"
	"github.com/guruperl/pzdesign/summer/payment"
	"github.com/guruperl/pzdesign/summer/pub"
	"github.com/guruperl/pzdesign/summer/site"
	"github.com/guruperl/pzdesign/summer/slot"
	"github.com/guruperl/pzdesign/summer/targetname"
	"github.com/guruperl/pzdesign/summer/wechat"
	"github.com/guruperl/pzdesign/summer/weight"
	"go.uber.org/zap"
)

type Entry struct {
	Name       string
	NewModel   func() interface{}
	NewStorage func() interface{}
	NewFilter  func() interface{}
}

var Entries = []Entry{
	{"ac", func() interface{} { return new(ac.Model) }, func() interface{} { return new(ac.Model) }, func() interface{} { return new(ac.Filter) }},
	{"address", func() interface{} { return new(address.Model) }, func() interface{} { return new(address.Model) }, func() interface{} { return new(address.Filter) }},
	{"adv", func() interface{} { return new(adv.Model) }, func() interface{} { return new(adv.Model) }, func() interface{} { return new(adv.Filter) }},
	{"agent", func() interface{} { return new(agent.Model) }, func() interface{} { return new(agent.Model) }, func() interface{} { return new(agent.Filter) }},
	{"alipay", func() interface{} { return new(alipay.Model) }, func() interface{} { return new(alipay.Model) }, func() interface{} { return new(alipay.Filter) }},
	{"attrname", func() interface{} { return new(attrname.Model) }, func() interface{} { return new(attrname.Model) }, func() interface{} { return new(attrname.Filter) }},
	{"balance", func() interface{} { return new(balance.Model) }, func() interface{} { return new(balance.Model) }, func() interface{} { return new(balance.Filter) }},
	{"bidder", func() interface{} { return new(bidder.Model) }, func() interface{} { return new(bidder.Model) }, func() interface{} { return new(bidder.Filter) }},
	{"campaign", func() interface{} { return new(campaign.Model) }, func() interface{} { return new(campaign.Model) }, func() interface{} { return new(campaign.Filter) }},
	{"cc", func() interface{} { return new(cc.Model) }, func() interface{} { return new(cc.Model) }, func() interface{} { return new(cc.Filter) }},
	{"chac", func() interface{} { return new(chac.Model) }, func() interface{} { return new(chac.Model) }, func() interface{} { return new(chac.Filter) }},
	{"channel", func() interface{} { return new(channel.Model) }, func() interface{} { return new(channel.Model) }, func() interface{} { return new(channel.Filter) }},
	{"cheque", func() interface{} { return new(cheque.Model) }, func() interface{} { return new(cheque.Model) }, func() interface{} { return new(cheque.Filter) }},
	{"creative", func() interface{} { return new(creative.Model) }, func() interface{} { return new(creative.Model) }, func() interface{} { return new(creative.Filter) }},
	{"item", func() interface{} { return new(item.Model) }, func() interface{} { return new(item.Model) }, func() interface{} { return new(item.Filter) }},
	{"ledger", func() interface{} { return new(ledger.Model) }, func() interface{} { return new(ledger.Model) }, func() interface{} { return new(ledger.Filter) }},
	{"manage", func() interface{} { return new(manage.Model) }, func() interface{} { return new(manage.Model) }, func() interface{} { return new(manage.Filter) }},
	{"midroute", func() interface{} { return new(midroute.Model) }, func() interface{} { return new(midroute.Model) }, func() interface{} { return new(midroute.Filter) }},
	{"payment", func() interface{} { return new(payment.Model) }, func() interface{} { return new(payment.Model) }, func() interface{} { return new(payment.Filter) }},
	{"pub", func() interface{} { return new(pub.Model) }, func() interface{} { return new(pub.Model) }, func() interface{} { return new(pub.Filter) }},
	{"site", func() interface{} { return new(site.Model) }, func() interface{} { return new(site.Model) }, func() interface{} { return new(site.Filter) }},
	{"slot", func() interface{} { return new(slot.Model) }, func() interface{} { return new(slot.Model) }, func() interface{} { return new(slot.Filter) }},
	{"targetname", func() interface{} { return new(targetname.Model) }, func() interface{} { return new(targetname.Model) }, func() interface{} { return new(targetname.Filter) }},
	{"wechat", func() interface{} { return new(wechat.Model) }, func() interface{} { return new(wechat.Model) }, func() interface{} { return new(wechat.Filter) }},
	{"weight", func() interface{} { return new(weight.Model) }, func() interface{} { return new(weight.Model) }, func() interface{} { return new(weight.Filter) }},
}

func Build() (map[string]interface{}, map[string]interface{}, map[string]interface{}) {
	models := make(map[string]interface{}, len(Entries))
	storage := make(map[string]interface{}, len(Entries))
	filters := make(map[string]interface{}, len(Entries))
	for _, entry := range Entries {
		models[entry.Name] = entry.NewModel()
		storage[entry.Name] = entry.NewStorage()
		filters[entry.Name] = entry.NewFilter()
	}
	return models, storage, filters
}

func BuildFactories(projectRoot string, logger *zap.Logger) (map[string]func() interface{}, map[string]func() interface{}, map[string]func() interface{}, error) {
	models := make(map[string]func() interface{}, len(Entries))
	storage := make(map[string]func() interface{}, len(Entries))
	filters := make(map[string]func() interface{}, len(Entries))
	for _, entry := range Entries {
		entry := entry
		comp, err := genelet.LoadComponent(projectRoot + "/summer/" + entry.Name + "/component.json")
		if err != nil {
			return nil, nil, nil, err
		}
		models[entry.Name] = initializedFactory(entry.NewModel, comp, logger)
		storage[entry.Name] = initializedFactory(entry.NewStorage, comp, logger)
		filters[entry.Name] = initializedFactory(entry.NewFilter, comp, logger)
	}
	return models, storage, filters, nil
}

func initializedFactory(newValue func() interface{}, comp *genelet.Component, logger *zap.Logger) func() interface{} {
	return func() interface{} {
		value := newValue()
		if err := genelet.InvokeVoid(value, "Initialize", comp, logger); err != nil {
			panic(err)
		}
		return value
	}
}
