---
class: principle
---

**Rule** — Resolving the Cloud tenant via `getAccessibleAtlassianResources` (no
params) is the mandatory FIRST Jira/Confluence API call. Use the returned UUID
`cloudId` for every subsequent call; cache cloudId/hostname for the session.
Never guess an `<org>.atlassian.net` slug or derive the cloudId/hostname from the
org name.

**Why** — Tenant subdomains do not reliably match the org name, so a guessed
slug returns 404 ("Failed to fetch tenant info for cloud ID"). The failure had a
prior distilled learning yet recurred, so the rule is escalated to a HARD RULE
gate on the flow's first step rather than advisory guidance.

**Where** — Pre-flight connector/tenant stage, immediately before any ticket
lookup or mutation.
