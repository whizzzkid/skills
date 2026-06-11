---
skill: wk-adversarial-review
date: 2026-06-10
type: surprise
severity: medium
---

GIT_SEQUENCE_EDITOR=: with --autosquash replays from the base, re-triggering already-resolved conflicts.

**What happened:** After a rebase that resolved conflicts and produced a wasm staleness issue, a fixup commit was created (`git commit --fixup=<sha>`). To fold it non-interactively, `GIT_SEQUENCE_EDITOR=: git rebase -i --autosquash origin/<base>` was run. This re-ran the entire rebase from the remote base, re-encountering all previously-resolved conflicts, not just squashing within the existing chain.

**Root cause:** `git rebase -i --autosquash <base>` with `GIT_SEQUENCE_EDITOR=:` starts a fresh rebase from `<base>`, applying all commits from scratch. It does not simply re-order the existing chain in place — previously committed conflict resolutions are re-exposed.

**Suggested fix:** When a wasm rebuild (or any artifact rebuild) produces a stale artifact after rebase, prefer amending the fixup commit's message directly (`git commit --amend`) to give it a conventional commit message and keep it as a standalone commit, rather than trying to fold it into a mid-chain commit. Non-interactive autosquash into a mid-chain commit is not reliably conflict-free after a rebase.
