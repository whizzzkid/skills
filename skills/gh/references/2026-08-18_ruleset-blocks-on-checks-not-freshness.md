---
class: principle
---

**Rule** — Never infer "branch must be updated" from `mergeStateStatus: BLOCKED`
alone. Branch-freshness is enforced only when the ruleset's
`strict_required_status_checks_policy` is `true`; absent that flag, passing
required checks + resolved conversations = mergeable regardless of distance from
base.

**Why** — Agent attributed a BLOCKED merge state to branch staleness when the
active ruleset only required status checks to pass, not branches to be
up-to-date. The user corrected: the strict flag was absent, so the PR was
mergeable.

**Where** — `SKILL.md` → "A green-checks `BLOCKED` merge — what to check",
new bullet on branch-freshness.
