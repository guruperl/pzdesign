package main

import (
	"flag"
	"fmt"
	"os"
	"path/filepath"
	"sort"
	"strings"

	"golang.org/x/net/html"
)

type publicFile struct {
	path     string
	language string
}

var deprecatedChineseCopy = []string{
	"商家",
	"商户",
	"流量源公司",
	"媒体主",
	"DSP 代理",
	"投放项目",
	"AdX",
	"中间商",
	"广告库存",
	"你现在",
	"你的操作",
	"登入",
	"登陆",
	"拿下",
	"重新播",
	"入网时间",
	"删除成功",
	"更新成功",
	"保存成功",
	"添加成功",
	"提交成功",
	"上传成功",
	"继续管理你的",
	"连接优质广告",
	"真实流量",
	"从投放目标到可衡量的广告活动",
	"从网站或 App 到可运营的广告位",
}

var untranslatedEnglishCopy = []string{
	"Advertiser Workspace",
	"Publisher Workspace",
	"Continue",
	"Oops! You're lost.",
	"Application error.",
	"Please enter a valid email address",
	"Create New Campaign",
	"Change Password",
	"Save and Update",
	"Delete this route",
}

var requiredSnippets = map[string][]string{
	"www/index.html": {
		"W8M 广告投放与流量接入平台",
		"DSP、SSP 与 ADX 一体化工作流",
		"OpenRTB 2.5 受控兼容与开放 API",
		"隐私信号、流量质量与运行观测",
		"选择账户类型",
		"广告主使用流程",
		"流量方接入流程",
		"创建和检查广告活动",
		"配置和检查广告组",
		"添加和测试广告素材",
		"上线投放并查看报表",
		"创建和审核流量源",
		"配置和检查广告位",
		"部署网页广告码或 App/API",
		"验证接入并查看报表",
		"只启用活动本身不会绕过下层规则",
		"广告投放详细使用指南",
		"流量接入详细使用指南",
		"页面显示“已保存”不代表已经进入生产投放",
		"200</code> 空结果是正常无填充",
		"覆盖 DSP、SSP 与 ADX 的平台能力",
		"DSP 投放与竞价",
		"SSP 直连流量变现",
		"ADX 与 OpenRTB 互通",
		"测量、归因与分析",
		"隐私、身份与渲染安全",
		"流量质量与风险控制",
		"账务、结算与托管支付",
		"开放 API 与生产运行",
		"OpenRTB 2.5 受控兼容规范",
		"维护型 Android/iOS 原生 SDK 将在具体集成需求确认后提供",
		"平台不会在缺少连续生产测量和服务商恢复记录时宣称已经达到 99.9%",
		"账户入口",
		"使用说明与常见问题",
		"联系技术支持",
	},
	"www/manuals/advertiser.html": {"广告主与代理商使用手册", "外部 DSP / ADX 需求方接入与竞价"},
	"www/manuals/publisher.html":  {"流量方（发布商）接入手册", "获取并部署网页广告码"},
	"www/index.en.html": {
		"W8M Advertising and Traffic Integration Platform",
		"DSP, SSP, and ADX integrated workflow",
		"Choose Your Account Type",
		"Advertiser Workflow",
		"Publisher Integration Workflow",
		"Platform Capabilities Across DSP, SSP, and ADX",
		"Account Entry Points",
		"Contact Technical Support",
	},
	"www/manuals/advertiser.en.html": {"Advertiser and Agency Manual", "External DSP / ADX Demand-Side Integration and Bidding"},
	"www/manuals/publisher.en.html":  {"Publisher Integration Manual", "Get and Deploy Web Ad Code"},
	"www/css/w8m-home.css": {
		`#capabilities .capability-card,`,
		`.capability-modal[id^="capability-"] .capability-modal-icon`,
		`.capability-modal[id^="capability-"] .capability-status`,
		`--capability-accent: #6b46c1`,
		`--font-reading: "DengXian"`,
		`.journey-step p {`,
		`font-size: .875rem`,
	},
	"tmpls/adv/login.g":             {"广告投放管理", "广告主账户登录"},
	"tmpls/pub/login.g":             {"流量接入管理", "流量方账户登录"},
	"tmpls/agent/login.g":           {"代理商后台登录", "/goto/agent/g/"},
	"tmpls/admin/login.g":           {"系统管理登录", "/goto/admin/g/"},
	"tmpls/web/error.g":             {"错误编号：{{.Code}}", "联系技术支持"},
	"tmpls/web/adv/retrieve.g":      {"如果该邮箱已注册，我们将发送密码重置链接"},
	"tmpls/web/pub/retrieve.g":      {"如果该邮箱已注册，我们将发送密码重置链接"},
	"tmpls/web/adv/insert.mail.g":   {"您好，", "/goto/web/g/adv?action=activate", "W8M 广告平台"},
	"tmpls/web/pub/insert.mail.g":   {"您好，", "/goto/web/g/pub?action=activate", "W8M 广告平台"},
	"tmpls/web/adv/retrieve.mail.g": {"您好，", "/goto/web/g/adv?action=startreset", "W8M 广告平台"},
	"tmpls/web/pub/retrieve.mail.g": {"您好，", "/goto/web/g/pub?action=startreset", "W8M 广告平台"},
	"summer/adv/filter.go":          {"W8M 广告主账户邮箱验证", "W8M 广告主账户密码重置"},
	"summer/pub/filter.go":          {"W8M 流量方账户邮箱验证", "W8M 流量方账户密码重置"},
	"tmpls/web/adv/startreset.g": {
		`name="action" value="resetpass"`,
		`name="adv_id"`,
		`name="email"`,
		`name="stamp"`,
		`name="firstname"`,
		`name="lastname"`,
		`name="md5"`,
	},
	"tmpls/web/pub/startreset.g": {
		`name="action" value="resetpass"`,
		`name="pub_id"`,
		`name="email"`,
		`name="stamp"`,
		`name="firstname"`,
		`name="lastname"`,
		`name="md5"`,
	},
	"tmpls/web/adv/retrieve.e":      {"Check Your Email", "The link is valid for 24 hours"},
	"tmpls/web/pub/retrieve.e":      {"Check Your Email", "The link is valid for 24 hours"},
	"tmpls/web/adv/insert.mail.e":   {"Activate Account", "W8M Advertising Platform"},
	"tmpls/web/pub/insert.mail.e":   {"Activate Account", "W8M Advertising Platform"},
	"tmpls/web/adv/retrieve.mail.e": {"Reset Password", "W8M Advertising Platform"},
	"tmpls/web/pub/retrieve.mail.e": {"Reset Password", "W8M Advertising Platform"},
}

