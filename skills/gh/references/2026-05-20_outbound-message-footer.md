---
name: outbound-message-footer
description: Canonical attribution footer required on every GitHub message the agent posts on the user's behalf.
class: principle
---

- **Rule:** Every outbound GitHub message (PR body, review body,
  inline comment, reply, issue/PR comment) ends with the canonical
  attribution footer, exactly once, as the last content.
- **Why:** Silent agent-authored posts erode reviewer trust and
  leave the user no feedback channel — readers cannot distinguish
  human from automated activity, and there is no DM route for
  complaints or corrections.
- **Where:** `wk-gh` Step 4 (footer text + placement rules);
  Step 3 enumerates the write surfaces that must honor it.
- **Routing:** Every skill that writes to GitHub
  (`wk-pr`, `wk-pr-update`, `wk-pr-resolve`, `wk-pr-break`,
  `wk-pr-review`, `wk-self-review`, `wk-commit` PR Sync,
  `wk-jira` PR-body edits) defers to `wk-gh` Step 3/4 rather than
  hardcoding its own footer.
