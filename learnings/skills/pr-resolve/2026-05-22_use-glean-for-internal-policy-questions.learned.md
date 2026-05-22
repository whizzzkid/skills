---
skill: wk-pr-resolve
date: 2026-05-22
type: gap
severity: medium
---

Use Glean MCP to answer internal policy/infra questions before drafting reviewer replies.

**What happened:** A human reviewer asked about log retention. The agent answered from general knowledge ("Datadog defaults to 15 days") without checking internal documentation. The user had to provide a specific internal doc link that contained the authoritative answer.

**Root cause:** When a reviewer question touches org-specific policy (retention tiers, infra limits, billing configuration, SLAs), the agent defaulted to generic vendor knowledge instead of querying the internal knowledge base via `mcp__claude_ai_Glean__search` or `mcp__claude_ai_Glean__read_document`.

**Suggested fix:** In Step 4 (Generate Suggestions), when a reviewer comment is a question about org-specific policy (retention, quotas, billing, infra config, compliance), add a mandatory pre-draft step: search Glean for the relevant internal doc before writing the reply. If Glean surfaces an authoritative doc, cite it verbatim in the reply. Only fall back to general vendor knowledge if Glean returns nothing relevant.
