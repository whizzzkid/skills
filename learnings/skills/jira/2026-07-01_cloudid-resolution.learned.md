---
skill: wk-jira
date: 2026-07-01
type: correction
severity: medium
---

Resolve the Atlassian Cloud tenant via the accessible-resources endpoint; never guess an `<org>.atlassian.net` slug.

**What happened:** A Jira MCP call was made with the cloudId set to a guessed `<org-name>.atlassian.net` subdomain inferred from the org name. It returned a 404 ("Failed to fetch tenant info for cloud ID"). The real tenant subdomain differed from the org name, and only `getAccessibleAtlassianResources` (no params) returned the correct cloudId UUID and hostname.

**Root cause:** The workflow inferred the tenant subdomain from the org/employer name. Atlassian tenant subdomains do not reliably match the org name, so any guessed slug is a coin flip.

**Suggested fix:** Make Stage 0 (MCP check) of the Jira lifecycle call `getAccessibleAtlassianResources` first and use the returned UUID `cloudId` for every subsequent call; cache the resolved cloudId/hostname for the session. Explicitly forbid deriving the cloudId or hostname from the org name.
