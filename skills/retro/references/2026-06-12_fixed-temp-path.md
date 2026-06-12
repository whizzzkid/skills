---
class: principle
date: 2026-06-12
skill: wk-retro
---

- **Rule:** Use a fixed temp path (e.g. `/tmp/retro-draft-wkretro.md`), not
  `$$`, for files shared across Bash tool calls.
- **Why:** Each Bash tool call is a new subprocess; `$$` differs between the
  write call and a later read/sed call, so the file is not found and the step
  is silently skipped.
- **Where:** Validation gate code block — replaced `$$` paths with fixed slugs.
