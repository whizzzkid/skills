---
skill: wk-self-review
date: 2026-06-06
type: gap
severity: medium
---

Pending review POST blocked by auto-mode permission classifier with no pre-flight warning.

**What happened:** The skill attempted `gh api .../pulls/{n}/reviews` (POST) to create a pending review, which was blocked by the auto-mode classifier because posting to GitHub under the user's identity requires explicit permission.

**Root cause:** The skill has no pre-flight step that checks whether the required `gh api .../reviews` POST permission is present in settings, and no fallback path that informs the user to add it before the attempt fails.

**Suggested fix:** Add a Step 0.5 that checks for `gh api repos/*/pulls/*/reviews` in allowed Bash commands (or equivalent) and surface a one-line prompt to add it if missing, before building the review payload.
