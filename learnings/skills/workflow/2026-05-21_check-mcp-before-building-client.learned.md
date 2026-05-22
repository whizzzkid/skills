---
skill: wk-workflow
date: 2026-05-21
type: correction
severity: medium
---

Started writing a Ruby HTTP client for a third-party API when an MCP tool for that API already existed in the session.

**What happened:** User asked to create per-PR Datadog notebooks from the pipeline. Agent began implementing a `DatadogNotebookClient` Ruby class with full HTTP plumbing. User interrupted: "why are we writing a notebook client? can't we just use the MCP?" — the Datadog MCP had already been used earlier that same session to create a notebook.

**Root cause:** Before starting implementation, the agent did not survey available MCP tools for the target service. The default path was "write code" rather than "check for an existing tool."

**Suggested fix:** Add a pre-implementation check to wk-workflow Phase 1: before writing any HTTP client or API integration, grep the available MCP tools for the target service name. If an MCP tool exists and the use case is interactive (not pipeline/CI code), prefer the MCP. Only build a client when the call must run in a non-Claude environment (CI containers, cron jobs, etc.) — and document that reason explicitly in the plan.
