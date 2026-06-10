---
class: principle
date: 2026-06-10
skill: wk-adversarial-review
severity: high
---

- **Rule:** Scan source **and documentation code fences** for credentials
  passed as a CLI flag value (`--password=`, `--http-password=`, `-p $X`,
  `wget --password`); flag `blocker`.
- **Why:** Flag-value credentials land in `/proc/<pid>/cmdline`, visible to
  any local user via `ps`. The sweep previously scanned source and env
  assignments only, missing doc download recipes.
- **Where:** Sweep 2.1 (Vulnerability-class), new bullet + doc-fence grep.
  Safe alternatives: `curl -u` (scrubs argv), `--netrc`, header file.
