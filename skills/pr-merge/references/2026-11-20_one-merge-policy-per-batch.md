---
class: principle
skill: wk-pr-merge
date: 2026-11-20
---

# One merge policy per batch of PRs

- **Rule:** When a merge request covers two or more PRs, state one merge policy before the first merge (the agent
  merges each in a stated order, or the user merges them all), confirm it, and apply it the same way to every PR. A
  PR the user merges mid-flow resumes at Step 7 under that policy.
- **Why:** With no stated policy, the agent asked before one merge and acted alone on its sibling. The user read the
  difference as rules applied inconsistently, and could not predict what the agent would do next.
- **Where:** `SKILL.md` → When to Use. Pairs with `wk-pr`'s sibling-PR rule, which records the merge order and the
  expected conflict files.
