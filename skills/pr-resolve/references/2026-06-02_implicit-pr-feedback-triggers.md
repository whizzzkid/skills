---
class: principle
skill: wk-pr-resolve
date: 2026-06-02
---

- **Rule:** Auto-activate on indirect references to PR feedback ("fix the
  comment", "there's a description/comment issue", "address the feedback",
  "fix this on the PR") when an open PR exists on the current branch.
- **Why:** The skill only listed explicit phrases, so the agent asked a
  clarifying question instead of fetching and triaging the obvious open PR —
  losing a round-trip when the target was unambiguous.
- **Where:** Frontmatter `description` (activation triggers) + Quick Reference
  trigger table row.
