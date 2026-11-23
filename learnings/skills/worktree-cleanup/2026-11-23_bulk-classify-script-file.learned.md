---
skill: wk-worktree-cleanup
date: 2026-11-23
type: gap
severity: low
verified-against-source: no
---

Bulk classification loop pasted inline into the shell failed; run it as a bash script file instead.

**What happened:** The one-pass classifier for ~60 worktrees was run as an inline compound command in the user's zsh.
Every command in the loop body failed with "command not found" (whole command lines treated as one word) and a glob
error on `?`, so the first pass produced garbage. Re-running the same logic from a `bash` script file worked.

**Root cause:** (unverified — inferred from symptom) zsh word-splitting/globbing differences (`IFS` handling with
`read`, unquoted `?` globbing) in the inline loop; bash script file avoids them.

**Suggested fix:** In Step 4's bulk-run guidance, say to write the classification pass to a scratch script and run it
with `bash`, collecting `branch|merged|dirty|author` rows, rather than composing an inline loop. Also note that
`git stash list` is repo-wide (shared by all worktrees), so a per-worktree stash count is meaningless; check it once.
