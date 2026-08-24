package main

import (
	"go/ast"
	"go/parser"
	"go/token"
	"html/template"
	"net/url"
	"os"
	"os/exec"
	"path/filepath"
	"strings"
	"testing"

	"github.com/guruperl/genelet"
	"golang.org/x/net/html"
)

const hostileTemplateValue = `"><img src=x onerror="S04XSS"><script>S04XSS</script><a href="javascript:S04XSS">unsafe</a>`

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

func TestTemplateSourceFindings(t *testing.T) {
	tests := []struct {
		name string
		text string
		want int
	}{
		{
			name: "unsafe script URL",
			text: `<a href="javascript:alert(1)">run</a>`,
			want: 1,
		},
		{
			name: "remote script",
			text: `<script src="https://cdn.example.test/library.js"></script>`,
			want: 1,
		},
		{
			name: "exact Turnstile bootstrap",
			text: `<script src="https://challenges.cloudflare.com/turnstile/v0/api.js" async defer></script>`,
			want: 0,
		},
		{
			name: "modified Turnstile bootstrap",
			text: `<script src="https://challenges.cloudflare.com/turnstile/v0/api.js?onload=run"></script>`,
			want: 1,
		},
		{
			name: "stored markup iframe",
			text: `<iframe srcdoc="{{.content}}"></iframe>`,
			want: 1,
		},
		{
			name: "escaped source display",
			text: `<pre class="creative-source">{{.content}}</pre>`,
			want: 0,
		},
		{
			name: "local reviewed asset",
			text: `<script src="/admin/assets/js/vendor/jquery-slim.min.js"></script>`,
			want: 0,
		},
		{
			name: "raw modal title sink",
			text: `<script>$('#title').html(dataTitle);</script>`,
			want: 1,
		},
		{
			name: "text-only modal title",
			text: `<script>$('#title').text(dataTitle);</script>`,
			want: 0,
		},
	}
	for _, test := range tests {
		t.Run(test.name, func(t *testing.T) {
			if got := len(templateSourceFindings([]byte(test.text))); got != test.want {
				t.Fatalf("templateSourceFindings() returned %d findings, want %d", got, test.want)
			}
		})
	}
}

func TestFindForbiddenTemplateTypes(t *testing.T) {
	root := t.TempDir()
	files := map[string]string{
		"safe.go": `package fixture
import "html/template"
var _ = template.HTMLEscapeString
// template.HTML in documentation is not a conversion.
`,
		"unsafe.go": `package fixture
import "html/template"
var unsafe template.HTML
`,
		"alias.go": `package fixture
import ht "html/template"
var unsafeAlias ht.URL
`,
		"dot.go": `package fixture
import . "html/template"
`,
	}
	for name, content := range files {
		if err := os.WriteFile(filepath.Join(root, name), []byte(content), 0o600); err != nil {
			t.Fatal(err)
		}
	}
	findings, err := findForbiddenTemplateTypes(root)
	if err != nil {
		t.Fatal(err)
	}
	joined := strings.Join(findings, "\n")
	if len(findings) != 3 ||
		!strings.Contains(joined, "alias.go: template.URL") ||
		!strings.Contains(joined, "dot.go: dot import of html/template") ||
		!strings.Contains(joined, "unsafe.go: template.HTML") {
		t.Fatalf("findForbiddenTemplateTypes() = %v", findings)
	}
}

func TestDirectSSPBrowserRendererUsesAnIsolatedDeliveryHTMLSink(t *testing.T) {
	data, err := os.ReadFile(filepath.Join("..", "www", "js", "ads.js"))
	if err != nil {
		t.Fatal(err)
	}
	source := string(data)
	if strings.Contains(source, "innerHTML") || strings.Count(source, "frame.srcdoc = markup;") != 1 {
		t.Fatalf("direct SSP browser delivery HTML boundary changed:\n%s", source)
	}
	for _, required := range []string{
		`frame.setAttribute("sandbox", "allow-scripts allow-forms allow-popups allow-popups-to-escape-sandbox");`,
		`frame.setAttribute("referrerpolicy", "no-referrer");`,
		`frame.setAttribute("allow", "camera 'none'; microphone 'none'; geolocation 'none'; payment 'none'; usb 'none'; serial 'none'; bluetooth 'none'; clipboard-read 'none'; clipboard-write 'none'");`,
		`target.setAttribute("data-pz-state", "filled");`,
		`target.setAttribute("data-pz-state", emptyState || "no-fill");`,
	} {
		if !strings.Contains(source, required) {
			t.Fatalf("direct SSP browser renderer is missing %q", required)
		}
	}
	for _, forbidden := range []string{"allow-same-origin", "document.write", "insertAdjacentHTML", "outerHTML", "eval("} {
		if strings.Contains(source, forbidden) {
			t.Fatalf("direct SSP browser delivery contains unapproved sink %q", forbidden)
		}
	}
}

