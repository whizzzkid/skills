---
skill: wk-workflow
date: 2026-11-28
type: correction
severity: medium
verified-against-source: n/a
---

Derive go-live steps from what each merged layer actually does, and from the org's current secret-management surface.

**What happened:**
- The agent gave a go-live order that put "add the flag's targeting rule" first. But the stack's layers only
  initialize the SDK; the feature is wired to the flag in the last PR. The user corrected the order.
- The agent also told the user to set secrets with a repo-local config CLI. The user said secrets are now managed
  through the org's service-management portal.

**Root cause:**
- The agent planned the rollout as if the whole stack lands at once.
- The agent repeated a secret-setting command from a generator doc without checking that it is still the current
  path.

**Suggested fix:**
- For a stacked rollout, list what becomes live at each merge, and attach each prerequisite to the merge that
  needs it.
- For secrets, name the platform's current management surface (or ask) before quoting a CLI from docs.
