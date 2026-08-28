---
class: principle
---

**Rule** — When a symptom report drives a revert/rewrite of freshly-merged work, validate the mechanism in the affected system before planning a fix. A dissolved premise → re-land the original commit, not re-implement. A perception-based symptom (slow load, missing skeleton loaders) → surface the UI-affordance gap as the real follow-up.

**Why** — Perceived-data-loss reports are indistinguishable from real ones at the prompt level; without the is-a-fix-warranted gate, the plan would execute a revert + cross-repo re-implementation of a correct design.

**Where** — Step 0, is-a-fix-warranted gate sub-bullets.
