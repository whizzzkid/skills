---
class: principle
skill: wk-workflow
date: 2026-11-20
---

# Drive lifecycle-dependent UI in a real browser right after the first wiring commit

- **Rule:** A UI change that relies on framework lifecycle (persisted/permanent nodes, frame busy state, morphing,
  cache restore) is driven in a real browser right after its first wiring commit, before docs or the PR. Each
  lifecycle step the browser reveals is then added to the fake test harness as a regression test.
- **Why:** A hand-rolled fake DOM models only the lifecycle its author knew about. In the incident, the fake rendered
  a body swap but never parked a permanent node behind its placeholder, so a lookup at connect time returned null in
  the browser while every test passed. A second defect (two announcements concatenated) was also browser-only. Phase
  3.6 caught both, but only after docs were written; running it at the first wiring commit lands the fix before the
  surrounding work depends on the broken shape.
- **Where:** `SKILL.md` → Phase 3.6 (Frontend Live Preview), HARD RULE. Source: workflow learning (high severity) and
  the session-7 retrospect (What worked + What could've been better).
