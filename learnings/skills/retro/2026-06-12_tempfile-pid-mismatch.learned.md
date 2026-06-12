---
skill: wk-retro
date: 2026-06-12
type: correction
severity: low
---

`/tmp/retro-draft.$$` fails as a temp file path when the write and read happen in separate Bash tool invocations.

**What happened:** The retro draft was written to `/tmp/retro-draft.<pid>` in one shell, but the sed command that substituted `Session-N` ran in a different shell with a different PID, so the file was not found and the substitution was skipped.

**Root cause:** Each Bash tool call spawns a new subprocess; `$$` expands to the PID of that subprocess. A path using `$$` is only valid within the same tool call, never across multiple calls.

**Suggested fix:** Use a fixed, predictable temp path (e.g., `/tmp/retro-draft-wkretro.md`) instead of `$$`, or write the entire draft and append in a single heredoc within one tool call to avoid the cross-invocation dependency.
