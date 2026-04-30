---
skill: wk:workflow
date: 2026-04-30
type: gap
severity: medium
---

Prefactor before extending: when adding a second caller of a pattern, lift the shared logic first, then implement the new caller against the lifted helper.

**What happened:** While building `StatusCommenter` (a new "post a Fresh Eyes PR comment" surface) on PR #NNN, the validation prologue (`token?` → `pr_number.to_s` → `REPO_PATTERN` → `PR_NUMBER_PATTERN`) was copied verbatim from `ReviewPoster#post_summary_comment`. The duplication landed across 4 commits and survived two `wk:pr-resolve` passes before a reviewer pointed at the pattern. After the duplicate `gh pr comment --edit-last` upsert was finally consolidated, ~15 LOC of validation still mirrored across both classes.

**Root cause:** `wk:workflow`'s implementation phase treats "make the new feature work" and "consolidate with the existing feature it resembles" as separate concerns, with the second concern usually deferred to "later." When the first commit lands working code, the duplication becomes invisible — it's no longer a delta in the diff, it's just "how the file looks." Tests then accumulate against both copies, raising the cost of consolidation. The pattern hides especially well when the two callers live in different files and were touched in different PRs.

**Suggested fix:** Add a "prefactor probe" to `wk:workflow` Phase 1 (planning):

> Before writing the new caller, grep the codebase for the operation it performs (e.g. "post a PR comment", "validate repo format", "open a build", "fetch labels"). If another caller exists:
> 1. Read both call sites end-to-end.
> 2. Identify the duplicated prologue/epilogue (validation, error handling, logging, retries).
> 3. Lift the duplicated portion into a helper module/function in the same `lib/` location, with one consolidated test file.
> 4. Migrate the existing caller onto the helper as a separate commit, with all existing tests still passing.
> 5. *Then* implement the new caller as a thin wrapper that delegates to the helper plus any new behavior.

The order matters: lift-then-migrate-then-extend keeps the existing-caller migration reviewable in isolation and makes the new caller's diff trivially small (it's mostly the new behavior, not a duplicated prologue).

This is "prefactor" — refactoring before adding new code, not after. The cost is one extra commit on the existing caller; the benefit is permanent (no future "found another duplicate of this" review comment). Add this as a default action when Phase 1 detects an existing similar caller, not as an optional step the user has to remember.

Trigger phrases that should fire the probe: "another", "similar", "like the X version", "post/fetch/validate/build" + an object that already has a caller.
