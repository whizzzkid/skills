---
class: principle
---

**Rule:** To test an edited `SKILL.md` in-session, copy it to the plugin cache path
or start a fresh session. Re-invoking the `Skill` tool after `npx skills add` alone
still loads the stale cached content.

**Why:** The plugin cache (`$HOME/.claude/plugins/cache/`) is checked before the
worktree install, and the Skill tool caches loaded content per-session. The worktree
version is only active when no cached version exists, so in-session edits are
invisible until the cache is refreshed or the session restarts.

**Where:** wk-sharpen Step 8 → Install/verify.
