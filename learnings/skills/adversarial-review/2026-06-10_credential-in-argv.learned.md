---
skill: wk-adversarial-review
date: 2026-06-10
type: gap
severity: high
---

wget/curl download snippets can expose credentials in process argv.

**What happened:** A README download recipe used `wget --http-password=$SECRET`, which puts the credential in `/proc/<pid>/cmdline` for the lifetime of the process — visible to any local user via `ps`. A bot reviewer flagged this as a secrets-handling blocker; the adversarial pre-flight missed it.

**Root cause:** The adversarial sweep looked for credentials in source code and env-var assignments, but did not scan documentation code blocks for CLI flag patterns that leak secrets into process arguments.

**Suggested fix:** Add a mechanical sweep over documentation fences and shell scripts for credential-in-argv patterns:
```bash
grep -rn -- '--password=\|--http-password=\|-p $\|-p "\|PASS=\|TOKEN=' docs/ README* **/*.sh **/*.md
```
Flag any match where a secret variable is passed as a CLI flag value (not piped or read from a file). The safe alternatives are `curl -u` (scrubs `-u` from argv), `--netrc`, or a header file.
