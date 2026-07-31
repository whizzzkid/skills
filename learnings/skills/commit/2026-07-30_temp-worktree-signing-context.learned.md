---
skill: wk-commit
date: 2026-07-30
type: correction
severity: medium
verified-against-source: yes
---

Probe signing configuration from the exact shell environment before committing in a temporary
worktree.

**What happened:** A signed commit launched against a detached temporary worktree failed because no
signing key was visible. Retrying `git -C /tmp/agent/worktree commit -S` through the
configuration-bearing user shell succeeded.

**Root cause:** The original launch-cwd explanation was incorrect: `git -C` selects the target
repository regardless of the caller's cwd. Signing config was visible only in the shell environment
that supplied the user's Git configuration.

**Suggested fix:** Before a signed commit or merge in a temporary worktree, run
`git -C /tmp/agent/worktree config --get user.signingkey` from the exact shell that will execute it.
If the key is absent there but present in the user's shell, execute `git -C` through that shell, then
verify the resulting commit object's raw `gpgsig` header before pushing.
