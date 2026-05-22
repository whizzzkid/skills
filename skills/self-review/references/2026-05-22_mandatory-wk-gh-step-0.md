---
name: mandatory-wk-gh-step-0
description: Convert the GitHub-routing prose HARD RULE into a numbered Step 0 gate.
class: principle
---

- **Rule:** Invoke `wk-gh` as Step 0 before any `gh` command or
  GitHub API call this skill issues. Step 1 cannot start until
  Step 0 completes.
- **Why:** A HARD RULE buried in prose at the top of a skill is
  read but not always acted on — agents proceed to subsequent
  numbered steps and bypass the routing. Posts ship without org
  scoping and without the canonical outbound footer.
- **Where:** New Step 0 "Route GitHub I/O through `wk-gh`
  (MANDATORY)" inserted immediately before Step 1.
