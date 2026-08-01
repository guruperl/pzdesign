package main

import (
	"html/template"
	"net/url"
	"path/filepath"
	"strings"
	"testing"

	"github.com/guruperl/genelet"
)

func TestHasAssembledQuery(t *testing.T) {
	tests := []struct {
		name string
		text string
		want bool
	}{
		{
			name: "quoted query",
			text: `{{$query := print "campaign_id=" .campaign_id "&campaign_md5=" .campaign_md5}}`,
			want: true,
		},
		{
			name: "raw quoted query",
			text: "{{print `site_id=` .site_id `&site_md5=` .site_md5}}",
			want: true,
		},
		{
			name: "direct parameters",
			text: `<a href="item?action=topics&campaign_id={{.campaign_id}}&campaign_md5={{.campaign_md5}}">`,
			want: false,
		},
	}
	for _, test := range tests {
		t.Run(test.name, func(t *testing.T) {
			if got := hasAssembledQuery([]byte(test.text)); got != test.want {
				t.Fatalf("hasAssembledQuery() = %v, want %v", got, test.want)
			}
		})
	}
}

func TestAdvertiserTemplatesRender(t *testing.T) {
	tests := []struct {
		name      string
		action    string
		component string
		lists     []map[string]interface{}
		contains  string
	}{
		{
			name:      "Chinese attribute names",
			action:    filepath.Join("..", "tmpls", "adv", "attrname", "topics.g"),
			component: "attrname",
			lists: []map[string]interface{}{
				{"attrname_id": 7, "attrname": "兴趣", "value": "体育,旅游"},
			},
			contains: `class="form-control"`,
		},
		{
			name:      "Chinese advertiser profile",
			action:    filepath.Join("..", "tmpls", "adv", "adv", "edit.g"),
			component: "adv",
			lists:     []map[string]interface{}{advertiserProfileFixture()},
			contains:  `name=state_id value="沪"`,
		},
		{
			name:      "English advertiser profile",
			action:    filepath.Join("..", "tmpls", "adv", "adv", "edit.e"),
			component: "adv",
			lists:     []map[string]interface{}{advertiserProfileFixture()},
			contains:  `name=state_id value="沪"`,
		},
	}

	for _, test := range tests {
		t.Run(test.name, func(t *testing.T) {
			ext := filepath.Ext(test.action)
			files, err := roleFiles(filepath.Join("..", "tmpls"), test.action, ext)
			if err != nil {
				t.Fatal(err)
			}
			parsed, err := template.New(filepath.Base(test.action)).Option("missingkey=zero").ParseFiles(files...)
			if err != nil {
				t.Fatal(err)
			}

			args := url.Values{}
			args.Set("a_company", "测试广告主")
			args.Set("a_email", "adv@example.test")
			page := &genelet.Tmpl{
				Lists: test.lists,
				ARGS:  args,
				Other: map[string]interface{}{
					"Action":    strings.TrimSuffix(filepath.Base(test.action), ext),
					"Component": test.component,
				},
				Success: true,
			}
			rendered, err := page.Get_page(parsed)
			if err != nil {
				t.Fatal(err)
			}
			if !strings.Contains(rendered, test.contains) {
				t.Fatalf("rendered template does not contain %q", test.contains)
			}
		})
	}
}

func advertiserProfileFixture() map[string]interface{} {
	return map[string]interface{}{
		"domain":    "example.test",
		"firstname": "明",
		"lastname":  "李",
		"company":   "测试广告主",
		"phone":     "13800000000",
		"street":    "示例路 1 号",
		"city":      "上海",
		"state_id":  "沪",
	}
}