func TestCreativeDeliveryConsumerInventory(t *testing.T) {
	rawDOMMarkers := []string{
		"innerHTML",
		"outerHTML",
		"insertAdjacentHTML",
		"document.write",
		".html(",
		"srcdoc",
	}
	jsRoot := filepath.Join("..", "www", "js")
	adsPath := filepath.Clean(filepath.Join(jsRoot, "ads.js"))
	err := filepath.Walk(jsRoot, func(path string, info os.FileInfo, walkErr error) error {
		if walkErr != nil {
			return walkErr
		}
		if info.IsDir() || filepath.Ext(path) != ".js" {
			return nil
		}
		data, readErr := os.ReadFile(path)
		if readErr != nil {
			return readErr
		}
		source := string(data)
		if filepath.Clean(path) == adsPath {
			if strings.Count(source, "frame.srcdoc = markup;") != 1 {
				t.Errorf("%s must contain exactly one reviewed creative sink", path)
			}
			source = strings.Replace(source, "frame.srcdoc = markup;", "", 1)
		}
		for _, marker := range rawDOMMarkers {
			if strings.Contains(source, marker) {
				t.Errorf("unreviewed first-party DOM sink %q in %s", marker, path)
			}
		}
		return nil
	})
	if err != nil {
		t.Fatal(err)
	}

	nativeRendererMarkers := []string{
		"android.webkit.WebView",
		"WKWebView",
		"loadDataWithBaseURL(",
		"loadHTMLString(",
		"addJavascriptInterface(",
	}
	for _, root := range []string{"cmd", "summer", "tmpls", filepath.Join("www", "js")} {
		err := filepath.Walk(filepath.Join("..", root), func(path string, info os.FileInfo, walkErr error) error {
			if walkErr != nil {
				return walkErr
			}
			if info.IsDir() {
				return nil
			}
			switch filepath.Ext(path) {
			case ".go", ".js", ".g", ".e":
			default:
				return nil
			}
			data, readErr := os.ReadFile(path)
			if readErr != nil {
				return readErr
			}
			for _, marker := range nativeRendererMarkers {
				if strings.Contains(string(data), marker) {
					t.Errorf("undocumented native creative renderer marker %q in %s", marker, path)
				}
			}
			return nil
		})
		if err != nil {
			t.Fatal(err)
		}
	}
}

func TestSourceOnlyManagementPackagesHaveNoOutboundHTTPPrimitive(t *testing.T) {
	packages := []string{"campaign", "creative", "item", "site"}
	forbiddenHTTP := map[string]bool{
		"Client": true, "Transport": true, "DefaultClient": true, "DefaultTransport": true,
		"Get": true, "Head": true, "Post": true, "PostForm": true,
	}
	for _, packageName := range packages {
		root := filepath.Join("..", "summer", packageName)
		err := filepath.Walk(root, func(path string, info os.FileInfo, walkErr error) error {
			if walkErr != nil {
				return walkErr
			}
			if info.IsDir() || filepath.Ext(path) != ".go" || strings.HasSuffix(path, "_test.go") {
				return nil
			}
			fileSet := token.NewFileSet()
			file, err := parser.ParseFile(fileSet, path, nil, 0)
			if err != nil {
				return err
			}
			httpAliases := map[string]bool{}
			for _, imported := range file.Imports {
				if imported.Path.Value == `"net"` {
					t.Errorf("source-only management package imports raw network access in %s", path)
					continue
				}
				if imported.Path.Value != `"net/http"` {
					continue
				}
				alias := "http"
				if imported.Name != nil {
					alias = imported.Name.Name
				}
				if alias == "." {
					t.Errorf("source-only management package dot-imports net/http in %s", path)
					continue
				}
				httpAliases[alias] = true
			}
			ast.Inspect(file, func(node ast.Node) bool {
				selector, ok := node.(*ast.SelectorExpr)
				if !ok {
					return true
				}
				identifier, qualified := selector.X.(*ast.Ident)
				if qualified && httpAliases[identifier.Name] && forbiddenHTTP[selector.Sel.Name] {
					t.Errorf("source-only management package contains outbound primitive %s.%s in %s", identifier.Name, selector.Sel.Name, path)
				}
				return true
			})
			return nil
		})
		if err != nil {
			t.Fatal(err)
		}
	}
}

