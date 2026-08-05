---
class: principle
---

# Preflight SSH signing in the execution shell

**Rule** — Before a signed merge or rewrite, verify `user.signingkey` and `ssh-add -L` in the exact execution shell.
If only the login shell exposes both, run the operation there with the verified key via one-shot `git -c`.

**Why** — Starting first can leave a merge at commit creation without access to its configured signing agent.

**Where** — Commit-signing preflight.
