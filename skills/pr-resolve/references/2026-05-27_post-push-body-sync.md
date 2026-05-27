---
class: principle
date: 2026-05-27
source: learnings/skills/pr-resolve/2026-05-27_missed-post-push-body-sync.md
severity: high
---

- **Rule:** PR description sync after push is a numbered, mandatory step (Step 8.5), not a prose HARD RULE buried inside Step 8. The agent must explicitly satisfy it with a `gh pr edit {number} --body ...` call OR an explicit "no drift detected" log line that names each verified item (commit list, test-plan checkboxes, CI status section, remaining-work bullets). Silent skip is the failure mode. When the Step 7 confirmation gate is skipped (per the prior "explicit decisions" rule), Step 8.5 is the only remaining drift-catch — emit the edit unconditionally there.
- **Why:** Burying the body-sync as inline prose between push and reply-posting let the agent flow through the push → reply → resolve sequence and forget the body update, especially when no prior Step 7 prompt forced a pause and the prior session's body was authored by a different skill (no muscle memory).
- **Where:** New Step 8.5 "Sync PR description (mandatory, immediately after push)" between push and reply-posting; Step 7 skip-path bullet referencing Step 8.5 as the remaining drift-catch; reply work moved under Step 8.6.