func TestDirectSSPBrowserRendererFillAndNoFillBehavior(t *testing.T) {
	if _, err := exec.LookPath("node"); err != nil {
		t.Skip("node is unavailable; source-policy checks still run")
	}
	scriptPath := filepath.Join("..", "www", "js", "ads.js")
	harness := `
const fs = require("fs");
eval(fs.readFileSync(process.argv[1], "utf8"));
function element(tag) {
  return {
    tagName: tag,
    attributes: {},
    style: {},
    children: [],
    firstChild: null,
    setAttribute: function(k, v) { this.attributes[k] = v; },
    appendChild: function(v) { this.children.push(v); this.firstChild = this.children[0]; },
    removeChild: function() { this.children.shift(); this.firstChild = this.children[0] || null; }
  };
}
global.document = { createElement: element };
const target = element("div");
pzRenderAd(target, "<img src='/imp'>", {mediaTypes:{banner:{size:[300,250]}}}, "no-fill");
if (target.children.length !== 1 || target.children[0].tagName !== "iframe") throw new Error("filled iframe missing");
const frame = target.children[0];
if (frame.srcdoc !== "<img src='/imp'>" || frame.width !== "300" || frame.height !== "250") throw new Error("filled markup or dimensions changed");
if (!frame.attributes.sandbox || frame.attributes.sandbox.includes("allow-same-origin") || frame.attributes.referrerpolicy !== "no-referrer") throw new Error("iframe isolation changed");
if (!frame.attributes.allow || !frame.attributes.allow.includes("camera 'none'") || !frame.attributes.allow.includes("clipboard-write 'none'")) throw new Error("iframe permissions policy changed");
if (target.attributes["data-pz-state"] !== "filled") throw new Error("filled state missing");
const hostile = '</iframe><img src=x onerror=alert(1)><script>window.parent.document.body.textContent="owned"</script>';
pzRenderAd(target, hostile, {mediaTypes:{banner:{size:[300,250]}}}, "no-fill");
if (target.children.length !== 1 || target.children[0].tagName !== "iframe" || target.children[0].srcdoc !== hostile) throw new Error("hostile markup escaped the single srcdoc boundary");
if (target.attributes["data-pz-state"] !== "filled") throw new Error("hostile fixture changed deterministic state");
pzRenderAd(target, "", {mediaTypes:{banner:{size:[300,250]}}}, "no-fill");
if (target.children.length !== 0 || target.attributes["data-pz-state"] !== "no-fill") throw new Error("no-fill behavior changed");
pzRenderAd(target, {unexpected:true}, {}, "error");
if (target.children.length !== 0 || target.attributes["data-pz-state"] !== "error") throw new Error("error behavior changed");
`
	command := exec.Command("node", "-e", harness, scriptPath)
	if output, err := command.CombinedOutput(); err != nil {
		t.Fatalf("browser renderer behavior: %v\n%s", err, output)
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
			rendered := renderAdvertiserTemplate(t, test.action, test.component, test.lists)
			if !strings.Contains(rendered, test.contains) {
				t.Fatalf("rendered template does not contain %q", test.contains)
			}
		})
	}
}

func TestAdvertiserWorkspaceShell(t *testing.T) {
	rendered := renderAdvertiserTemplate(
		t,
		filepath.Join("..", "tmpls", "adv", "attrname", "topics.g"),
		"attrname",
		nil,
	)
	for _, want := range []string{
		`href="/css/w8m-workspace.css?v=20260802-1"`,
		`<body class="w8m-workspace theme-advertiser">`,
		`<span class="navbar-brand">W8M 广告主工作台</span>`,
	} {
		if !strings.Contains(rendered, want) {
			t.Errorf("rendered workspace does not contain %q", want)
		}
	}
	if strings.Contains(rendered, `<a class="navbar-brand"`) {
		t.Error("workspace name must not link away from the advertiser portal")
	}
}

func TestWorkspaceDangerButtonTextContrast(t *testing.T) {
	css, err := os.ReadFile(filepath.Join("..", "www", "css", "w8m-workspace.css"))
	if err != nil {
		t.Fatal(err)
	}
	const want = `.w8m-workspace .btn-danger,
.w8m-workspace .btn-danger:hover,
.w8m-workspace .btn-danger:focus,
.w8m-workspace .btn-danger:active,
.w8m-workspace .btn-danger.active,
.w8m-workspace a.btn-danger:visited {
  color: #fff;
}`
	if !strings.Contains(string(css), want) {
		t.Error("workspace danger buttons must retain white text in every interaction state")
	}
}

