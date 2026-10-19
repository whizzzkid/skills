---
skill: wk-arch-review
date: 2026-10-16
type: gap
severity: high
verified-against-source: yes
---

Before putting a subagent research claim into a spec, read the primary source behind it, especially for security
properties.

**What happened:** The spec repeated a research summary saying a credential broker could stand in for egress control,
and called a vendor feature "experimental". The independent adversarial review found that both contradicted the cited
sources.

**Root cause:** The subagent report linked the source, but nobody re-read the source when composing the doc. The
security nuance was in the source and missing from the summary.

**Suggested fix:** Spot-check the primary source of every claim that the recommendation or a security conclusion
depends on, before the draft is complete rather than waiting for the merge gate.
