---
skill: wk-pr-resolve
date: 2026-06-17
type: gap
severity: high
---

Rebase conflict resolution silently drops safety guards that exist on the base branch but not in the incoming feature commit.

**What happened:** A `git rebase --onto origin/main` conflict at a function call site had two sides: the base side (HEAD = current rebase position, carrying a `signal.Stop(sigCh)` call added on the base branch by a prior merged PR) and the incoming commit's side (the feature branch, which had not yet added that guard). Resolving by taking the incoming commit's version dropped the guard. The code compiled, all tests passed, and the regression was only caught by adversarial review.

**Root cause:** Step 2 of wk-pr-resolve covers `git rebase --onto` for base-advance conflicts but has no audit step for cleanup/signal/context primitives that exist on the base side of a conflict but are absent from the incoming side. The base side represents canonical `origin/main` state; any guard present there was added intentionally and should survive the merge unless the incoming commit explicitly removes it with a matching commit message rationale.

**Suggested fix:** Add a post-conflict-resolution audit step in Step 2: after resolving each conflict, diff the two sides for calls to signal/context/cleanup primitives (`signal.Stop`, `context.Cancel*`, `sync.*`, `defer`, `close(`, `os.RemoveAll`, and analogous resource-release patterns). Any primitive present on the HEAD (base) side but absent in the resolved result is a safety-guard candidate — verify the omission is intentional (incoming commit explicitly removed it with rationale) versus accidental (lost to conflict resolution). Block continuation until each absence is confirmed.
