---
class: principle
---

**Rule:** To inspect a committed or staged version of a file mid-run, use
read-only `git show HEAD:<path>` (committed) or `git show ":<path>"` (staged
blob). Never use `git stash`, `git checkout`, or `git reset` to "peek" — they
mutate the working tree.

**Why:** `git stash` without `--keep-index` stashes staged + unstaged changes and
resets the tree to HEAD, silently reverting in-progress edits. The reverted file
then reads as if the edits never applied, and recovery requires popping the
correct stash — error-prone when other sessions left unrelated stashes.

**Where:** wk-commit git-hygiene section. Applies to any skill that reads a
committed version during a run (size measurement, net-change diffs, base-branch
comparison).
