---
class: principle
---

# Fail fast across dependent commit commands

**Rule** — Begin every grouped stage, verification, and commit shell with `set -euo pipefail`.

**Why** — A later read-only command can otherwise return success after staging failed, hiding the broken prerequisite.

**Where** — Staged-set verification before a grouped commit.
