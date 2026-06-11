---
class: principle
---

- **Rule** — When a prompt bundles ≥2 distinct deliverables (each could be its
  own ticket/commit/PR), list them and ask "one PR or separate?" before
  planning.
- **Why** — The agent began planning a 3-deliverable bundle without confirming
  granularity; the user interrupted twice with "forget what I said before."
- **Where** — Step 0 grill: new ambiguity-signal row + "Multi-deliverable
  granularity" rule.
- **Source** — materialized from global memory
  `feedback_confirm_scope_multi_deliverable`; mirrors wk-workflow Phase 1's
  Multi-deliverable scope probe so direct `/wk-plan` invocations also gate it.
