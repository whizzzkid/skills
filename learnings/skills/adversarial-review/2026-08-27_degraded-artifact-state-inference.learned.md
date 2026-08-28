---
skill: wk-adversarial-review
date: 2026-08-27
type: gap
severity: high
verified-against-source: yes
---

State inferred from a rendered artifact (summary comment) was trusted even when the artifact was produced in a degraded mode that omitted the very content the inference relied on.

**What happened:** Code stamped findings as "posted" because a summary comment existed, but a degraded-mode summary can render with zero findings listed -- the existence of the artifact did not prove the state it was taken to imply. The reviewer caught this only in a delta round, as a late blocker.

**Root cause:** No sweep covers "state derived from an output artifact must be gated on the artifact's trustworthiness/degradation flags." The mechanical sweeps check guards and sentinels but not provenance of state inference from rendered output.

**Suggested fix:** Add a sweep/hunt category: when a diff derives persisted state from the existence or content of a produced artifact (summary, report, comment), verify every degraded/partial/fallback production path of that artifact and require the inference to be gated on a non-degraded signal (e.g. "summary exists AND was not produced under a degraded reason").
