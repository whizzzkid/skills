---
name: mcp-before-client
description: Survey available MCP tools for the target service before writing an HTTP client.
class: principle
---

- **Rule:** Before writing any HTTP client / SDK wrapper / API
  integration for a third-party service, survey available MCP
  tools for that service. If a matching MCP exists and the use
  case is interactive (not pipeline / CI / cron code outside a
  Claude session), use the MCP. Build a client only when the call
  must run in a non-Claude environment and document why.
- **Why:** Defaulting to "write code" when an MCP tool already
  covers the integration burns time on plumbing the agent does not
  need. The MCP often has higher-fidelity primitives than the raw
  REST API and is already authenticated.
- **Where:** Phase 1 "Investigate user-provided artifacts first",
  new sub-bullet after the GitHub-URL routing rule.
