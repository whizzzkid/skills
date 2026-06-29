---
skill: wk-workflow
date: 2026-06-29
type: correction
severity: high
---

Never propose deferring a security guard clause without an explicit user instruction to do so.

**What happened:** When triaging a finding that a CDN URL from an API response was passed directly to curl without scheme validation, the agent proposed deferring the SSRF guard to a follow-up. The user immediately corrected: "I did not ask you to defer the validation, continue triaging."

**Root cause:** "Defer for follow-up" framing was applied to a security validation as if it were a feature — but guard clauses protecting against injection/SSRF are not optional scope. The agent conflated "cloudsmith-cli as a replacement" (a valid follow-up) with the guard itself (a fix required now).

**Suggested fix:** When a finding is a missing guard clause or security validation (SSRF, injection, path traversal, scheme check), treat it as a blocker-class fix regardless of scope. Never propose deferring it without user direction. "Apply guard now, track the larger tooling replacement separately" is always the right split.
