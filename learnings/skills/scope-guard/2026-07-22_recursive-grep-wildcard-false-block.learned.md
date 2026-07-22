---
skill: wk-scope-guard
date: 2026-07-22
type: gap
severity: low
---

`grep -r` (or `-rl`) with a wildcard glob argument (e.g. `*.go`) gets blocked as "search outside the project root" even when CWD already equals the repo/worktree root the guard resolves — despite an equivalent non-recursive `grep` call (explicit filenames, no `-r`) from the same CWD passing cleanly.

**What happened:** While working inside a git worktree nested under a different repo's working tree, `grep -rln "pattern" *.go` was blocked by the scope-guard hook even though `git -C CWD rev-parse --show-toplevel` for that CWD resolves inside the worktree itself. The otherwise-identical non-recursive form (`grep -n "pattern" file1.go file2.go`) succeeded.

**Root cause:** The hook's lexical token inspection appears to treat `-r`/`-rl`-style recursive flags combined with an unexpanded glob token (`*.go`) as an ambiguous/unbounded search root, independent of the resolved CWD-based repo root check that governs the non-recursive path.

**Suggested fix:** When working in a nested worktree and a recursive grep is blocked, don't retry with `SCOPE_GUARD_OFF=1` as a command prefix (env vars set inside a Bash tool call do not persist to the hook's separate process). Instead: list files explicitly first (`ls *.go`) and grep by explicit filename list, or avoid `-r` entirely when CWD already matches the intended search root.