var accountActions = []string{
	"activate",
	"insert",
	"insert.mail",
	"resetpass",
	"retrieve",
	"retrieve.mail",
	"startnew",
	"startreset",
	"startretrieve",
}

var capabilityModalIDs = []string{
	"capability-dsp",
	"capability-ssp",
	"capability-openrtb",
	"capability-measurement",
	"capability-security",
	"capability-quality",
	"capability-accounting",
	"capability-operations",
}

var roleGuideModalIDs = []string{
	"role-guide-advertiser",
	"role-guide-publisher",
}

var journeyModalIDs = []string{
	"journey-advertiser-campaign",
	"journey-advertiser-ad-group",
	"journey-advertiser-creative",
	"journey-advertiser-reporting",
	"journey-publisher-source",
	"journey-publisher-slot",
	"journey-publisher-integration",
	"journey-publisher-validation",
}

func main() {
	root := flag.String("root", ".", "pzdesign repository root")
	flag.Parse()

	failures, err := check(*root)
	if err != nil {
		fmt.Fprintln(os.Stderr, err)
		os.Exit(2)
	}
	if len(failures) > 0 {
		for _, failure := range failures {
			fmt.Fprintln(os.Stderr, failure)
		}
		fmt.Fprintf(os.Stderr, "public copy failures: %d\n", len(failures))
		os.Exit(1)
	}
	fmt.Println("public copy failures: 0")
}

