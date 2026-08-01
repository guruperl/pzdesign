# Security Policy

Report vulnerabilities and suspected data exposure through GitHub's private
vulnerability reporting for this repository, not through a public issue.

Templates, static assets, tests, and examples must not contain live account
details, runtime logs, uploaded customer media, production paths, or secrets.
Run these checks before opening a pull request:

```bash
./tools/check-public-data.sh
gitleaks git --redact .
```

If a live credential is exposed, revoke or rotate it first. Removing it from a
later commit does not make the earlier public value safe.
