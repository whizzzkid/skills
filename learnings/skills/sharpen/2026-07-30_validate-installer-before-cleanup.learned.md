---
skill: wk-sharpen
date: 2026-07-30
type: correction
severity: high
verified-against-source: yes
---

Validate installer prerequisites before removing the active installation.

**What happened:** The required post-change installer removed existing global
skill copies, then exited because its package runner was absent from the
non-login shell. The global installation stayed empty until a login-shell retry.

**Root cause:** The installer performs destructive cleanup before resolving and
validating the executable needed for replacement, with no rollback path.

**Suggested fix:** Resolve and validate every install prerequisite before
cleanup. Build the replacement first when practical; only remove the active
installation once a complete replacement can be installed.
