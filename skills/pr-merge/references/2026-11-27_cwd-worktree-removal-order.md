---
class: principle
skill: wk-pr-merge
date: 2026-11-27
severity: low
---

# Removing the CWD worktree: one sequenced call, never parallel

**Rule** — When the merged worktree is the session's working directory, run its removal and the local-branch delete
as one sequenced `cd "$main" && …` chain; start every later call with `cd "$main"`.

**Why** — Every Bash call starts in the session CWD. Removal and branch delete were sent as parallel calls; removal
succeeded and the harness refused the delete because its start directory no longer existed. The reference already
prescribed a single chain (installed 2026-10-29), so this is a re-violation → escalated one notch from
reference-only to a `SKILL.md` Step 10 rule.

**Rejected** — "delete the branch first": Git refuses to delete a branch checked out in a live worktree.

**Where** — `SKILL.md` Step 10; `references/worktree-cleanup.md`.
