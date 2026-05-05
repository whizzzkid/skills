---
skill: wk-pr-resolve
date: 2026-04-21
type: gap
severity: medium
---

`wk-pr-resolve` has no mandatory retro step at the end, causing the user to have to prompt for it.

**What happened:** Completed the full 10-step pr-resolve flow (push, replies, resolve threads, merge check, final summary) and stopped. User reminded me to run `wk-retro`. The `wk-pr` skill has an explicit "Step 6: Session Retro" that invokes `wk-retro`; `wk-pr-resolve` lacks an equivalent.

**Root cause:** The skill's Quick Reference and step list end at Step 10 with no retro instruction.

**Suggested fix:** Add a Step 11 to `wk-pr-resolve/SKILL.md`:

```
## Step 11: Session Retro

After the final summary, invoke `wk-retro` to capture session learnings.
This is mandatory — do not skip even if the session was short.
```

And add a row to the Quick Reference table:
```
| Session ends | Invoke wk-retro |
```
