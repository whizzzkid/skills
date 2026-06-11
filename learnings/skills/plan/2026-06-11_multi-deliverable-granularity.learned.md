---
skill: wk-plan
date: 2026-06-11
type: gap
severity: medium
source: memory:feedback_confirm_scope_multi_deliverable
---

When a prompt lists ≥2 distinct deliverables that could each stand alone,
ask "one PR or separate?" before entering the planning phase.

**What happened:** Agent began planning a 3-deliverable bundle without
confirming granularity; user interrupted twice with "forget what I said
before" and reduced scope to a single deliverable.

**Root cause:** wk-plan Step 0 grill detected vagueness signals but had no
granularity signal; wk-workflow Phase 1 had the probe but direct `/wk-plan`
invocations bypassed it.

**Distilled:** Step 0 grill gains a "≥2 distinct deliverables bundled" signal
row + Multi-deliverable granularity rule.
