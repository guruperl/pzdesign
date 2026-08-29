package main

import (
	"bufio"
	"flag"
	"fmt"
	"os"
	"path/filepath"
	"regexp"
	"sort"
	"strings"

	"golang.org/x/net/html"
)

func main() {
	root := flag.String("root", ".", "pzdesign repository root")
	exemptFile := flag.String("exempt", "tools/check-parity/exempt.txt", "exemption file path")
	flag.Parse()

	failures, err := check(*root, *exemptFile)
	if err != nil {
		fmt.Fprintln(os.Stderr, err)
		os.Exit(2)
	}
	if len(failures) > 0 {
		for _, failure := range failures {
			fmt.Fprintln(os.Stderr, failure)
		}
		fmt.Fprintf(os.Stderr, "parity failures: %d\n", len(failures))
		os.Exit(1)
	}
	fmt.Println("parity failures: 0")
}

func check(root, exemptFile string) ([]string, error) {
	exempt, err := readExemptions(exemptFile)
	if err != nil {
		return nil, err
	}
	usedExemptions := make(map[string]bool)

	var failures []string

	gTemplates, err := findTemplates(root, ".g")
	if err != nil {
		return nil, err
	}

	for _, gPath := range gTemplates {
		rel, _ := filepath.Rel(root, gPath)
		rel = filepath.ToSlash(rel)

		ePath := strings.TrimSuffix(gPath, ".g") + ".e"

		if _, err := os.Stat(ePath); err != nil {
			if os.IsNotExist(err) {
				if exempt[rel] {
					usedExemptions[rel] = true
				} else {
					failures = append(failures, fmt.Sprintf("missing %s twin for %s", filepath.Base(ePath), rel))
				}
				continue
			}
			return nil, err
		}

		eRel, _ := filepath.Rel(root, ePath)
		eRel = filepath.ToSlash(eRel)

		gBody, err := os.ReadFile(gPath)
		if err != nil {
			return nil, err
		}
		eBody, err := os.ReadFile(ePath)
		if err != nil {
			return nil, err
		}

		gText := string(gBody)
		eText := string(eBody)

		unexpectedHan, err := containsUnexpectedHan(eText)
		if err != nil {
			return nil, fmt.Errorf("parse %s English copy: %w", eRel, err)
		}
		if unexpectedHan {
			failures = append(failures, fmt.Sprintf("%s contains untranslated Chinese copy", eRel))
		}

		if err := compareForms(rel, eRel, gText, eText, exempt, usedExemptions); err != nil {
			failures = append(failures, err.Error())
		}
		if err := compareStructure(rel, eRel, gText, eText, exempt, usedExemptions); err != nil {
			failures = append(failures, err.Error())
		}
	}
	for exemption := range exempt {
		if !usedExemptions[exemption] {
			failures = append(failures, fmt.Sprintf("stale parity exemption: %s", exemption))
		}
	}

	sort.Strings(failures)
	return failures, nil
}

var (
	editionRoutePattern   = regexp.MustCompile(`(/goto/[^/[:space:]"']+/)[ge](/)`)
	templateActionPattern = regexp.MustCompile(`{{[^{}]*}}`)
	confirmSinglePattern  = regexp.MustCompile(`confirm\('[^']*'\)`)
	confirmDoublePattern  = regexp.MustCompile(`confirm\("[^"]*"\)`)
	hanPattern            = regexp.MustCompile(`\p{Han}`)
)

func compareStructure(gRel, eRel, gText, eText string, exempt, usedExemptions map[string]bool) error {
	gStructure, err := extractStructure(gText)
	if err != nil {
		return fmt.Errorf("parse %s structure: %w", gRel, err)
	}
	eStructure, err := extractStructure(eText)
	if err != nil {
		return fmt.Errorf("parse %s structure: %w", eRel, err)
	}
	if !slicesEqual(gStructure, eStructure) {
		exemption := gRel + " structure"
		if exempt[exemption] {
			usedExemptions[exemption] = true
		} else {
			return fmt.Errorf("%s structure does not match %s: %s", gRel, eRel, firstStructuralDifference(gStructure, eStructure))
		}
	}
	return nil
}

