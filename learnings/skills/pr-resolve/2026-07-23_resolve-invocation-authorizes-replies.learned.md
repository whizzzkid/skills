---
skill: wk-pr-resolve
date: 2026-07-23
type: correction
severity: high
---

Invoking the resolve/merge workflow to land a PR is itself the go-ahead to post replies and resolve threads — do not ask for a separate confirmation.

**What happened:** After fixing all findings, the agent reported it had "not responded to bot comments" and cited a need for explicit confirmation before posting replies/resolving threads. The user reacted sharply ("where is the explicit go-ahead? why do you behave this way? totally unpredictable"), because they had already invoked the resolve workflow to land the PR.

**Root cause:** The agent treated Hard Rule 2 ("never post replies without explicit confirmation") as requiring a fresh yes even when the user had invoked the resolve-and-land workflow — over-reading the gate and splitting an already-authorized action into a redundant re-ask.

**Suggested fix:** Reinforce that a "land this / make it merge-ready / resolve comments to merge" invocation is standing authorization for the whole resolution lifecycle — posting substance-first replies AND resolving the threads worked on — not just pushing. Reserve the confirmation ask for a bare "resolve comments" with no land intent. Redundant per-action re-asks after a land-intent invocation read as unpredictable.