func TestPublisherWorkspaceShell(t *testing.T) {
	args := url.Values{}
	args.Set("p_email", "publisher@example.test")
	rendered := renderRoleTemplate(
		t,
		filepath.Join("..", "tmpls", "pub", "site", "topics.g"),
		"site",
		nil,
		args,
	)
	for _, want := range []string{
		`href="/css/w8m-workspace.css?v=20260802-1"`,
		`w8m-workspace theme-publisher`,
		`<span class="navbar-brand">W8M <small>流量方工作台</small></span>`,
		`class="navbar-toggler mobile-sidebar-toggler d-lg-none"`,
		`class="nav-link workspace-account-menu"`,
		`<span>账户</span>`,
	} {
		if !strings.Contains(rendered, want) {
			t.Errorf("rendered publisher workspace does not contain %q", want)
		}
	}
	for _, unwanted := range []string{
		`/img/O.png`,
		`img-avatar`,
		`class="navbar-toggler sidebar-toggler d-md-down-none"`,
		`aside-menu-toggler`,
	} {
		if strings.Contains(rendered, unwanted) {
			t.Errorf("rendered publisher workspace still contains %q", unwanted)
		}
	}
}

func TestHostedPaymentNavigationFollowsServiceAvailability(t *testing.T) {
	tests := []struct {
		role   string
		action string
		args   url.Values
	}{
		{"adv", filepath.Join("..", "tmpls", "adv", "attrname", "topics.g"), values(map[string]string{"a_company": "Advertiser", "a_email": "adv@example.test"})},
		{"pub", filepath.Join("..", "tmpls", "pub", "site", "topics.g"), values(map[string]string{"p_email": "pub@example.test"})},
	}
	for _, test := range tests {
		t.Run(test.role, func(t *testing.T) {
			disabled := renderRoleTemplateWithOther(t, test.action, "topics", nil, test.args, map[string]interface{}{"HostedPaymentEnabled": false})
			if strings.Contains(disabled, `href="hostedpayment?action=topics"`) {
				t.Fatal("disabled hosted-payment service remained in navigation")
			}
			enabled := renderRoleTemplateWithOther(t, test.action, "topics", nil, test.args, map[string]interface{}{"HostedPaymentEnabled": true})
			if !strings.Contains(enabled, `href="hostedpayment?action=topics"`) {
				t.Fatal("enabled hosted-payment service is missing from navigation")
			}
		})
	}
}

func TestMarketplaceNavigationFollowsSchemaAvailability(t *testing.T) {
	tests := []struct {
		role   string
		action string
		args   url.Values
	}{
		{"adv", filepath.Join("..", "tmpls", "adv", "attrname", "topics.g"), values(map[string]string{"a_company": "Advertiser", "a_email": "adv@example.test"})},
		{"pub", filepath.Join("..", "tmpls", "pub", "site", "topics.g"), values(map[string]string{"p_email": "pub@example.test"})},
	}
	for _, test := range tests {
		t.Run(test.role, func(t *testing.T) {
			disabled := renderRoleTemplateWithOther(t, test.action, "topics", nil, test.args, map[string]interface{}{"MarketplaceReportingEnabled": false})
			if strings.Contains(disabled, `href="ledger?action=topicsMarketplace"`) {
				t.Fatal("inactive marketplace report remained in navigation")
			}
			enabled := renderRoleTemplateWithOther(t, test.action, "topics", nil, test.args, map[string]interface{}{"MarketplaceReportingEnabled": true})
			if !strings.Contains(enabled, `href="ledger?action=topicsMarketplace"`) {
				t.Fatal("active marketplace report is missing from navigation")
			}
		})
	}
}

func TestActionNavigationFollowsSchemaAvailability(t *testing.T) {
	args := values(map[string]string{"a_company": "Advertiser", "a_email": "adv@example.test"})
	action := filepath.Join("..", "tmpls", "adv", "attrname", "topics.g")
	disabled := renderRoleTemplateWithOther(t, action, "topics", nil, args, map[string]interface{}{"ActionReportingEnabled": false})
	if strings.Contains(disabled, `href="ledger?action=topicsAdvActions"`) {
		t.Fatal("inactive action report remained in advertiser navigation")
	}
	enabled := renderRoleTemplateWithOther(t, action, "topics", nil, args, map[string]interface{}{"ActionReportingEnabled": true})
	if !strings.Contains(enabled, `href="ledger?action=topicsAdvActions"`) {
		t.Fatal("active action report is missing from advertiser navigation")
	}
}

func TestAdvertiserMaintenanceErrorExplainsInactiveFeature(t *testing.T) {
	parsed, err := template.ParseFiles(filepath.Join("..", "tmpls", "adv", "error.g"))
	if err != nil {
		t.Fatal(err)
	}
	var output strings.Builder
	if err := parsed.Execute(&output, genelet.Gerror{Code: 503}); err != nil {
		t.Fatal(err)
	}
	if !strings.Contains(output.String(), "此功能尚未启用") {
		t.Fatal("advertiser 503 page does not explain the inactive feature")
	}
}

