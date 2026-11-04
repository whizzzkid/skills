---
skill: wk-pr-review
date: 2026-11-03
type: pattern
severity: low
verified-against-source: n/a
---

Per-finding refute verifiers inflate severity; re-map against the concern definition before posting.

**What happened:** A parallel verify pass (one refuting agent per finding) confirmed most findings but labeled a metrics-skew issue `concern`, which would have held approval on a non-critical item.

**Root cause:** Verifier prompts asked for a severity draft without restating that `concern` is reserved for correctness/security/data-loss.

**Suggested fix:** In Phase 3, re-check every verifier-assigned `concern` against the severity definition before the approve gate; include the definition verbatim in verifier prompts.
