---
skill: wk-workflow
date: 2026-06-10
type: correction
severity: medium
---

Confirm scope before planning when a prompt bundles multiple distinct deliverables.

**What happened:** User provided a prompt with three separate deliverables. Agent began planning all three in parallel. User interrupted twice and issued "forget what I said before" to reduce scope to a single deliverable.

**Root cause:** The wk-plan grill step checks for ambiguous acceptance criteria but does not explicitly check for multi-task bundles where each item could be an independent ticket/PR. A bundle of N tasks feels like a clear requirement but hides a scope decision only the user can make.

**Suggested fix:** When the prompt lists ≥2 distinct deliverables (each could stand alone as a separate commit or PR), surface them as a numbered list and ask: "Should I treat these as one PR or separate?" before entering the planning phase. This is distinct from the existing grill checks (acceptance criteria, scope boundary) — it targets the granularity decision, not the definition-of-done.
