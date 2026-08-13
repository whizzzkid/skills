---
skill: wk-pr
date: 2026-08-12
type: correction
severity: medium
verified-against-source: n/a
---

Follow-up PRs in the same session must be based on latest remote main, not stale local branch state.

**What happened:** Agent created follow-up fix PRs building on a local branch that was behind remote main after earlier PRs had been merged. The stale base caused unnecessary diff noise and complicated the review.

**Root cause:** Agent did not `git fetch origin main && git reset --hard origin/main` before starting a new follow-up branch after the prior fix PR was merged. (unverified — inferred from user correction)

**Suggested fix:** Before creating any follow-up PR in the same session, always sync to latest remote main: `git fetch origin main && git reset --hard origin/main`, then create the new branch and changes from that point. This ensures each follow-up PR has a clean, current base.