func TestPublisherSlotTopicsShowsCommercialFloorAndPreservesSiteType(t *testing.T) {
	args := values(map[string]string{
		"p_email": "publisher@example.test", "site_id": "11",
		"site_md5": "fixture", "site_name": "Example App", "site_type": "App",
	})
	rendered := renderRoleTemplate(
		t,
		filepath.Join("..", "tmpls", "pub", "slot", "topics.g"),
		"slot",
		[]map[string]interface{}{{
			"slot_id": 13, "slot_md5": "slot-fixture", "slot_name": "Leaderboard",
			"qa_device_g": "移动设备", "bidfloor": float64(1.25), "active": "Yes",
			"created": "2026-08-01", "browser_code": "", "api_code": "POST /pz",
		}},
		args,
	)
	for _, want := range []string{
		`最低竞价（USD CPM）`, `1.250000`, `App SDK / API 接入代码`,
		`site_type=App`,
	} {
		if !strings.Contains(rendered, want) {
			t.Errorf("rendered publisher slot topics does not contain %q", want)
		}
	}
	if strings.Contains(rendered, `>网页广告码</button>`) {
		t.Error("App inventory exposed a browser tag action")
	}
}

func TestPublisherSupplyMetadataIsEscapedInFormsAndReports(t *testing.T) {
	args := values(map[string]string{
		"p_email": "publisher@example.test", "site_id": "11", "site_md5": "fixture",
		"site_name": hostileTemplateValue, "site_type": "Web", "day": "2026-08-01", "idays": "1", "top": "20",
	})
	site := renderRoleTemplate(t, filepath.Join("..", "tmpls", "pub", "site", "edit.g"), "site", []map[string]interface{}{{
		"site_id": 11, "site_name": hostileTemplateValue, "site_type": "Web", "foreign_id": "example.com",
		"site_url": hostileTemplateValue, "inventory_environment": "Web", "integration_mode": "BrowserTag",
		"canonical_identity": hostileTemplateValue, "store_url": hostileTemplateValue,
	}}, args)
	assertHostileTemplateValueIsInert(t, site)

	profile := renderRoleTemplateWithOther(t, filepath.Join("..", "tmpls", "pub", "pub", "edit.g"), "pub", []map[string]interface{}{{
		"domain": "example.com", "seller_id": hostileTemplateValue, "seller_type": "Publisher",
		"seller_asi": hostileTemplateValue, "seller_name": hostileTemplateValue,
		"seller_domain": hostileTemplateValue, "seller_authorized": "No",
	}}, args, map[string]interface{}{"address_states": []map[string]interface{}{}})
	assertHostileTemplateValueIsInert(t, profile)

	report := renderRoleTemplate(t, filepath.Join("..", "tmpls", "pub", "ledger", "topicsMarketplace.g"), "ledger", []map[string]interface{}{{
		"demand_source": "Local", "site_name": hostileTemplateValue, "slot_name": hostileTemplateValue,
		"inventory_environment": hostileTemplateValue, "integration_mode": hostileTemplateValue,
		"media_intent": hostileTemplateValue, "placement": hostileTemplateValue,
		"traffic_quality": hostileTemplateValue, "source_quality": hostileTemplateValue,
		"seller_type": "Publisher", "seller_id": hostileTemplateValue,
		"imps": 1, "clis": 0, "ctr": float64(0), "revenue_usd": "0.000000", "effective_cpm": float64(0),
	}}, args)
	assertHostileTemplateValueIsInert(t, report)
}

func TestRegistrationRoleThemes(t *testing.T) {
	tests := []struct {
		role  string
		theme string
	}{
		{role: "adv", theme: "theme-advertiser"},
		{role: "pub", theme: "theme-publisher"},
	}
	for _, test := range tests {
		t.Run(test.role, func(t *testing.T) {
			rendered := renderRoleTemplate(
				t,
				filepath.Join("..", "tmpls", "web", test.role, "startnew.g"),
				test.role,
				nil,
				url.Values{},
			)
			for _, want := range []string{
				`href="/css/w8m-account.css?v=20260822-1"`,
				`<body class="w8m-public-account ` + test.theme + `">`,
				`<div class="account-card ` + test.theme + `">`,
			} {
				if !strings.Contains(rendered, want) {
					t.Errorf("rendered %s registration does not contain %q", test.role, want)
				}
			}
		})
	}
}

