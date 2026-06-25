---
skill: wk-workflow
date: 2026-06-25
type: gap
severity: medium
---

Claude Code plugin cache takes priority over worktree installs during SKILL.md development.

**What happened:** After editing a SKILL.md in a worktree, the Skill tool loaded the cached version from `$HOME/.claude/plugins/cache/<org>/<plugin>/<version>/` instead of the modified worktree file. The skill session-caches at first load, so changes weren't visible without copying the file to the cache path or starting a new session.

**Root cause:** The plugin cache ($HOME/.claude/plugins/cache/) is checked before the worktree-local install, and the Skill tool caches loaded content per-session. The worktree version is only active when no cached version exists.

**Suggested fix:** When developing/testing SKILL.md changes, add a step: "Copy updated SKILL.md to the plugin cache path OR start a fresh session after installing — in-session Skill tool calls will load the cached version, not the worktree version."
