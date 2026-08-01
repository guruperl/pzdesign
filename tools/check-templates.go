package main

import (
	"flag"
	"fmt"
	"html/template"
	"os"
	"path/filepath"
	"regexp"
	"sort"
	"strings"
)

var assembledQueryPattern = regexp.MustCompile("\\bprint\\s+[`\"][^`\"\\n]*[A-Za-z_][A-Za-z0-9_]*=")

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

	failures := len(unsafeQueries)
	for _, path := range unsafeQueries {
		fmt.Fprintf(os.Stderr, "%s: query parameters must be written directly in URL attributes, not assembled with print\n", path)
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
