---
skill: wk-commit
date: 2026-08-04
type: correction
severity: medium
verified-against-source: yes
---

Guard grouped stage, verify, and commit commands with `set -euo pipefail`.

**What happened:** A staging command failed, but later read-only commands continued and made the
overall shell invocation exit successfully.

**Root cause:** The dependent command sequence did not enable fail-fast shell behavior.

**Suggested fix:** Make `set -euo pipefail` mandatory for every multi-command commit sequence so a
failed stage or verification prevents the commit and any success-looking tail output.
