---
class: principle
skill: wk-pr
date: 2026-11-26
severity: low
---

# Same-anchor sibling PRs: offer stacking

**Rule** — Sibling PRs from one session whose overlap is at the same insertion anchor (same list position in a shared
file) → offer stacking the later PR on the earlier one: branch from its head, set `baseRefName` to the parent branch,
merge the parent in once when it changes.

**Why** — The generic overlap rule (merge order + update after the first merge) treats the conflict as possible; at
the same anchor it is certain, so deferring resolution is strictly worse. Stacking kept each PR's diff scoped and the
final merge to the default branch one-sided.

**Where** — `SKILL.md` → sibling-PR overlap rule.
