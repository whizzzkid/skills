---
skill: wk-jira
date: 2026-06-23
type: correction
severity: medium
---

Auto mode blocks Jira transitions fired as dev-work side-effects; surface this upfront.

**What happened:** The In Progress transition (Stage 2) was blocked by the auto mode classifier with reason "transitioning Jira issue was not requested — user only referenced the ticket as context." The transition only succeeded after the user was informed and it was retried in a separate turn.

**Root cause:** Auto mode treats Jira writes as external-system writes requiring explicit user intent. A ticket URL in the opening prompt is treated as context, not as authorization to modify the ticket. wk-jira's Stage 2 "development intent = auto" assumption conflicts with auto mode's write classifier.

**Suggested fix:** At Stage 0, when auto mode is active, note that Jira transitions may be blocked and prompt the user to either: (a) confirm intent once ("yes, transition this ticket as we work"), or (b) add a Bash permission rule for Jira MCP writes. Do not silently retry — surface the block and ask once rather than spinning on denials.
