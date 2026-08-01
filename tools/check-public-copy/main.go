package main

import (
	"flag"
	"fmt"
	"os"
	"path/filepath"
	"sort"
	"strings"
)

var forbidden = []string{
	"商家",
	"商户",
	"流量源公司",
	"登入",
	"登陆",
	"继续管理你的",
	"连接优质广告",
	"真实流量",
	"从投放目标到可衡量的广告活动",
	"从网站或 App 到可运营的广告位",
	"Advertiser Workspace",
	"Publisher Workspace",
	"Continue",
	"Oops! You're lost.",
	"Application error.",
	"Please enter a valid email address",
	"/goto/adv/e/",
	"/goto/pub/e/",
	"/goto/agent/e/",
	"/goto/admin/e/",
}

var requiredSnippets = map[string][]string{
	"www/index.html": {
		"W8M 广告投放与媒体接入平台",
		"选择适合你的账户类型",
		"广告主使用流程",
		"媒体主接入流程",
		"平台功能",
		"账户入口",
		"使用说明与常见问题",
		"联系技术支持",
	},
	"www/manuals/advertiser.html":   {"广告主与 DSP 代理使用手册", "外部 DSP / AdX 中间商竞价"},
	"www/manuals/publisher.html":    {"媒体主使用手册", "获取并部署网页广告码"},
	"tmpls/adv/login.g":             {"广告投放管理", "广告主账户登录"},
	"tmpls/pub/login.g":             {"广告库存管理", "媒体主账户登录"},
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
	"summer/pub/filter.go":          {"W8M 媒体主账户邮箱验证", "W8M 媒体主账户密码重置"},
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
}

var accountActions = []string{
	"activate.g",
	"insert.g",
	"insert.mail.g",
	"resetpass.g",
	"retrieve.g",
	"retrieve.mail.g",
	"startnew.g",
	"startreset.g",
	"startretrieve.g",
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
			path := filepath.Join(root, "tmpls", "web", role, action)
			if _, err := os.Stat(path); err != nil {
				if os.IsNotExist(err) {
					failures = append(failures, fmt.Sprintf("missing public template: %s", filepath.ToSlash(path)))
					continue
				}
				return nil, err
			}
		}
	}

	for _, path := range files {
		body, err := os.ReadFile(path)
		if err != nil {
			return nil, err
		}
		text := string(body)
		rel, err := filepath.Rel(root, path)
		if err != nil {
			return nil, err
		}
		rel = filepath.ToSlash(rel)
		for _, phrase := range forbidden {
			if strings.Contains(text, phrase) {
				failures = append(failures, fmt.Sprintf("%s contains disallowed public copy %q", rel, phrase))
			}
		}
		if strings.Contains(text, "{{.Errorstr}}") || strings.Contains(text, "{{ .Errorstr }}") {
			failures = append(failures, fmt.Sprintf("%s renders a raw framework error", rel))
		}
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

	sort.Strings(failures)
	return failures, nil
}

func publicFiles(root string) ([]string, error) {
	files := []string{
		filepath.Join(root, "www", "index.html"),
		filepath.Join(root, "www", "manuals", "advertiser.html"),
		filepath.Join(root, "www", "manuals", "publisher.html"),
	}
	for _, role := range []string{"admin", "adv", "agent", "pub"} {
		files = append(files, filepath.Join(root, "tmpls", role, "login.g"))
	}

	webRoot := filepath.Join(root, "tmpls", "web")
	if err := filepath.WalkDir(webRoot, func(path string, entry os.DirEntry, err error) error {
		if err != nil {
			return err
		}
		if !entry.IsDir() && filepath.Ext(path) == ".g" {
			files = append(files, path)
		}
		return nil
	}); err != nil {
		return nil, err
	}
	sort.Strings(files)
	return files, nil
}
