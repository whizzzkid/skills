---
class: principle
skill: wk-plan
date: 2026-11-20
---

# Measure a claimed saving before planning the fix

- **Rule:** When acceptance criteria assert a request-count or latency saving, write out the request sequence before
  and after the change and measure the baseline (network log, aborted vs completed) before drafting. If the model
  contradicts the claim, raise it as `[HUMAN-IN-LOOP]`: fix, redesign, or close as working-as-intended.
- **Why:** A ticket claimed that skipping a restore during a cached-preview render would save a request. The fix and
  its unit tests landed first. A later network count showed the opposite: the existing path aborted the original
  request early, and the fix let a stale page render before the restore (one more completed request, plus a flicker).
  The premise was never modelled or measured.
- **Where:** `SKILL.md` → Step 0 → Is-a-fix-warranted gate, sub-bullet. Race/ordering premises point to
  `wk-workflow` Phase 2's red-reproduction HARD RULE.
