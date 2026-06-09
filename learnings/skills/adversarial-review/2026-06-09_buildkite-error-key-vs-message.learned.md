---
skill: wk-adversarial-review
date: 2026-06-09
type: gap
severity: high
---

Check external API error-response schema before asserting which key encodes the error message.

**What happened:** Skill instructions checked for an `error` key in Buildkite REST responses, but Buildkite returns `{"message": "..."}` on failure. Silent failure — `web_url` absent → success path skips; `error` absent → failure path skips; no output rendered.

**Root cause:** Sweep 2.11 (external-call reproduction) was not run against the response shape — the error key was assumed rather than verified against the Buildkite API docs or a live error response.

**Suggested fix:** Add an external-API-response-shape check to the adversarial subagent prompt: when a diff adds error-key checks (`error`, `err`, `errors`) against an external API, verify the API's actual error schema. Detection: `git diff | grep -nE '"error"\s*key\s*present|error.*key'`.