func TestPublicAccountFormsRenderScopedTurnstileWidgets(t *testing.T) {
	tests := []struct {
		role   string
		page   string
		action string
	}{
		{role: "adv", page: "startnew", action: "register_adv"},
		{role: "adv", page: "startretrieve", action: "recover_adv"},
		{role: "pub", page: "startnew", action: "register_pub"},
		{role: "pub", page: "startretrieve", action: "recover_pub"},
	}
	for _, test := range tests {
		for _, ext := range []string{"g", "e"} {
			t.Run(test.role+"_"+test.page+"_"+ext, func(t *testing.T) {
				rendered := renderRoleTemplateWithOther(
					t,
					filepath.Join("..", "tmpls", "web", test.role, test.page+"."+ext),
					test.role,
					nil,
					url.Values{},
					map[string]interface{}{
						"TurnstileSiteKey": "0x4-public-site-key",
						"TurnstileAction":  test.action,
					},
				)
				for _, want := range []string{
					`class="cf-turnstile"`,
					`data-sitekey="0x4-public-site-key"`,
					`data-action="` + test.action + `"`,
					`src="https://challenges.cloudflare.com/turnstile/v0/api.js"`,
				} {
					if !strings.Contains(rendered, want) {
						t.Errorf("rendered form does not contain %q", want)
					}
				}
				if strings.Contains(rendered, "private-secret") {
					t.Error("rendered form contains a Turnstile secret")
				}
			})
		}
	}
}

func TestLoginRoleThemes(t *testing.T) {
	tests := []struct {
		role  string
		theme string
	}{
		{role: "adv", theme: "theme-advertiser"},
		{role: "pub", theme: "theme-publisher"},
	}
	for _, test := range tests {
		t.Run(test.role, func(t *testing.T) {
			path := filepath.Join("..", "tmpls", test.role, "login.g")
			parsed, err := template.ParseFiles(path)
			if err != nil {
				t.Fatal(err)
			}
			var output strings.Builder
			if err := parsed.Execute(&output, map[string]interface{}{
				"LoginName": "login",
				"GoURIName": "go_uri",
				"GoURI":     "/",
				"Login":     "email",
				"Password":  "passwd",
				"Errorstr":  "",
			}); err != nil {
				t.Fatal(err)
			}
			rendered := output.String()
			for _, want := range []string{
				`href="/css/w8m-account.css?v=20260801-3"`,
				`<body class="w8m-public-account ` + test.theme + `">`,
			} {
				if !strings.Contains(rendered, want) {
					t.Errorf("rendered %s login does not contain %q", test.role, want)
				}
			}
		})
	}
}

func TestHostileLoginValuesAreContextuallyEscaped(t *testing.T) {
	for _, role := range []string{"adv", "pub", "admin", "agent", "analyst"} {
		t.Run(role, func(t *testing.T) {
			path := filepath.Join("..", "tmpls", role, "login.g")
			parsed, err := template.ParseFiles(path)
			if err != nil {
				t.Fatal(err)
			}
			var output strings.Builder
			if err := parsed.Execute(&output, map[string]interface{}{
				"LoginName": "javascript:S04XSS",
				"GoURIName": hostileTemplateValue,
				"GoURI":     hostileTemplateValue,
				"Login":     hostileTemplateValue,
				"Password":  hostileTemplateValue,
				"TOTP":      hostileTemplateValue,
				"Errorstr":  hostileTemplateValue,
			}); err != nil {
				t.Fatal(err)
			}
			assertHostileTemplateValueIsInert(t, output.String())
			if role == "pub" && !strings.Contains(output.String(), `#ZgotmplZ`) {
				t.Fatalf("%s login did not reject an unsafe form action: %s", role, output.String())
			}
		})
	}
}

func TestIdentitySecurityTemplatesEscapeEnrollmentAndRecoveryMaterial(t *testing.T) {
	argsByRole := map[string]url.Values{
		"adv":     values(map[string]string{"adv_id": "1", "a_email": "adv@example.test", "a_company": "Advertiser"}),
		"pub":     values(map[string]string{"pub_id": "2", "p_email": "pub@example.test", "p_company": "Publisher", "p_contact": "Operator", "p_timezone_id": "UTC"}),
		"admin":   values(map[string]string{"admin_id": "3", "admin_login": "admin"}),
		"agent":   values(map[string]string{"agent_id": "4", "agent_login": "agent", "agent_level": "1"}),
		"analyst": values(map[string]string{"analyst_id": "5", "analyst_login": "analyst"}),
	}
	for role, args := range argsByRole {
		t.Run(role, func(t *testing.T) {
			rendered := renderRoleTemplateWithOther(t,
				filepath.Join("..", "tmpls", role, "security", "page.g"), "security", nil, args,
				map[string]interface{}{
					"Required": true, "MFAState": "Enabled", "RecoveryRemaining": 2,
					"Enrollment":    genelet.TOTPEnrollment{Secret: hostileTemplateValue, URI: hostileTemplateValue},
					"RecoveryCodes": []string{hostileTemplateValue}, "CSRFInput": hostileTemplateValue,
				})
			assertHostileTemplateValueIsInert(t, rendered)
			if strings.Contains(rendered, `<script>S04XSS</script>`) || strings.Contains(rendered, `href="javascript:`) {
				t.Fatalf("identity material became executable markup: %s", rendered)
			}
		})
	}
}