func check(root string) ([]string, error) {
	files, err := publicFiles(root)
	if err != nil {
		return nil, err
	}

	var failures []string
	for _, role := range []string{"adv", "pub"} {
		for _, action := range accountActions {
			for _, edition := range []string{"g", "e"} {
				path := filepath.Join(root, "tmpls", "web", role, action+"."+edition)
				if _, err := os.Stat(path); err != nil {
					if os.IsNotExist(err) {
						rel, _ := filepath.Rel(root, path)
						failures = append(failures, fmt.Sprintf("missing public template: %s", filepath.ToSlash(rel)))
						continue
					}
					return nil, err
				}
			}
		}
	}

	for _, file := range files {
		body, err := os.ReadFile(file.path)
		if err != nil {
			return nil, err
		}
		text := string(body)
		rel, err := filepath.Rel(root, file.path)
		if err != nil {
			return nil, err
		}
		rel = filepath.ToSlash(rel)
		copyFailures, err := checkCopy(rel, file.language, text)
		if err != nil {
			return nil, err
		}
		failures = append(failures, copyFailures...)
	}

	for rel, snippets := range requiredSnippets {
		path := filepath.Join(root, filepath.FromSlash(rel))
		body, err := os.ReadFile(path)
		if err != nil {
			if os.IsNotExist(err) {
				failures = append(failures, fmt.Sprintf("missing required public file: %s", rel))
				continue
			}
			return nil, err
		}
		for _, snippet := range snippets {
			if !strings.Contains(string(body), snippet) {
				failures = append(failures, fmt.Sprintf("%s is missing required copy or contract %q", rel, snippet))
			}
		}
	}

	for _, rel := range []string{"www/index.html", "www/index.en.html"} {
		body, err := os.ReadFile(filepath.Join(root, filepath.FromSlash(rel)))
		if err != nil {
			return nil, err
		}
		failures = append(failures, checkIndexStructure(rel, string(body))...)
	}

	// Check hreflang bidirectionality for language pairs: index.html <-> index.en.html, etc.
	// For each .en.html file, ensure both it and its .html counterpart have reciprocal hreflang tags
	langPairs := [][2]string{
		{"www/index.html", "www/index.en.html"},
		{"www/manuals/advertiser.html", "www/manuals/advertiser.en.html"},
		{"www/manuals/publisher.html", "www/manuals/publisher.en.html"},
	}
	for _, pair := range langPairs {
		chinesePath := filepath.Join(root, pair[0])
		englishPath := filepath.Join(root, pair[1])
		chineseBody, err := os.ReadFile(chinesePath)
		if err != nil {
			return nil, err
		}
		englishBody, err := os.ReadFile(englishPath)
		if err != nil {
			return nil, err
		}
		if !hasAlternateLink(string(chineseBody), filepath.Base(englishPath), "en") {
			failures = append(failures, fmt.Sprintf("%s lacks an English alternate link to %s", pair[0], pair[1]))
		}
		if !hasAlternateLink(string(englishBody), filepath.Base(chinesePath), "zh-CN") {
			failures = append(failures, fmt.Sprintf("%s lacks a Chinese alternate link to %s", pair[1], pair[0]))
		}
	}

	sort.Strings(failures)
	return failures, nil
}

