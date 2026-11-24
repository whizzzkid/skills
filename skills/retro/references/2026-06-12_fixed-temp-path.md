---
class: principle
date: 2026-06-12
skill: wk-retro
superseded-by: 2026-11-23_write-once-single-call.md
---

- **Rule:** Never let a retro temp path depend on state from another Bash tool call.
- **Why:** Each Bash tool call is a new subprocess; `$$` differs between the
  write call and a later read/sed call, so the file is not found and the step
  is silently skipped.
- **Where:** Validation gate code block.
- **Superseded:** the fixed shared path this fix introduced
  (`/tmp/retro-draft-wkretro.md`) raced concurrent sessions. The gate now runs
  as one Bash call with a per-run `mktemp` draft — see
  [`2026-11-23_write-once-single-call.md`](2026-11-23_write-once-single-call.md).
