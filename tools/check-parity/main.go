package main

import (
	"bufio"
	"flag"
	"fmt"
	"os"
	"path/filepath"
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
				if !exempt[rel] {
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

		if err := compareForms(rel, eRel, gText, eText, exempt); err != nil {
			failures = append(failures, err.Error())
		}
	}

	sort.Strings(failures)
	return failures, nil
}

func compareForms(gRel, eRel, gText, eText string, exempt map[string]bool) error {
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
		if !exempt[exemptKey] {
			return fmt.Errorf("%s form field names do not match %s", gRel, eRel)
		}
	}
	if !setsEqual(gActions, eActions) && !exempt[gRel+" form-actions"] {
		return fmt.Errorf("%s hidden action values do not match %s", gRel, eRel)
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
	err := filepath.WalkDir(root, func(path string, entry os.DirEntry, err error) error {
		if err != nil {
			return err
		}
		if !entry.IsDir() && filepath.Ext(path) == ext {
			depth := strings.Count(filepath.ToSlash(path), "/")
			if depth >= 3 {
				templates = append(templates, path)
			}
		}
		return nil
	})
	sort.Strings(templates)
	return templates, err
}
