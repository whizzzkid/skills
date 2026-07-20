---
skill: wk-pr-merge
date: 2026-07-20
type: gap
severity: medium
---

The Step 6 `gh pr merge` command is blocked by the auto-mode permission classifier even when the user explicitly invoked the merge skill.

**What happened:** User ran the merge skill; all gates passed; the `gh pr merge --squash --delete-branch` call was denied by the classifier, forcing a redundant confirmation since invoking the skill IS the authorization.

**Root cause:** The skill's `allowed-tools` frontmatter listed only bare `Bash`, which the auto-mode classifier still gates per-command for write actions. There was no granular pre-approval for the one write command the skill exists to run.

**Suggested fix:** Add `"Bash(gh pr merge:*)"` to the skill's own `allowed-tools` frontmatter (skill-scoped, NOT global `$HOME/.claude/settings.json`). The grant belongs with the skill that needs it so it travels with the skill and does not widen global permissions. The agent must never self-add the rule to global settings — editing `settings.json` to grant permissions is itself classifier-blocked and is the wrong scope.
