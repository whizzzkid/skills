---
skill: wk-sharpen
date: 2026-07-15
type: correction
severity: medium
---

Appending `git stash` to a measurement command to "peek at HEAD" reverted all
staged and working edits into a stash mid-run, requiring recovery before the
commit could proceed.

**What happened:** While measuring the HEAD body size for a net-change
comparison, a `git stash` was tacked onto the command. `git stash` (without
`--keep-index`) stashes staged + unstaged changes and resets the working tree to
HEAD, silently reverting the in-progress SKILL.md/README.md edits. A file-view
system reminder then showed the OLD version string, which looked like the edits
had never applied. Recovery required `git stash pop` of the correct entry — with
an unrelated pre-existing stash from another session also present.

**Root cause:** Reached for `git stash` as a way to read HEAD's content, when it
mutates the tree. The read-only tool `git show HEAD:<path>` returns any committed
file's content with zero working-tree impact.

**Suggested fix:** To compare against a committed version, always use
`git show HEAD:<path>` (or `git show ":<path>"` for the staged blob) — never
`git stash`, `git checkout`, or any tree-mutating command mid-edit. Before any
stash/checkout/reset in a run with uncommitted work, stop and confirm it is
intended.
