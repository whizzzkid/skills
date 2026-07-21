---
skill: wk-pr-resolve
date: 2026-07-21
type: correction
severity: medium
---

A reply to a reviewer thread opened with a banned praise word ("Good catch"), violating the substance-first HARD RULE.

**What happened:** When replying to a bot finding that was a genuinely correct edge-case catch (a midnight race), the reply body led with "Good catch — real boundary bug. Fixed in ...". Hard Rule 2 bans praise/thanks openers ("Good catch!") unconditionally; the reply should have led directly with the substance (what changed + commit SHA).

**Root cause:** The rule is easy to violate precisely when the finding *is* impressive — the instinct to acknowledge a good catch is strongest exactly where the ban applies. The jq-built body was written and posted in one step with no pre-emit lint for opener words.

**Suggested fix:** Add a mechanical pre-emit check on every reply/dismissal body before the `gh api .../replies` POST: reject if the body's first sentence matches a praise/thanks pattern (`^(good catch|great|thanks|nice|well spotted|nice catch|good point)`). Mirror the wk-gh footer pre-emit gate — a grep guard is cheap and catches the slip the prose rule doesn't.
