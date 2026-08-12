---
skill: wk-gh
date: 2026-08-10
type: correction
severity: medium
verified-against-source: yes
---

Treat sandboxed authentication failures as environment failures until an authenticated login-shell probe confirms
the account state.

**What happened:** A restricted command reported that the stored GitHub credential was invalid even though the user
was already authenticated. The same account and command succeeded outside the sandbox.

**Root cause:** The restricted environment could neither reach the GitHub API nor access the operating-system
keychain. `gh auth status` collapsed those access failures into a misleading invalid-token result.

**Suggested fix:** When both stored-token access and API connectivity fail in a sandbox, rerun a read-only
`gh api user` and `gh auth status` probe in the authenticated login environment before asking the user to log in or
declaring authentication broken.