func TestStoredCreativeMarkupIsDisplayedAsSource(t *testing.T) {
	tests := []struct {
		name      string
		action    string
		component string
		lists     []map[string]interface{}
		args      url.Values
	}{
		{
			name:      "advertiser management",
			action:    filepath.Join("..", "tmpls", "adv", "creative", "topics.g"),
			component: "creative",
			lists: []map[string]interface{}{{
				"creative_id": 9, "creative_name": hostileTemplateValue,
				"content": hostileTemplateValue,
			}},
			args: values(map[string]string{
				"a_company": "advertiser", "a_email": "adv@example.test",
				"qa_mime": "img", "active": "Yes", "campaign_name": "campaign",
				"item_name": "item",
			}),
		},
		{
			name:      "publisher review",
			action:    filepath.Join("..", "tmpls", "pub", "item", "topics.g"),
			component: "item",
			lists: []map[string]interface{}{{
				"item_name":       hostileTemplateValue,
				"creative_topics": []map[string]interface{}{{"content": hostileTemplateValue}},
			}},
			args: values(map[string]string{"p_email": "pub@example.test"}),
		},
		{
			name:      "agent review",
			action:    filepath.Join("..", "tmpls", "agent", "item", "topics.g"),
			component: "item",
			lists: []map[string]interface{}{{
				"item_id": 7, "item_name": hostileTemplateValue, "active": "Yes",
				"creative_topics": []map[string]interface{}{{"content": hostileTemplateValue}},
			}},
			args: values(map[string]string{
				"agent_login": "reviewer", "agent_level": "1",
				"campaign_id": "4", "campaign_md5": "fixture",
			}),
		},
	}
	for _, test := range tests {
		t.Run(test.name, func(t *testing.T) {
			rendered := renderRoleTemplate(t, test.action, test.component, test.lists, test.args)
			assertHostileTemplateValueIsInert(t, rendered)
			if !strings.Contains(rendered, `<pre class="creative-source">`) || !strings.Contains(rendered, `&lt;img`) {
				t.Fatalf("stored creative was not shown as escaped source: %s", rendered)
			}
		})
	}
}

func TestHostileAccountAndReportValuesAreContextuallyEscaped(t *testing.T) {
	admin := renderRoleTemplate(
		t,
		filepath.Join("..", "tmpls", "admin", "adv", "topics.g"),
		"adv",
		[]map[string]interface{}{{
			"adv_id": 7, "email": hostileTemplateValue, "firstname": hostileTemplateValue,
			"company": hostileTemplateValue, "active": "Yes",
		}},
		values(map[string]string{"admin_login": "admin", "admin_id": "1"}),
	)
	assertHostileTemplateValueIsInert(t, admin)

	campaign := renderRoleTemplate(
		t,
		filepath.Join("..", "tmpls", "adv", "campaign", "topics.g"),
		"campaign",
		[]map[string]interface{}{{
			"campaign_id": 4, "campaign_md5": "fixture", "campaign_name": hostileTemplateValue,
			"active": "Yes", "budget": "10.00", "startx": "2026-08-01", "endx": "2026-08-02",
		}},
		values(map[string]string{"a_company": "advertiser", "a_email": "adv@example.test"}),
	)
	assertHostileTemplateValueIsInert(t, campaign)

	report := renderRoleTemplateWithOther(
		t,
		filepath.Join("..", "tmpls", "adv", "ledger", "topicsMid24Hours.g"),
		"ledger",
		[]map[string]interface{}{{
			"hours": hostileTemplateValue, "imps": hostileTemplateValue,
			"clis": hostileTemplateValue, "spend": hostileTemplateValue,
		}},
		values(map[string]string{"a_company": "advertiser", "a_email": "adv@example.test"}),
		map[string]interface{}{
			"ledger_topicsMidTopBidders": []map[string]interface{}{},
			"ledger_topicsMidTopSlots":   []map[string]interface{}{},
		},
	)
	assertHostileTemplateValueIsInert(t, report)
	if strings.Contains(report, `</script><script>S04XSS`) {
		t.Fatalf("report value broke out of its JavaScript string context: %s", report)
	}
}

