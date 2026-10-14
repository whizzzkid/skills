---
class: principle
---

# Open local files in the user's IDE, not the OS default app

**Rule**

- Asked to open a local file for the user → `"${IDE:-open}" <file>`.
- Bare `open` is only for URLs, or files when `$IDE` is unset.
- Never launch a terminal editor or a `--wait` command from Bash; it blocks the tool call.

**Why**

- `open <file>` launched the system default editor and the user redirected to `$IDE`.

**Rejected suggestion**

- The learning proposed `${IDE:-${VISUAL:-open}}`. `$VISUAL` is often a terminal editor (vim, nvim), which would
  hang a non-interactive Bash call, so the fallback chain stops at `$IDE`. `$EDITOR` is excluded for the same reason
  and because it commonly carries `--wait`.

**Where**

`skills/workflow/SKILL.md` → Phase 2 → Code standards.
