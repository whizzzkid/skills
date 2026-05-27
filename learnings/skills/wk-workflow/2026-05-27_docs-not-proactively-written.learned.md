---
skill: wk-workflow
date: 2026-05-27
type: correction
severity: medium
---

Agent did not proactively update docs alongside implementation commits; user had to explicitly ask.

**What happened:** After implementing a multi-file feature (Go + Ruby + tests), the agent committed the code without updating user-facing documentation or writing a spec doc. The user redirected: "document these changes and update the spec too."

**Root cause:** Phase 2 of wk-workflow requires `wk-docs` invocation with each commit, but the agent treated docs as a separate follow-up step rather than part of each commit boundary.

**Suggested fix:** At every commit boundary in Phase 2, explicitly check: "Does this change introduce or modify any user-facing behavior, config schema, or API surface?" If yes, the doc update must land in the same commit — not as a follow-up. For config-schema additions specifically (new YAML fields, new env vars, new JSON output fields), always include a docs/specs entry and update any reference docs in the same or immediately subsequent commit.
