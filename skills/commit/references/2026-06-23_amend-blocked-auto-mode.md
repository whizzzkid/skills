---
class: principle
skill: wk-commit
date: 2026-06-23
---

**Rule**

When a CI fix produces a single trivial follow-up that corrects the immediately
prior commit, surface an explicit `git commit --amend` suggestion for the user to
approve in the same response — do not silently create a separate commit and defer
the squash to retro.

**Why**

Auto mode blocks `--amend` as history-rewriting, so the agent cannot amend
unprompted. Accumulating uncorrected follow-ups forces the user into a manual
`git rebase -i HEAD~N` later. Asking once at the fix site is cheaper.

**Where**

Post-CI-Fix Squash Offer → "Single trivial follow-up → offer `--amend` at the fix
site" subsection (complements the existing ≥3-commit squash offer).
