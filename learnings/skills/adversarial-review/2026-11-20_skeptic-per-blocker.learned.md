---
skill: wk-adversarial-review
date: 2026-11-20
type: practice
severity: low
verified-against-source: n/a
source: learnings/retrospect/2026-11-20_session-7 and 2026-11-20_session-9 (What worked)
---

A fan-out adversarial review with one skeptic per finding downgraded an over-severe blocker and found real defects.

**What happened:** One skeptic per finding downgraded an over-severe blocker and surfaced mutation survivors, each
fixed with a regression test. In a later session the same shape surfaced framework side effects that request specs
cannot see.

**Suggested fix:** After the adversarial subagent returns, dispatch one skeptic per blocker that tries to refute it
with a reproduction; refuted → question.
