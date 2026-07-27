---
class: principle
---

# Commit-gate recovery mechanics (Step 8, item 3)

The gate's enumerated pass/fail checks stay inline in `SKILL.md`; this file carries the
recovery procedure for each specific way the commit can be blocked. Relocated because
these are per-hook catalog rows, not gate checks — a gate is never moved behind a pointer.

## Re-check the index after any hook-blocked commit

- A hook that rejects the commit leaves the index as-is, but a scrubbing hook
  (`scrub-staged.sh`) may have rewritten staged blobs. Re-read `git diff --cached
  --name-only` before retrying; never assume the staged set survived unchanged.

## Untracked skill dir from another session blocks `check-readme-index`

- The hook scans the whole `skills/` tree **on disk**, not the staged paths, so another
  session's half-built skill fails a commit that does not touch it.
- Don't `git add` or index it. Move it aside (`mv skills/<name> /tmp/agent/...`), land the
  path-scoped commit, push, then restore it untouched.

## Rename a processed learning with `mv`, not `git mv`

- A freshly materialized learning is untracked, so `git mv` aborts with
  `fatal: not under version control`.
- `mv` the file to `.learned.md`, then `git add` the new path.

## Stage only the paths this run touched

- Blanket `git add -A` bundles other sessions' *unprocessed* inbox files into the commit.
- If `-A` was unavoidable, `git reset` every `learnings/`/`retrospect/` path this run did
  not process, then re-verify the staged set before committing.
