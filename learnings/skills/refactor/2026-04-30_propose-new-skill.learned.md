---
skill: wk-refactor-validate (PROPOSED — does not exist yet)
date: 2026-04-30
type: gap
severity: high
---

Need a new `wk-refactor-validate` skill that runs after any rebase / merge / patch-replay / "extract helper" refactor to verify functional behavior is preserved against the source-of-truth branch.

**What happened:** During wk-pr-update patch-replay on PR #NNN, I resolved an `AA` conflict on `bin/status_comment` by picking "theirs" (the Bootstrap-extracted version), which silently dropped main's `BUILDKITE_PULL_REQUEST` fallback for native {repo} builds. Tests passed (the patch's spec didn't cover that branch — the spec was also picked from "theirs"). Rubocop passed. The PR review missed it. The user caught the regression manually after merge-readiness was claimed. Functional regression slipped through every existing gate.

**Root cause:**

1. **Conflict resolution bias.** When two valid functional paths exist (Bootstrap helper vs main's hand-rolled fallback), `git checkout --theirs` for one file and `--ours` for its spec produces *internally consistent* but *externally regressed* code. Tests pass because both files moved together.
2. **No semantic diff gate.** `git diff origin/main..HEAD` shows what changed but not whether intent was preserved. Refactors should produce a *narrower* net diff than feature work, and unexpectedly-large diffs deserve scrutiny line-by-line.
3. **Test suite is a lagging indicator.** Tests covered the new code paths; they didn't cover paths that *should still exist*. A pure refactor shouldn't change which tests exist — only which file they live in.
4. wk-pr-update and wk-pr-resolve both run "tests + rubocop" as their validation gate. Neither asks "does this still do what main does?"

**Suggested fix:** Author `wk-refactor-validate` as a post-refactor verification skill. Trigger conditions:

- After wk-pr-update finishes a patch-replay or rebase
- After wk-pr-resolve resolves any conflict
- Manually invoked when the user suspects a refactor dropped behavior

The skill should:

1. **Diff against the merge-base and against the post-refactor target** — produce both `git diff <merge-base>..HEAD` and `git diff origin/<base>..HEAD`. The merge-base diff shows what the branch *was* doing; the base diff shows what it does *now*.
2. **Classify the refactor type** — extract-helper / move-file / rename / pure-rebase / split-file. Each has expected diff shapes; deviations are flags. e.g., extract-helper should have a roughly net-zero LOC diff for the caller (replace inline code with a call); large negative deltas mean behavior was dropped, not extracted.
3. **For each modified file, ask: did any *removed* line encode behavior not present elsewhere?** Use a structured checklist:
   - Was an `ENV.fetch` removed? Is the env var still read somewhere?
   - Was a fallback chain (`if x.nil? then y end`) removed? Is the fallback still invoked?
   - Was a `rescue` clause dropped? Is the exception still handled?
   - Was a guard (`unless`, `return early`) removed? Is the guarded condition still impossible?
   - Was a comment removed that documented WHY a branch existed? Was the branch removed too?
4. **Cross-check tests against removed behavior** — for each test that the patch *removed* (or that exists in the main-side spec but not in this branch's spec), verify the underlying behavior was either (a) intentionally removed (PR description should say so) or (b) still present and tested under a different name.
5. **Compare against the source-of-truth branch's behavior** — `git show origin/<base>:<file>` for each touched file, side-by-side with the post-refactor file. Spot semantic divergence even when names changed.
6. **Surface findings interactively** — present each suspicious removal with: line, original behavior, what (if anything) replaces it, and ask the user to confirm intentional vs regression.

The skill should be invoked **before** "this is ready for review" claims, not after the user catches a regression.

**Why this is a `wk-refactor-validate` skill and not a wk-pr-update sub-step:** wk-pr-update's job is integration; it should not also be the safety net for *semantic* preservation, because that's a different mode of reasoning (intent-vs-behavior, not branch-vs-branch). Same reason wk-self-review is its own skill — composing each concern separately makes both better.

**Related existing memory:**
- `feedback_stacked_pr_base_detection.md` (just written) — this learning is the second half of that story: detecting the right base, then validating the refactor preserved behavior.
- `feedback_complete_plan_before_done.md` — same family: don't claim done until verified.
