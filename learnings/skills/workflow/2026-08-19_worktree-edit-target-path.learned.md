---
skill: wk-workflow
date: 2026-08-19
type: correction
severity: medium
verified-against-source: yes
---

In a linked worktree, an absolute edit path can resolve into a sibling worktree/main checkout instead of the active branch.

**What happened:** Working in a linked worktree, a config file was located via a repo-root absolute path that pointed at the main checkout, not the worktree copy. The edit landed in the wrong tree and was only caught when `git add` rejected the path as "outside repository". The main checkout then had to be reverted and the edit re-applied to the worktree copy.

**Root cause:** The file was opened by an absolute path anchored at the primary checkout rather than the current worktree root; nothing verified the target lived under the worktree before editing.

**Suggested fix:** Phase 2 pre-edit — resolve every edit target relative to `git rev-parse --show-toplevel` of the active worktree, and before staging confirm each intended path is under that root; treat a repo-root absolute path in a linked-worktree session as a red flag to re-anchor.