func containsUnexpectedHan(text string) (bool, error) {
	document, err := html.Parse(strings.NewReader(text))
	if err != nil {
		return false, err
	}
	var found bool
	var walk func(*html.Node, bool)
	walk = func(node *html.Node, allowHan bool) {
		if found {
			return
		}
		if node.Type == html.ElementNode {
			chartag := parityAttribute(node, "data-chartag-toggle")
			classes := parityAttribute(node, "class")
			if node.Data == "a" && strings.EqualFold(chartag, "g") && hasClassToken(classes, "lang-toggle") {
				allowHan = true
			}
			if !allowHan {
				for _, attribute := range node.Attr {
					if hanPattern.MatchString(attribute.Val) {
						found = true
						return
					}
				}
			}
		}
		if node.Type == html.TextNode && !allowHan && hanPattern.MatchString(node.Data) {
			found = true
			return
		}
		for child := node.FirstChild; child != nil; child = child.NextSibling {
			walk(child, allowHan)
		}
	}
	walk(document, false)
	return found, nil
}

func parityAttribute(node *html.Node, key string) string {
	for _, attribute := range node.Attr {
		if strings.EqualFold(attribute.Key, key) {
			return attribute.Val
		}
	}
	return ""
}

func hasClassToken(classes, token string) bool {
	for _, class := range strings.Fields(classes) {
		if strings.EqualFold(class, token) {
			return true
		}
	}
	return false
}

func firstStructuralDifference(gStructure, eStructure []string) string {
	limit := len(gStructure)
	if len(eStructure) < limit {
		limit = len(eStructure)
	}
	for index := 0; index < limit; index++ {
		if gStructure[index] != eStructure[index] {
			return fmt.Sprintf("token %d is %q vs %q", index+1, gStructure[index], eStructure[index])
		}
	}
	return fmt.Sprintf("token counts are %d vs %d", len(gStructure), len(eStructure))
}

// extractStructure retains the element tree, functional attributes, and Go
// template actions while discarding prose that is expected to be translated.
// Chinese templates are therefore free to supply the copy, but not a different
// form, route, conditional, asset, or page layout from their English twins.
func extractStructure(text string) ([]string, error) {
	document, err := html.Parse(strings.NewReader(text))
	if err != nil {
		return nil, err
	}
	var structure []string
	var walk func(*html.Node)
	walk = func(node *html.Node) {
		switch node.Type {
		case html.ElementNode:
			attributes := make(map[string]string, len(node.Attr))
			for _, attribute := range node.Attr {
				attributes[strings.ToLower(attribute.Key)] = attribute.Val
			}
			keys := make([]string, 0, len(attributes))
			for key := range attributes {
				if structuralAttribute(node.Data, key, attributes) {
					keys = append(keys, key)
				}
			}
			sort.Strings(keys)
			var token strings.Builder
			token.WriteByte('<')
			token.WriteString(node.Data)
			for _, key := range keys {
				token.WriteByte(' ')
				token.WriteString(key)
				token.WriteByte('=')
				token.WriteString(normalizeStructuralValue(attributes[key]))
			}
			token.WriteByte('>')
			structure = append(structure, token.String())
			for child := node.FirstChild; child != nil; child = child.NextSibling {
				walk(child)
			}
			structure = append(structure, "</"+node.Data+">")
			return
		case html.TextNode:
			for _, action := range templateActionPattern.FindAllString(node.Data, -1) {
				structure = append(structure, normalizeStructuralValue(action))
			}
		}
		for child := node.FirstChild; child != nil; child = child.NextSibling {
			walk(child)
		}
	}
	walk(document)
	return structure, nil
}

func structuralAttribute(tag, key string, attributes map[string]string) bool {
	switch key {
	case "lang", "title", "placeholder", "aria-label", "alt", "data-language", "data-chartag-toggle", "data-title":
		return false
	case "content":
		return tag != "meta" || (attributes["name"] != "description" && attributes["name"] != "keyword" && attributes["name"] != "keywords")
	case "value":
		if tag == "button" {
			return false
		}
		if tag == "input" {
			switch strings.ToLower(attributes["type"]) {
			case "button", "reset", "submit":
				return false
			}
		}
	}
	return true
}