func checkIndexStructure(rel, text string) []string {
	var failures []string
	wantModalTriggers := len(capabilityModalIDs) + len(roleGuideModalIDs) + len(journeyModalIDs)
	if got := strings.Count(text, `data-toggle="modal"`); got != wantModalTriggers {
		failures = append(failures, fmt.Sprintf("%s has %d modal triggers, want %d", rel, got, wantModalTriggers))
	}
	if got := strings.Count(text, `class="modal fade capability-modal" id="capability-`); got != len(capabilityModalIDs) {
		failures = append(failures, fmt.Sprintf("%s has %d capability modals, want %d", rel, got, len(capabilityModalIDs)))
	}
	if got := strings.Count(text, `capability-card-measurement`); got != len(capabilityModalIDs)*2 {
		failures = append(failures, fmt.Sprintf("%s has %d measurement-themed capability elements, want %d", rel, got, len(capabilityModalIDs)*2))
	}
	for _, modalID := range capabilityModalIDs {
		if strings.Count(text, `data-target="#`+modalID+`"`) != 1 {
			failures = append(failures, fmt.Sprintf("%s must contain one trigger for #%s", rel, modalID))
		}
		if strings.Count(text, `id="`+modalID+`"`) != 1 {
			failures = append(failures, fmt.Sprintf("%s must contain one modal with id %s", rel, modalID))
		}
	}
	if got := strings.Count(text, `class="modal fade capability-modal role-guide-modal`); got != len(roleGuideModalIDs) {
		failures = append(failures, fmt.Sprintf("%s has %d role-guide modals, want %d", rel, got, len(roleGuideModalIDs)))
	}
	for _, modalID := range roleGuideModalIDs {
		if strings.Count(text, `data-target="#`+modalID+`"`) != 1 {
			failures = append(failures, fmt.Sprintf("%s must contain one trigger for #%s", rel, modalID))
		}
		if strings.Count(text, `id="`+modalID+`"`) != 1 {
			failures = append(failures, fmt.Sprintf("%s must contain one modal with id %s", rel, modalID))
		}
	}
	if got := strings.Count(text, `class="modal fade capability-modal journey-modal`); got != len(journeyModalIDs) {
		failures = append(failures, fmt.Sprintf("%s has %d journey modals, want %d", rel, got, len(journeyModalIDs)))
	}
	if got := strings.Count(text, `class="journey-step journey-step-action`); got != len(journeyModalIDs) {
		failures = append(failures, fmt.Sprintf("%s has %d clickable journey cards, want %d", rel, got, len(journeyModalIDs)))
	}
	if got := strings.Count(text, `role="button" tabindex="0" data-toggle="modal" data-target="#journey-`); got != len(journeyModalIDs) {
		failures = append(failures, fmt.Sprintf("%s has %d keyboard-accessible journey cards, want %d", rel, got, len(journeyModalIDs)))
	}
	for _, modalID := range journeyModalIDs {
		if strings.Count(text, `data-target="#`+modalID+`"`) != 1 {
			failures = append(failures, fmt.Sprintf("%s must contain one trigger for #%s", rel, modalID))
		}
		if strings.Count(text, `id="`+modalID+`"`) != 1 {
			failures = append(failures, fmt.Sprintf("%s must contain one modal with id %s", rel, modalID))
		}
	}
	return failures
}

func hasAlternateLink(text, hrefSuffix, language string) bool {
	document, err := html.Parse(strings.NewReader(text))
	if err != nil {
		return false
	}
	var found bool
	var walk func(*html.Node)
	walk = func(node *html.Node) {
		if found {
			return
		}
		if node.Type == html.ElementNode && node.Data == "link" {
			rel, _ := attribute(node, "rel")
			href, hasHref := attribute(node, "href")
			hreflang, hasHreflang := attribute(node, "hreflang")
			found = hasToken(rel, "alternate") && hasHref && hrefTargetsFile(href, hrefSuffix) && hasHreflang && strings.EqualFold(hreflang, language)
		}
		for child := node.FirstChild; child != nil && !found; child = child.NextSibling {
			walk(child)
		}
	}
	walk(document)
	return found
}

func hrefTargetsFile(href, filename string) bool {
	href = strings.SplitN(href, "#", 2)[0]
	href = strings.SplitN(href, "?", 2)[0]
	return href == filename || strings.HasSuffix(href, "/"+filename)
}

func rendersRawFrameworkError(text string) bool {
	for remainder := text; ; {
		start := strings.Index(remainder, "{{")
		if start < 0 {
			return false
		}
		remainder = remainder[start+2:]
		end := strings.Index(remainder, "}}")
		if end < 0 {
			return false
		}
		action := strings.TrimSpace(remainder[:end])
		for _, field := range []string{".Errorstr", ".Errstr"} {
			if action == field || strings.HasPrefix(action, field+" ") || strings.HasPrefix(action, field+"|") {
				return true
			}
		}
		remainder = remainder[end+2:]
	}
}

