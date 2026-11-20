---
class: principle
source: learnings/skills/pr/2026-11-20_parallel-pr-merge-order.learned.md
date: 2026-11-20
skill: wk-pr
---

**Rule** — When one session opens two or more PRs, intersect their changed-file sets
(`git diff --name-only "origin/<base>...<head>"`) before calling them independent. Overlap → state the recommended
merge order and the expected conflict files in each PR body and the hand-off, and offer to update the later PR right
after the earlier one merges.

**Why** — Two parallel PRs off the default branch both edited shared registries (an import map, a lint config list,
one view) and were reported as independent. The second conflicted after the first merged; the user found the conflict
and had to ask why the merge order was never raised. "Independent" had been judged on behavior, not file overlap.

**Classification** — `principle`, new Step 2 rule (stack merge order was covered via `baseRefName`; trunk-based
sibling PRs had no overlap check).

**Where** — `SKILL.md` → Step 2 (Create Draft PR), after Stacking; README Noteworthy.
