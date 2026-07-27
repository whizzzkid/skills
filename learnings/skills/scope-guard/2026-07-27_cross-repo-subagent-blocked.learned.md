---
skill: wk-scope-guard
date: 2026-07-27
type: gap
severity: medium
verified-against-source: yes
---

The scope-guard hook blocks `find` and recursive `grep -r`/`rg` even when the agent's task is explicitly and legitimately operating inside a different repo's worktree (e.g. a PR-review subagent dispatched against another project's checkout).

**What happened:** A subagent was explicitly instructed to review a PR in a second repo checked out under a worktree path outside the calling session's own repo root. Any `find ...` command, or a `grep` invocation combined with the `-r` flag, run from that worktree cwd was blocked with "BLOCKED search outside the project root," citing the *original* repo as "Repo root." The hook's own error message says `SCOPE_GUARD_OFF=1` "for the session" resolves it, but `export SCOPE_GUARD_OFF=1` set inside the same blocked Bash command had no effect — the hook evaluates before/independently of that command's own environment mutation.

**Root cause:** (unverified — inferred from symptom) The hook determines "repo root" from the session's original working directory/config rather than the Bash tool call's actual `cwd`, and reads `SCOPE_GUARD_OFF` from an environment snapshot taken before the blocked command runs, so an inline `export` in the same command line cannot satisfy it.

**Suggested fix:** Have the hook treat the Bash call's actual `cwd` (not the session's original root) as the scope boundary when the cwd is itself a valid, distinct git worktree/repo — a legitimate cross-repo subagent task should not need `find`/`grep -r` avoidance workarounds. Until fixed, callers should route around it with non-recursive `ls`/`grep` (no `-r`) and avoid `find` entirely rather than relying on the documented `SCOPE_GUARD_OFF=1` escape, which does not take effect via an inline `export`.
