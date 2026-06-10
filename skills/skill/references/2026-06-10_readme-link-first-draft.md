---
class: principle
date: 2026-06-10
severity: medium
---

- **Rule:** Linkify every `wk-*` mention in a new skill's README from the first
  draft (or drop backticks); even placeholder `wk-<name>` examples must be
  links or non-backticked.
- **Why:** A bare backticked `wk-foo` trips the check-skill-links pre-commit
  hook and forces a re-commit.
- **Where:** Step 6 (README authoring) — linkify bullet.
