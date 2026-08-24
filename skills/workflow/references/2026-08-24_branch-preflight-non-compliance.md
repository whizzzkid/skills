---
class: principle
---

# Branch pre-flight non-compliance

**Rule:** Phase 2 branch pre-flight must be a HARD RULE — verify `git rev-parse --abbrev-ref HEAD` matches the intended base before any edit. Rebase/cherry-pick conflicts are a diagnostic signal of wrong-base targeting; diagnose before working around.

**Why:** An agent skipped the advisory pre-flight, assumed the default branch as base in a worktree branched from a different release branch, hit rebase conflicts, and instead of diagnosing the wrong base, created a new branch off default and rewrote everything against the wrong code structure. Multiple secondary signals (different exports, missing test framework, missing build config) were also ignored.

**Where:** `skills/workflow/SKILL.md` → Phase 2 → HARD RULE — branch pre-flight before first edit.
