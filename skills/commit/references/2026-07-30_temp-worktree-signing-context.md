---
class: principle
---

# Probe signing from the shell that will commit

- **Rule:** Before a signed commit in a linked/temporary worktree, run
  `git -C <worktree> config --get user.signingkey` through the exact shell that
  will commit. If only the user's shell sees it, run `git -C` through that shell.
- **Why:** Environment-delivered Git configuration follows the process
  environment, not the caller's launch directory.
- **Verify:** Inspect the raw commit for a `gpgsig` header before pushing.
- **Where:** [`wk-commit`](../README.md) Commit Signing step 3.
- **Budget:** Body `24556 - 241 = 24315` bytes, leaving 261 bytes.
