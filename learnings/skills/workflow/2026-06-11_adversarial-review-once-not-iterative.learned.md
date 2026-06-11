---
skill: wk-workflow
date: 2026-06-11
type: correction
severity: high
---

Run adversarial review once on the complete implementation — not after each partial commit in a multi-site change.

**What happened:** Adversarial review ran three times across five commits for a single logical change. Each partial commit triggered a new review, which found the next layer of gaps, producing a slow commit-review-fix loop.

**Root cause:** The workflow treats adversarial review as a per-commit gate rather than a per-feature gate. For a cross-cutting change, "complete" means all affected sites are implemented — not just the first one the agent touched.

**Suggested fix:** Hold all commits for a cross-cutting change until the full site map is implemented, then run one adversarial review. The commit sequence should be: enumerate sites → implement all → commit → review → fix residuals → done. "One commit per logical change" means the logical change is the whole feature, not each file touched.