func checkCopy(rel, language, text string) ([]string, error) {
	var failures []string
	for _, phrase := range deprecatedChineseCopy {
		if strings.Contains(text, phrase) {
			failures = append(failures, fmt.Sprintf("%s contains disallowed public copy %q", rel, phrase))
		}
	}
	if language == "zh" {
		for _, phrase := range untranslatedEnglishCopy {
			if strings.Contains(text, phrase) {
				failures = append(failures, fmt.Sprintf("%s contains untranslated public copy %q", rel, phrase))
			}
		}
	}
	if rendersRawFrameworkError(text) {
		failures = append(failures, fmt.Sprintf("%s renders a raw framework error", rel))
	}
	linkFailures, err := checkEditionLinks(rel, language, text)
	if err != nil {
		return nil, err
	}
	return append(failures, linkFailures...), nil
}

func checkEditionLinks(rel, language, text string) ([]string, error) {
	opposite := "e"
	if language == "en" {
		opposite = "g"
	}
	targets := make([]string, 0, 5)
	for _, role := range []string{"adv", "pub", "agent", "admin", "web"} {
		targets = append(targets, "/goto/"+role+"/"+opposite+"/")
	}

	document, err := html.Parse(strings.NewReader(text))
	if err != nil {
		return nil, fmt.Errorf("parse %s links: %w", rel, err)
	}
	var failures []string
	var walk func(*html.Node)
	walk = func(node *html.Node) {
		if node.Type == html.ElementNode && (node.Data == "a" || node.Data == "link") {
			href, ok := attribute(node, "href")
			if ok {
				for _, target := range targets {
					if strings.Contains(href, target) && !isAllowedLanguageLink(node, opposite) {
						failures = append(failures, fmt.Sprintf("%s contains opposite-edition link %q outside a language toggle or alternate link", rel, href))
						break
					}
				}
			}
		}
		for child := node.FirstChild; child != nil; child = child.NextSibling {
			walk(child)
		}
	}
	walk(document)
	return failures, nil
}

func isAllowedLanguageLink(node *html.Node, opposite string) bool {
	if node.Data == "link" {
		rel, _ := attribute(node, "rel")
		_, hasHreflang := attribute(node, "hreflang")
		return hasToken(rel, "alternate") && hasHreflang
	}
	classes, _ := attribute(node, "class")
	if hasToken(classes, "lang-toggle") {
		return true
	}
	dataToggle, hasDataToggle := attribute(node, "data-lang-toggle")
	want := "en"
	if opposite == "g" {
		want = "zh"
	}
	return hasDataToggle && dataToggle == want
}

func attribute(node *html.Node, key string) (string, bool) {
	for _, item := range node.Attr {
		if strings.EqualFold(item.Key, key) {
			return item.Val, true
		}
	}
	return "", false
}

func hasToken(value, token string) bool {
	for _, item := range strings.Fields(value) {
		if strings.EqualFold(item, token) {
			return true
		}
	}
	return false
}

func publicFiles(root string) ([]publicFile, error) {
	files := []publicFile{
		{path: filepath.Join(root, "www", "index.html"), language: "zh"},
		{path: filepath.Join(root, "www", "index.en.html"), language: "en"},
		{path: filepath.Join(root, "www", "manuals", "advertiser.html"), language: "zh"},
		{path: filepath.Join(root, "www", "manuals", "advertiser.en.html"), language: "en"},
		{path: filepath.Join(root, "www", "manuals", "publisher.html"), language: "zh"},
		{path: filepath.Join(root, "www", "manuals", "publisher.en.html"), language: "en"},
	}
	templateRoot := filepath.Join(root, "tmpls")
	if err := filepath.WalkDir(templateRoot, func(path string, entry os.DirEntry, err error) error {
		if err != nil {
			return err
		}
		if entry.IsDir() {
			return nil
		}
		switch filepath.Ext(path) {
		case ".g":
			files = append(files, publicFile{path: path, language: "zh"})
		case ".e":
			files = append(files, publicFile{path: path, language: "en"})
		}
		return nil
	}); err != nil {
		return nil, err
	}
	sort.Slice(files, func(i, j int) bool { return files[i].path < files[j].path })
	return files, nil
}
