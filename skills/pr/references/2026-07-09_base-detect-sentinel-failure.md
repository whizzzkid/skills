---
skill: wk-pr
class: principle
---

**Rule** — After the base-detection merge-base loop, treat an unchanged
sentinel distance (`$BEST_DIST == 999999`) as a detection FAILURE, not a valid
"base = default" result. Require independent confirmation of the base (explicit
`--base`, or the plan's stated stacking target) before `gh pr create`.

**Why** — When no candidate yields a merge-base (every non-default candidate
drops out, or even the default fails to resolve), the loop returns the default
branch with the sentinel untouched — indistinguishable from a branch genuinely
forked off default. Silently proceeding mis-bases a stacked PR. Complements the
candidate-resolution fix in `base-detect-local-only-candidates` (which keeps
local-only candidates in the loop); this rule catches the case where the loop
still yields nothing.

**Where** — wk-pr Step 1, immediately after the merge-base distance loop.
