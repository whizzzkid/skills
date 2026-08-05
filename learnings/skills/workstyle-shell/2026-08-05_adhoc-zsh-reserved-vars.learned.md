---
skill: wk-workstyle-shell
date: 2026-08-05
type: correction
severity: medium
verified-against-source: yes
---

Apply zsh reserved-variable checks to compound ad hoc commands.

**What happened:** A loop variable named `path` replaced zsh's executable
search path after a signed commit, so the index-reconciliation commands failed.

**Root cause:** The existing reserved-`path` rule was verified in the owning
skill, but it was not applied while composing a multi-step ad hoc shell command.

**Suggested fix:** Apply shell reserved-variable checks to every compound zsh
command, not only committed scripts; use role-specific loop names.
