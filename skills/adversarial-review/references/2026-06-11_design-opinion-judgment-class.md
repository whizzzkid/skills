---
class: one-off
date: 2026-06-11
skill: wk-adversarial-review
---

- **Scenario:** A post-push bot re-raises subjective design-quality findings
  (abstraction, type-precision) that contradict a refactor accepted earlier in
  the same session — one proposing to reverse the accepted change.
- **Symptom:** Risk of re-churning an intentional design choice into another
  fix cycle.
- **Fix:** Treat as judgment-class — route to wk-pr-resolve Step 4
  convergence/terminal-thrash handling: dismiss-with-rationale and resolve.
- **Why not promoted:** No mechanical sweep applies — taste/structure opinions
  can't be grepped without false-positiving every intentional design choice;
  the thrash-handling rule already covers the action.
