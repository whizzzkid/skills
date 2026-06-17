---
class: principle
---

# Gate `gh pr create` on the merge-base algorithm, not intuition

**Rule**

- Do not call `gh pr create` until Step 1's merge-base distance loop has actually
  run this session and set `$BEST_BASE`/`$BEST_DIST`.
- `--base` takes `$BEST_BASE`'s computed value only — never a hand-typed branch
  name. If `$BEST_BASE != $DEFAULT_BRANCH`, surface the A/B/C stacked-PR prompt
  first.

**Why**

- The algorithm was already documented but skipped in practice: `--base main` was
  passed on a branch forked from another in-flight branch, mis-basing a stacked PR
  that the user had to fix on GitHub.
- A branch that "obviously" targets the default is exactly where the loop gets
  skipped — so the gate must bind to the loop running, not to the agent's judgment
  that it is unnecessary. This is a re-violation of an existing rule, escalated.

**Where**

- `skills/pr/SKILL.md` Hard Rule 3 (Very important gate) + Step 1.
