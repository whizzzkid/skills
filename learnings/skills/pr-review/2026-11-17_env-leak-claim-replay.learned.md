---
skill: wk-pr-review
date: 2026-11-17
type: correction
severity: medium
verified-against-source: yes
---

A prior review refuted an author's env-dependent failure count, but the reviewer's replay had leaked CI-like env vars.

**What happened:** An earlier run claimed "all N examples fail locally, not N-2". The author rebutted: the two extra
examples reach the external tool only when specific CI env vars are set. A re-run under `env -i` with only HOME and
PATH confirmed the author: both pass bare, and each fails only when its gating var is set.

**Root cause:** Claim replay inherited the reviewer's shell env, so a "laptop-like" run was not laptop-like.

**Suggested fix:** When replaying a claim that depends on environment ("fails locally", "CI-only"), run under
`env -i HOME=$HOME PATH=$PATH` and add the gating vars one at a time to attribute each difference. Also: an own pending
draft can be submitted with a replacement body via `POST /reviews/{id}/events`, so no delete+recreate is needed.
