---
skill: wk-pr
date: 2026-06-01
type: correction
severity: medium
---

Stacking a PR on an unmerged draft base misleads about merge intent.

**What happened:** Created a PR with `--base <draft-branch>` because the user said "create a stacked PR". The user immediately redirected: "change the base to `main` instead." The stacked-on-draft framing was a false split — the parent PR was a draft that hadn't yet merged, so both sets of changes should land together.

**Root cause:** The base-detection heuristic correctly identified the parent branch as the closest merge-base, but didn't reason about whether the parent was a mergeable state. When the parent is also a draft PR not yet approved, stacking produces two PRs the reviewer must sequence — often not what the user wants.

**Suggested fix:** After computing `$BEST_BASE`, check whether it corresponds to an open PR and whether that PR is in draft state. If draft, surface: "The detected base (`{branch}`) is still a draft PR. Options: (A) stack here anyway, (B) retarget to the default branch and include both changesets, (C) cancel." Auto mode should default to B when the parent is draft.
