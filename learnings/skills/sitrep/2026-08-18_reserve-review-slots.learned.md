---
skill: wk-sitrep
date: 2026-08-18
type: gap
severity: medium
verified-against-source: yes
---

Reserve nested-agent capacity when auto-launching pull-request reviews.

**What happened:** Starting several review workers concurrently consumed every available agent slot. Each review then
needed mandatory architecture or adversarial workers, so progress stopped until parent workers were interrupted and
the reviews were serialized.

**Root cause:** The sitrep auto-review stage caps top-level review workers but does not account for the nested workers
required by the review skill or the runtime's total concurrency limit.

**Suggested fix:** Compute top-level review concurrency from the runtime limit and the review skill's maximum nested
fan-out. Reserve enough slots for mandatory nested passes, and serialize reviews when the runtime cannot guarantee
that capacity.
