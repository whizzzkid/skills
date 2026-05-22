---
class: principle
date: 2026-05-22
source: learnings/skills/pr/2026-05-22_early-return-recurrence.md
---

- **Rule:** Ancillary post-`gh pr create` actions (cross-repo discussion comment, reply to referenced PR, Slack/Jira link, upstream issue update) do not constitute task completion; the post-creation lifecycle still runs.
- **Why:** Agent conflated "posted the side comment" with "task done," skipping CI poll, self-review, adversarial gate, and `gh pr ready` until the user re-prompted. Recurrence — prior `.learned.md` did not harden the rule.
- **Where:** Step 3 HARD RULE — appended "Side actions never terminate the workflow" clause and a continue-signal table.
