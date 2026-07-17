---
class: principle
skill: wk-pr-update
date: 2026-07-17
severity: high
---

# Stale rerere cache silently re-applies a wrong resolution

**Rule** — When merge/rebase/patch prints `Staged '<file>' using previous resolution`,
do not trust the staged result: run `git rerere forget <file>` then
`git checkout --merge <file>` to recreate the real conflict markers, re-resolve by hand,
and verify both sides are represented. For auto-generated files (schema dumps, `*.lock`),
regenerate from source and verify the merged output.

**Why** — `rerere.enabled` reuses a prior resolution by content hash. For files whose
conflict recurs across sibling PRs (schema dumps, lockfiles), the cached resolution can
be the wrong-direction one that dropped the branch's own additions. It is applied and
staged automatically with no conflict markers left, so `git diff --check` finds nothing
and the loss is invisible until manual inspection of the staged diff.

**Where** — Stage 4 (conflict resolution loop), as the HARD RULE at the top of the stage.
