---
skill: wk-pr-break
date: 2026-04-29
type: pattern
severity: low
---

When one file is touched in multiple children (e.g. a top-level require file), add only the relevant diff for each child rather than checking out the whole file from the original branch.

**What happened:** PR #NNN touched `lib/{repo}.rb` in all three child PRs (one `require_relative` line per child). Checking out the full file from `$ORIG` on any intermediate branch would forward-require modules that don't exist yet, breaking isolation.

**Root cause:** The skill's execution template says `git checkout $ORIG -- <paths>` for whole files, which works cleanly unless the same file accumulates additions across multiple children.

**Suggested fix:** Add a note in Stage 7 per-child execution: for shared files touched incrementally (manifest files, require lists, index files), do not checkout the full file from $ORIG — instead apply only the delta relevant to that child (manually add the one line / one block). Document this explicitly in the plan's Execution Notes section.
