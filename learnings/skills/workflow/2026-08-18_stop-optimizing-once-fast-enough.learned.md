---
skill: wk-workflow
date: 2026-08-18
type: correction
severity: low
verified-against-source: n/a
---

Agent kept proposing further CI-optimization splits (separating container-only steps from zip/git-needing steps) after the user's actual goal — "fast enough" — was already met.

**What happened:** After landing a working, fast CI pipeline, the agent floated one more architectural change (splitting a monolithic task to shrink a container's extra-install step) in response to the user probing why a step was slow. The user declined: the current state already solved the original problem and further tuning wasn't wanted.

**Root cause:** (unverified — inferred from symptom) No stopping criterion for "good enough" performance work — the agent treated every follow-up question about timing as an invitation to propose another optimization, rather than distinguishing curiosity ("why is this slow") from a request for more work.

**Suggested fix:** When a user asks a clarifying "why is X slow" question after the primary metric already improved dramatically (e.g. 20min → seconds), answer the question and stop — do not pair the answer with a new optional refactor proposal unless the user asks "what else can we do."
