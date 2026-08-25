---
class: principle
---

**Rule:** After merge, route each follow-up item via AskUserQuestion with three options — start now, generate a handoff prompt, or file a ticket — before worktree cleanup. Options 1 and 2 need local context that cleanup destroys.

**Why:** The prior flow only offered ticket filing. Starting work immediately or generating a handoff prompt are equally valid dispositions, and both require the worktree to still exist for context (file paths, merge SHA, local state).

**Where:** `SKILL.md` → Step 8 follow-ups output.
