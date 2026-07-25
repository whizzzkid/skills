---
skill: wk-pr
class: principle
---

**Rule** — Before targeting any explicitly-named base branch — a `wk-pr` base argument,
or a reviewed branch chosen for a follow-up PR — verify it is not already merged:

```bash
gh pr view "$BASE_CANDIDATE" --json state --jq .state
```

`state == "MERGED"` → the branch is gone. Retarget to `$DEFAULT_BRANCH`, notify the
user, and never push to a merged branch.

**Why** — Auto-detection only scans `--state open` PRs, so a merged branch never enters
the candidate set and is filtered implicitly; the explicit-base path has no such guard.

**Where** — wk-pr Step 1, explicit-base path.
