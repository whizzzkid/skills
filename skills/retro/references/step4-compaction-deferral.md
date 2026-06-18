---
class: principle
skill: wk-retro
date: 2026-06-18
---

**Rule:** If a session resumes from a compaction summary that mentions an
in-progress retro, the first action is to check whether the Step 4 `wk-learn`
calls for each "What could've been better" bullet were made; if not, make them
before any other work. The compaction summary reliably contains the retro entry
content — use it as the source of truth for which skills still need a `wk-learn`
call.

**Why:** Step 4's "same response" contract is fragile near a context limit:
compaction truncated the retro response before the `wk-learn` invocations ran, so
the calls silently never executed and had to be recovered from the summary next
session.

**Where:** Step 4 — compaction-recovery note alongside the per-skill-gap HARD RULE.
