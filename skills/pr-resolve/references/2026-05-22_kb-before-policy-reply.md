---
name: kb-before-policy-reply
description: Query the internal knowledge-base MCP before answering reviewer questions about org policy.
class: principle
---

- **Rule:** When a reviewer asks an org-specific policy question
  (retention, quotas, billing, infra config, compliance, SLAs,
  internal tooling), search the configured KB MCP via `ToolSearch`
  before drafting. Cite the authoritative doc verbatim when found.
  Fall back to vendor knowledge only when the KB returns nothing,
  and flag the fallback in the reply.
- **Why:** Generic vendor knowledge ("Datadog defaults to N days")
  is often wrong for org-customized configurations. Answering from
  defaults forces the reviewer to correct the agent with the
  internal-doc link they already knew about.
- **Where:** Step 4 "Query the internal knowledge base before
  answering org-specific questions" block before the
  documentation-bot verification.
