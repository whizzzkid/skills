---
class: principle
source: learnings/skills/pr-review/2026-11-24_skip-lintable-nits.learned.md
date: 2026-11-24
severity: medium
---

## Never post lintable nits as review findings

- **Rule:** Drop any finding a linter or formatter could catch (line width, wrapping, trailing whitespace, import order,
  quote style), whether or not the repo runs one. If the project lacks the lint rule and the gap matters, raise it at
  most once as a change-wide body suggestion to add the check. Never apply the agent's own authoring rules as review
  criteria for someone else's repo.
- **Why:** A review posted a line-width suggestion on a README in a repo with no line-length rule, where the same file
  already broke that width in several places. The "rule" was the agent's own markdown preference. The user judged the
  comment too shallow: catching it is a linter's job, not a reviewer's.
- **Where:** `SKILL.md` Phase 4, after the severity bullet.
