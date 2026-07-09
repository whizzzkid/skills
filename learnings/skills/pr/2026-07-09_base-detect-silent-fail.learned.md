---
skill: wk-pr
date: 2026-07-09
type: gap
severity: medium
---

Base-detection loop can silently fail and return the sentinel default (`BEST_DIST=999999`, `BEST_BASE=$DEFAULT_BRANCH`) when the branch's real base is a local-only stacked branch.

**What happened:** For a branch stacked on an open PR's head, the merge-base distance loop exited with `BEST_DIST` still at its `999999` init value and `BEST_BASE` still the default branch — despite the true base being another open PR's head. The correct base was known independently (verified merge-base + the plan's stated stacking target), so the wrong result was not used.

**Root cause:** A candidate whose ref resolves only locally (worktree branch not yet on origin, or fetch fails) can drop out of the loop; when every non-default candidate drops, the loop leaves the sentinel untouched and returns the default, indistinguishable from "genuinely forked off default."

**Suggested fix:** After the loop, treat `BEST_DIST == 999999` (unchanged sentinel) as a detection FAILURE, not a valid "base = default" result — warn and require independent confirmation of the base (known stacking target / explicit `--base`) before `gh pr create`, rather than silently proceeding against the default branch.
