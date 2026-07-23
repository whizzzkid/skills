---
skill: wk-jira
date: 2026-07-23
type: gap
severity: medium
---

Jira MCP tools require the UUID cloudId, not the site hostname.

**What happened:** `getJiraIssue`/`editJiraIssue`/`transitionJiraIssue` were
called with `cloudId="<site>.atlassian.net"` and returned `404 Failed to fetch
tenant info for cloud ID: <site>.atlassian.net`.

**Root cause:** The `cloudId` parameter is the tenant UUID, not the human-facing
site hostname. The hostname is never a valid cloudId. A guessed hostname (e.g.
dropping/adding a suffix like the org's `hq`) compounds the failure.

**Suggested fix:** Always call `getAccessibleAtlassianResources` (no args) first
to resolve the site → its UUID cloudId, then pass that UUID to every subsequent
Jira MCP call. Never derive the cloudId from a URL/hostname.
