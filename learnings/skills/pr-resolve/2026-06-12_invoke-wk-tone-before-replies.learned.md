---
skill: wk-pr-resolve
date: 2026-06-12
type: gap
severity: high
---

Invoke `wk-tone` before drafting any outbound reply comment on the user's behalf.

**What happened:** Agent drafted and posted PR review reply comments without invoking `wk-tone` first, resulting in tone violations (e.g., "Good catch") that the user had to correct after the fact.

**Root cause:** Step 5 (consult) and Step 6 (execute) draft reply bodies inline without a tone gate. The skill has no explicit instruction to load `wk-tone` before drafting replies.

**Suggested fix:** Add a mandatory `Skill(wk-tone)` invocation in Step 5 (before the first reply draft is produced) or as a pre-flight step in Step 8.6 (before posting replies). Every reply posted on the user's behalf must pass through their tone preferences before it goes out — corrections after posting are visible and embarrassing.
