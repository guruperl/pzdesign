package main

import (
	"flag"
	"fmt"
	"go/ast"
	"go/parser"
	"go/token"
	"html/template"
	"os"
	"path/filepath"
	"regexp"
	"sort"
	"strings"
)

var assembledQueryPattern = regexp.MustCompile("\\bprint\\s+[`\"][^`\"\\n]*[A-Za-z_][A-Za-z0-9_]*=")

var templateSourceRules = []struct {
	description string
	pattern     *regexp.Regexp
}{
	{
		description: "unsafe javascript, vbscript, or HTML data URL",
		pattern:     regexp.MustCompile(`(?i)\b(?:javascript|vbscript|data:text/html)\s*:`),
	},
	{
		description: "remote executable or embedded resource; serve reviewed assets locally",
		pattern:     regexp.MustCompile(`(?is)<\s*(?:script|iframe|object|embed|source)\b[^>]*\b(?:src|data)\s*=\s*["']?\s*https?://|<\s*link\b[^>]*\bhref\s*=\s*["']?\s*https?://`),
	},
	{
		description: "template data in an executable or fetching element",
		pattern:     regexp.MustCompile(`(?is)<\s*(?:iframe|script|object|embed|img|source)\b[^>]*\{\{`),
	},
	{
		description: "raw client-side HTML sink in a page template; use text or a reviewed delivery boundary",
		pattern:     regexp.MustCompile(`(?i)\.(?:html|append|prepend)\s*\(|\b(?:innerHTML|outerHTML|insertAdjacentHTML)\b`),
	},
}

var forbiddenTemplateTypes = map[string]bool{
	"CSS":      true,
	"HTML":     true,
	"HTMLAttr": true,
	"JS":       true,
	"Srcset":   true,
	"URL":      true,
}

func main() {
	root := flag.String("root", "tmpls", "template root")
	exts := flag.String("ext", ".g", "comma-separated template extensions")
	flag.Parse()

	var failures int
	var checked int
	for _, ext := range splitExts(*exts) {
		n, f, err := checkExt(*root, ext)
		if err != nil {
			fmt.Fprintln(os.Stderr, err)
			os.Exit(2)
		}
		checked += n
		failures += f
	}
	projectRoot, err := filepath.Abs(filepath.Dir(*root))
	if err != nil {
		fmt.Fprintln(os.Stderr, err)
		os.Exit(2)
	}
	rawTypes, err := findForbiddenTemplateTypes(projectRoot)
	if err != nil {
		fmt.Fprintln(os.Stderr, err)
		os.Exit(2)
	}
	for _, finding := range rawTypes {
		fmt.Fprintf(os.Stderr, "%s: raw html/template type is outside the renderer's approved trusted boundary\n", finding)
	}
	failures += len(rawTypes)

	if failures > 0 {
		fmt.Fprintf(os.Stderr, "checked templates: %d, failures: %d\n", checked, failures)
		os.Exit(1)
	}
	fmt.Printf("checked templates: %d, failures: 0\n", checked)
}

func splitExts(raw string) []string {
	fields := strings.Split(raw, ",")
	exts := make([]string, 0, len(fields))
	for _, field := range fields {
		field = strings.TrimSpace(field)
		if field == "" {
			continue
		}
		if !strings.HasPrefix(field, ".") {
			field = "." + field
		}
		exts = append(exts, field)
	}
	return exts
}

func checkExt(root, ext string) (int, int, error) {
	var actions []string
	var unsafeQueries []string
	var unsafeSources []string
	if err := filepath.WalkDir(root, func(path string, d os.DirEntry, err error) error {
		if err != nil {
			return err
		}
		if d.IsDir() || filepath.Ext(path) != ext {
			return nil
		}
		data, err := os.ReadFile(path)
		if err != nil {
			return err
		}
		if hasAssembledQuery(data) {
			unsafeQueries = append(unsafeQueries, path)
		}
		for _, finding := range templateSourceFindings(data) {
			unsafeSources = append(unsafeSources, path+": "+finding)
		}
		rel, err := filepath.Rel(root, path)
		if err != nil {
			return err
		}
		if len(strings.Split(rel, string(os.PathSeparator))) >= 3 {
			actions = append(actions, path)
		}
		return nil
	}); err != nil {
		return 0, 0, err
	}
	sort.Strings(actions)

	failures := len(unsafeQueries) + len(unsafeSources)
	for _, path := range unsafeQueries {
		fmt.Fprintf(os.Stderr, "%s: query parameters must be written directly in URL attributes, not assembled with print\n", path)
	}
	for _, finding := range unsafeSources {
		fmt.Fprintln(os.Stderr, finding)
	}
	for _, action := range actions {
		files, err := roleFiles(root, action, ext)
		if err != nil {
			return 0, 0, err
		}
		if _, err := template.ParseFiles(files...); err != nil {
			failures++
			fmt.Fprintf(os.Stderr, "%s: %v\n", action, err)
		}
	}
	return len(actions), failures, nil
}

func hasAssembledQuery(data []byte) bool {
	return assembledQueryPattern.Match(data)
}

func templateSourceFindings(data []byte) []string {
	var findings []string
	for _, rule := range templateSourceRules {
		if rule.pattern.Match(data) {
			findings = append(findings, rule.description)
		}
	}
	return findings
}

func findForbiddenTemplateTypes(root string) ([]string, error) {
	var findings []string
	err := filepath.WalkDir(root, func(path string, d os.DirEntry, err error) error {
		if err != nil {
			return err
		}
		if d.IsDir() {
			if path != root && (d.Name() == ".git" || d.Name() == "vendor") {
				return filepath.SkipDir
			}
			return nil
		}
		if filepath.Ext(path) != ".go" {
			return nil
		}
		parsed, err := parser.ParseFile(token.NewFileSet(), path, nil, 0)
		if err != nil {
			return err
		}
		templatePackages := map[string]bool{}
		for _, imported := range parsed.Imports {
			if strings.Trim(imported.Path.Value, `"`) != "html/template" {
				continue
			}
			if imported.Name == nil {
				templatePackages["template"] = true
				continue
			}
			switch imported.Name.Name {
			case ".":
				findings = append(findings, path+": dot import of html/template")
			case "_":
			default:
				templatePackages[imported.Name.Name] = true
			}
		}
		ast.Inspect(parsed, func(node ast.Node) bool {
			selector, ok := node.(*ast.SelectorExpr)
			if !ok || !forbiddenTemplateTypes[selector.Sel.Name] {
				return true
			}
			pkg, ok := selector.X.(*ast.Ident)
			if ok && templatePackages[pkg.Name] {
				findings = append(findings, path+": template."+selector.Sel.Name)
			}
			return true
		})
		return nil
	})
	sort.Strings(findings)
	return findings, err
}

func roleFiles(root, action, ext string) ([]string, error) {
	rel, err := filepath.Rel(root, action)
	if err != nil {
		return nil, err
	}
	parts := strings.Split(rel, string(os.PathSeparator))
	if len(parts) < 3 {
		return nil, fmt.Errorf("not an action template: %s", action)
	}

	roleDir := filepath.Join(root, parts[0])
	entries, err := os.ReadDir(roleDir)
	if err != nil {
		return nil, err
	}

	files := make([]string, 0, len(entries)+1)
	for _, entry := range entries {
		if entry.IsDir() {
			continue
		}
		path := filepath.Join(roleDir, entry.Name())
		if filepath.Ext(path) == ext {
			files = append(files, path)
		}
	}
	sort.Strings(files)
	files = append(files, action)
	return files, nil
}
