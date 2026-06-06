---
skill: wk-goodmorning
date: 2026-04-22
type: gap
severity: low
---

Skill's "block everything until all services succeed" rule is too strict when only one service needs interactive OAuth.

**What happened:** Jira/Confluence agent returned an OAuth authorization URL (user action required). The skill says to stop and present all blocked services before producing output. But the user was in auto mode and every OAuth step requires clicking through a browser flow that cannot be automated by the agent. Blocking the whole brief on a single OAuth click would defeat the purpose of the morning brief (user still needs actionable output to start the day).

**Root cause:** The skill treats all BLOCKED errors identically. It doesn't distinguish "MCP not installed" (hard blocker — can't proceed) from "OAuth needed" (soft blocker — can embed the authorization URL in the output and continue with the data we have).

**Suggested fix:** Introduce two severity levels for BLOCKED errors:
- **Hard block**: MCP tools not configured, network failure, missing secret. Stop output, list all hard blocks.
- **Soft block**: OAuth URL returned. Embed the URL in the affected section of the dashboard with a "⚠ Authorize here" CTA, then continue with carry-over data from yesterday for that service. Note the soft block in the summary so the user knows the section is degraded.

Also: when yesterday's morning.md or evening.md contains data for a soft-blocked service, surface that as "Known items (from yesterday)" rather than leaving the section empty.
