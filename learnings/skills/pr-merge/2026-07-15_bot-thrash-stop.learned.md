---
skill: wk-pr-merge
date: 2026-07-15
type: pattern
severity: medium
---

Recognize push-triggered bot re-evaluation surfacing an unbounded tail of new Minors ("bot-thrash") and stop the push cycle rather than chasing each finding.

**What happened:** Each push to satisfy one bot finding triggered a fresh automated review that surfaced brand-new Minor findings; the cycle threatened to never converge until the agent flagged it and the user chose to merge and defer.

**Root cause:** An automated reviewer re-runs on every push and dismisses its own stale approval, so fixing Minors by pushing can generate more Minors — there is no fixed-point without a stop rule.

**Suggested fix:** When a push produces new-only Minor/Info findings for ≥1 round, surface the thrash explicitly and offer merge-now-with-deferred-follow-ups instead of pushing again; only a Blocker/Major justifies another push.
