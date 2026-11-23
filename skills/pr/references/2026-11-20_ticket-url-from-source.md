---
class: principle
skill: wk-pr
date: 2026-11-20
---

# Re-violation: a ticket URL is an identifier that needs a source

- **Rule:** Resolve the issue-tracker host from a command (the tracker connector's accessible-resources call, or the
  body of a sibling PR) before writing a ticket URL into a PR body. Rule 4 now names tracker URLs explicitly and is
  escalated one rung (`Important`).
- **Why:** The first PR body linked the ticket under an invented tracker hostname; the body was edited once the real
  site was resolved. Rule 4 already listed URLs among sourced identifiers (installed before the incident), but its
  examples (run ids, SHAs, PR numbers) did not make a ticket link register as one.
- **Where:** `SKILL.md` → Rule 4. Source: pr learning and the 2026-11-21 session-1 retrospect.
