---
skill: wk-workflow
date: 2026-10-08
type: correction
severity: low
verified-against-source: yes
---

"Open the file" used macOS `open`, which launched the system default editor instead of the user's IDE.

**What happened:** The user asked to open a proposal; `open <file>` picked the OS default app, and the user redirected to the `$IDE` env var.

**Root cause:** No rule tells the agent to resolve the editor from `$IDE` / `$VISUAL` / `$EDITOR` before falling back to `open`.

**Suggested fix:** When asked to open a file for the user, launch `${IDE:-${VISUAL:-open}}` (strip any `--wait` from `$EDITOR`); never default to `open`.
