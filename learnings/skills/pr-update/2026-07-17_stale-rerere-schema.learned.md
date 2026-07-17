---
skill: wk-pr-update
date: 2026-07-17
type: correction
severity: high
---

A stale `rerere` cache silently re-applied a wrong resolution to an auto-generated schema dump, dropping the branch's own migration columns.

**What happened:** During a `git merge` of the base branch, git reported `Staged '<schema-file>' using previous resolution`. The rerere-cached resolution had earlier discarded this branch's own new columns (kept only the base side). `git diff --check` found no markers because the file was already staged, so the drop was invisible until manual inspection of the staged diff.

**Root cause:** `rerere.enabled=true` reuses a prior conflict resolution by content hash. For an auto-generated file (schema dump, lockfile) whose conflict recurs across sibling PRs, the cached resolution can be the wrong-direction one, and it is applied and staged automatically with no conflict markers left to review.

**Suggested fix:** In the conflict-resolution loop, when a merge/rebase prints `Staged '<file>' using previous resolution`, do not trust it — run `git rerere forget <file>` then `git checkout --merge <file>` to recreate real markers, and hand-verify both sides are represented. Especially for auto-generated files (schema.rb, *.lock), regenerate/verify the merged result rather than accepting the rerere output.