func TestMailTemplateValuesRemainPlainEscapedContent(t *testing.T) {
	for _, role := range []string{"adv", "pub"} {
		t.Run(role, func(t *testing.T) {
			path := filepath.Join("..", "tmpls", "web", role, "insert.mail.g")
			parsed, err := template.ParseFiles(path)
			if err != nil {
				t.Fatal(err)
			}
			args := values(map[string]string{
				"serverUrl": "https://www.example.test", role + "_id": "7",
				"email": hostileTemplateValue, "stamp": hostileTemplateValue,
				"md5": hostileTemplateValue, "firstname": hostileTemplateValue,
				"lastname": hostileTemplateValue,
			})
			page := &genelet.Tmpl{ARGS: args}
			var output strings.Builder
			if err := parsed.Execute(&output, page); err != nil {
				t.Fatal(err)
			}
			if strings.Contains(output.String(), "<img") || strings.Contains(output.String(), "<script") {
				t.Fatalf("mail template emitted hostile markup: %s", output.String())
			}
		})
	}
}

func renderAdvertiserTemplate(t *testing.T, action, component string, lists []map[string]interface{}) string {
	t.Helper()
	args := url.Values{}
	args.Set("a_company", "测试广告主")
	args.Set("a_email", "adv@example.test")
	return renderRoleTemplate(t, action, component, lists, args)
}

func renderRoleTemplate(t *testing.T, action, component string, lists []map[string]interface{}, args url.Values) string {
	t.Helper()
	return renderRoleTemplateWithOther(t, action, component, lists, args, nil)
}

func renderRoleTemplateWithOther(t *testing.T, action, component string, lists []map[string]interface{}, args url.Values, extraOther map[string]interface{}) string {
	t.Helper()
	ext := filepath.Ext(action)
	files, err := roleFiles(filepath.Join("..", "tmpls"), action, ext)
	if err != nil {
		t.Fatal(err)
	}
	parsed, err := template.New(filepath.Base(action)).Option("missingkey=zero").ParseFiles(files...)
	if err != nil {
		t.Fatal(err)
	}

	other := map[string]interface{}{
		"Action":    strings.TrimSuffix(filepath.Base(action), ext),
		"Component": component,
	}
	for key, value := range extraOther {
		other[key] = value
	}
	page := &genelet.Tmpl{
		Lists:   lists,
		ARGS:    args,
		Other:   other,
		Success: true,
	}
	rendered, err := page.Get_page(parsed)
	if err != nil {
		t.Fatal(err)
	}
	return rendered
}

func values(entries map[string]string) url.Values {
	result := url.Values{}
	for key, value := range entries {
		result.Set(key, value)
	}
	return result
}

func assertHostileTemplateValueIsInert(t *testing.T, rendered string) {
	t.Helper()
	doc, err := html.Parse(strings.NewReader(rendered))
	if err != nil {
		t.Fatal(err)
	}
	var walk func(*html.Node)
	walk = func(node *html.Node) {
		if node.Type == html.ElementNode {
			for _, attr := range node.Attr {
				key := strings.ToLower(attr.Key)
				value := strings.ToLower(strings.TrimSpace(attr.Val))
				if key == "onerror" {
					t.Errorf("hostile value created an event handler on <%s>", node.Data)
				}
				if strings.HasPrefix(key, "on") && (strings.Contains(value, "<img") || strings.Contains(value, "<script")) {
					t.Errorf("hostile value escaped its event-handler string context on <%s>: %q", node.Data, attr.Val)
				}
				if (key == "href" || key == "src" || key == "action" || key == "data-href") &&
					(strings.HasPrefix(value, "javascript:") || strings.HasPrefix(value, "vbscript:") || strings.HasPrefix(value, "data:text/html")) {
					t.Errorf("hostile value created unsafe %s=%q on <%s>", key, attr.Val, node.Data)
				}
			}
			if node.Data == "script" && strings.TrimSpace(nodeText(node)) == "S04XSS" {
				t.Error("hostile value created an executable script element")
			}
		}
		for child := node.FirstChild; child != nil; child = child.NextSibling {
			walk(child)
		}
	}
	walk(doc)
}

func nodeText(node *html.Node) string {
	var result strings.Builder
	var walk func(*html.Node)
	walk = func(current *html.Node) {
		if current.Type == html.TextNode {
			result.WriteString(current.Data)
		}
		for child := current.FirstChild; child != nil; child = child.NextSibling {
			walk(child)
		}
	}
	walk(node)
	return result.String()
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
