---
skill: wk-gh
date: 2026-07-01
type: correction
severity: medium
---

The canonical outbound footer must be appended to EVERY agent-authored outbound body, not just GitHub bodies.

**What happened:** Jira comment bodies (posted via the Jira MCP `addCommentToJiraIssue` — a PR-opened notice and a shipped notice) went out without the canonical `🦾 Generated with [wk-skills]…` footer. The GitHub self-review inline comments in the same session did carry it, which masked the gap.

**Root cause:** The wk-gh Step 4 footer rule was mentally scoped to GitHub PR/review/comment bodies only. External-system writes routed through non-GitHub connectors (Jira, Slack, docs) were not recognized as "outbound bodies" subject to the same rule.

**Suggested fix:** State explicitly in wk-gh Step 4 that the footer applies to every agent-authored outbound body across ALL external systems — Jira issue/comment bodies, Slack messages, doc bodies, etc. — not only GitHub. Add Jira MCP `addCommentToJiraIssue`/`editJiraIssue` and Slack send tools to the list of footer-bearing write paths so the rule fires when composing those payloads.