func normalizeStructuralValue(value string) string {
	value = editionRoutePattern.ReplaceAllString(value, `${1}{edition}${2}`)
	value = strings.ReplaceAll(value, ".en.html", ".html")
	value = strings.ReplaceAll(value, ".label_chinese", ".label")
	value = strings.ReplaceAll(value, ".channel_name_g", ".channel_name")
	value = strings.ReplaceAll(value, ".qa_device_g", ".qa_device")
	value = strings.ReplaceAll(value, ".qa_chinese", ".qa_mime")
	value = strings.ReplaceAll(value, ".Other.itemAttrsChinese", ".Other.itemAttrs")
	value = strings.ReplaceAll(value, ".Other.slotAttrsChinese", ".Other.slotAttrs")
	value = strings.ReplaceAll(value, ".Other.slotsChinese", ".Other.slots")
	value = strings.ReplaceAll(value, ".Other.itemsChinese", ".Other.items")
	value = strings.ReplaceAll(value, ".Other.aclChinese", ".Other.acl")
	value = strings.ReplaceAll(value, ".Other.dtChinese", ".Other.dt")
	value = strings.ReplaceAll(value, ".Other.pzuaChinese", ".Other.pzua")
	value = strings.ReplaceAll(value, ".Other.demoChinese", ".Other.demo")
	value = strings.ReplaceAll(value, ".Other.uploadChinese", ".Other.upload")
	value = confirmSinglePattern.ReplaceAllString(value, "confirm({translated-copy})")
	value = confirmDoublePattern.ReplaceAllString(value, "confirm({translated-copy})")
	value = templateActionPattern.ReplaceAllStringFunc(value, func(action string) string {
		body := strings.TrimSuffix(strings.TrimPrefix(action, "{{"), "}}")
		return "{{" + strings.Join(strings.Fields(body), " ") + "}}"
	})
	return strings.Join(strings.Fields(value), " ")
}

func slicesEqual(a, b []string) bool {
	if len(a) != len(b) {
		return false
	}
	for index := range a {
		if a[index] != b[index] {
			return false
		}
	}
	return true
}

func compareForms(gRel, eRel, gText, eText string, exempt, usedExemptions map[string]bool) error {
	gNames, gActions, err := extractFormContracts(gText)
	if err != nil {
		return fmt.Errorf("parse %s form contracts: %w", gRel, err)
	}
	eNames, eActions, err := extractFormContracts(eText)
	if err != nil {
		return fmt.Errorf("parse %s form contracts: %w", eRel, err)
	}

	if !setsEqual(gNames, eNames) {
		exemptKey := gRel + " form-fields"
		if exempt[exemptKey] {
			usedExemptions[exemptKey] = true
		} else {
			return fmt.Errorf("%s form field names do not match %s", gRel, eRel)
		}
	}
	if !setsEqual(gActions, eActions) {
		exemptKey := gRel + " form-actions"
		if exempt[exemptKey] {
			usedExemptions[exemptKey] = true
		} else {
			return fmt.Errorf("%s hidden action values do not match %s", gRel, eRel)
		}
	}

	return nil
}

func extractFormContracts(text string) (map[string]bool, map[string]bool, error) {
	names := make(map[string]bool)
	actions := make(map[string]bool)
	document, err := html.Parse(strings.NewReader(text))
	if err != nil {
		return nil, nil, err
	}
	var walk func(*html.Node)
	walk = func(node *html.Node) {
		if node.Type == html.ElementNode {
			switch node.Data {
			case "input", "select", "textarea", "button":
				attributes := make(map[string]string, len(node.Attr))
				for _, attribute := range node.Attr {
					attributes[strings.ToLower(attribute.Key)] = attribute.Val
				}
				name := attributes["name"]
				if name == "action" && node.Data == "input" && strings.EqualFold(attributes["type"], "hidden") {
					actions[attributes["value"]] = true
				} else if name != "" {
					names[name] = true
				}
			}
		}
		for child := node.FirstChild; child != nil; child = child.NextSibling {
			walk(child)
		}
	}
	walk(document)
	return names, actions, nil
}

func setsEqual(a, b map[string]bool) bool {
	if len(a) != len(b) {
		return false
	}
	for k := range a {
		if !b[k] {
			return false
		}
	}
	return true
}

func readExemptions(path string) (map[string]bool, error) {
	exempt := make(map[string]bool)
	file, err := os.Open(path)
	if err != nil {
		if os.IsNotExist(err) {
			return exempt, nil
		}
		return nil, err
	}
	defer file.Close()

	scanner := bufio.NewScanner(file)
	for scanner.Scan() {
		line := strings.TrimSpace(scanner.Text())
		if line != "" && !strings.HasPrefix(line, "#") {
			exempt[line] = true
		}
	}
	return exempt, scanner.Err()
}

func findTemplates(root string, ext string) ([]string, error) {
	var templates []string
	templateRoot := filepath.Join(root, "tmpls")
	err := filepath.WalkDir(templateRoot, func(path string, entry os.DirEntry, err error) error {
		if err != nil {
			return err
		}
		if !entry.IsDir() && filepath.Ext(path) == ext {
			templates = append(templates, path)
		}
		return nil
	})
	sort.Strings(templates)
	return templates, err
}
