---
skill: wk-sharpen
date: 2026-07-24
type: gap
severity: low
---

Batch-mode Source 1 scans a directory outside the repo root, so the shipped scope guard blocks the obvious recursive enumeration.

**What happened:** Batch mode instructs mirroring unprocessed learnings from the
global inbox under `$HOME/.claude/skills/`, which lies outside the repo root. The
natural `find <inbox> -type f` tripped the suite's own scope-guard hook, which
blocks any recursive search rooted outside the repo. A non-recursive `ls -A` on
the specific inbox subdirectories answered the same question and passed the guard.

**Root cause:** Source 1 names the directory to scan but not how to enumerate it.
The guard is correct to block recursive out-of-repo traversal, and the documented
opt-out must never be self-authorized, so the agent must reach the guard-compatible
form by improvisation on every run.

**Suggested fix:** Have Source 1 prescribe the enumeration shape it needs —
non-recursive listing of the known inbox subdirectories, not a recursive walk —
and state that the guard block is expected rather than a defect to route around.
Do not weaken the guard, and do not suggest the opt-out as the remedy.
