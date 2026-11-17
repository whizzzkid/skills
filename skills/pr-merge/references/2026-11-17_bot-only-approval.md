---
class: principle
---

- **Rule** — When the review decision is `APPROVED`, list the approving reviewers. If every approver is a bot, tell the
  user before attempting the merge and offer: merge it themselves, get a human approval, or add a permission rule.
- **Why** — reviewDecision was APPROVED from an automated reviewer, checks were green, merge state was clean, yet the
  merge call was denied by the agent's permission classifier because no human had reviewed. The step treated any
  APPROVED decision as sufficient and never checked who approved.
- **Where** — `SKILL.md` Steps 2–3, Step 3 review gate.
