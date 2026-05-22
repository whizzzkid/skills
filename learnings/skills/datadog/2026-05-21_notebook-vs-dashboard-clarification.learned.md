---
skill: wk-datadog
date: 2026-05-21
type: correction
severity: medium
---

Built a per-PR notebook approach when the user actually wanted a single reusable dashboard with template variable filtering.

**What happened:** User asked for "a new notebook per PR." Agent pivoted from Ruby client to MCP notebook creation. User then said "no that's not what I want, can you create a dashboard instead?" — the correct solution was one dashboard with `$repo` and `$pr_number` template variables, not a notebook created per run.

**Root cause:** "Notebook per PR" was taken literally. The user's intent was a single artifact they could filter to any PR, not thousands of individual notebooks. A dashboard with template variables is the canonical Datadog pattern for this use case.

**Suggested fix:** When a user asks to "create X per Y", clarify whether they want (a) one reusable resource filtered by Y, or (b) a new resource created for each Y instance. For Datadog specifically: per-entity views → dashboard with template variables; per-incident investigation → notebook. Ask before building if the distinction isn't explicit.
