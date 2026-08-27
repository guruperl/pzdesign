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
)

var (
	nameRegex   = regexp.MustCompile(`name="([^"]*)"`)
	actionRegex = regexp.MustCompile(`name="action"\s+value="([^"]*)"`)
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
	gNames := extractNames(gText)
	eNames := extractNames(eText)

	if !setsEqual(gNames, eNames) {
		exemptKey := gRel + " form-fields"
		if !exempt[exemptKey] && !exempt[gRel+" form-fields"] {
			return fmt.Errorf("%s form field names do not match %s", gRel, eRel)
		}
	}

	return nil
}

func extractNames(text string) map[string]bool {
	names := make(map[string]bool)
	for _, match := range nameRegex.FindAllStringSubmatch(text, -1) {
		if len(match) > 1 && match[1] != "" && !strings.HasPrefix(match[1], "action") {
			names[match[1]] = true
		}
	}
	return names
}

func extractHiddenActions(text string) map[string]bool {
	actions := make(map[string]bool)
	for _, match := range actionRegex.FindAllStringSubmatch(text, -1) {
		if len(match) > 1 && match[1] != "" {
			actions[match[1]] = true
		}
	}
	return actions
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
