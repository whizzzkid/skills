---
class: principle
skill: wk-pr-merge
date: 2026-11-20
---

# Step 9's retro runs after the merge; existence is not coverage

- **Rule:** Invoke `wk-retro` after the merge on every run. A retro file written before the merge never satisfies
  Step 9. Before reporting any step done, name the artifact and the events it covers.
- **Why:** A pre-merge retro misses every correction made after it was written, so pointing at it reports a step as
  done that captured nothing from the merge window. Judging completion by artifact existence, not coverage, is the
  failure mode.
- **Where:** `SKILL.md` → Steps 9–10, inside the Steps 7–10 atomic-unit HARD RULE.
- **Escalation:** re-violation of the prose clause "Invoke `Skill(wk-retro)` immediately after merge" (installed
  2026-10-08, before the report). Escalated one rung: baseline prose → `**Important:**`, plus the missing
  pre-merge-retro and coverage clauses.
- **Not changed:** `wk-worktree-cleanup`'s "retro already run" check stays as-is; under `wk-pr-merge` Step 9's
  post-merge retro is what satisfies it.
