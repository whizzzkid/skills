---
class: principle
---

**Rule** — Resolve the Atlassian Cloud tenant via `getAccessibleAtlassianResources` (no params) first and use the returned UUID `cloudId` for every subsequent call; cache the resolved cloudId/hostname for the session. Never guess or derive an `<org>.atlassian.net` slug from the org/employer name.

**Why** — A Jira MCP call used a cloudId guessed from the org name (`<org>.atlassian.net`) and returned 404 ("Failed to fetch tenant info for cloud ID"). Tenant subdomains do not reliably match the org name, so any inferred slug is a coin flip; only the accessible-resources endpoint returned the correct UUID and hostname.

**Where** — `wk-jira` Stage 0 (MCP availability check).
