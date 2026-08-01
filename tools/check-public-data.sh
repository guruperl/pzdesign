#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd -P)"
cd "$ROOT"

failed=0

check_pattern() {
	local label="$1"
	local pattern="$2"
	if git grep -nIE "$pattern" -- .; then
		printf 'public-data-check: tracked files contain %s\n' "$label" >&2
		failed=1
	fi
}

check_pattern "AWS access-key identifiers" 'A(KIA|SIA)[0-9A-Z]{16}'
check_pattern "private key material" 'BEGIN (RSA |EC |DSA |OPENSSH )?PRIVATE KEY'
check_pattern "a private home path" '/home/'peter
check_pattern "personal CSS identifiers" 'peter-'"small(er)?"
check_pattern "customer email domains" 'kinet'"\\.com"
check_pattern "retired customer exchange domains" 'leadsadx'"-trade\\.com|leads"'dsp|pine'"mobi"

if git ls-files 'logs/*' 'www/uploads/*' '*.docx' | grep -q .; then
	echo "public-data-check: runtime logs, uploads, or DOCX sources are tracked" >&2
	failed=1
fi

if [ "$failed" -ne 0 ]; then
	exit 1
fi

echo "Public-data guard passed."
