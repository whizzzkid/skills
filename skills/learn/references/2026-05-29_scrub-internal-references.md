---
class: principle
skill: wk-learn
date: 2026-05-29
---

# Scrub all internal references before writing a learning

- **Rule:** Never write internal/code-named projects, services, bots, repos,
  hard-coded user-land paths, or secrets into a learning file. Capture the
  principle and root cause; anonymize unavoidable tokens (`{bot}`, `{repo}`,
  `{service}`, `$EMPLOYER`/`$GITHUB_ORG`, `/tmp/agent/…`).
- **Why:** The repo is public. An internal name teaches one case and leaks
  identity; the generic mechanism teaches the class and stays org-agnostic.
- **Where:** Step 3 — HARD RULE "scrub all internal references before writing".
