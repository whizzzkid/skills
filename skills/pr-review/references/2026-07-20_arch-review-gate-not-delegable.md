---
class: principle
---

**Rule** — The arch-review trigger for spec/plan/ADR diffs is satisfied ONLY by a
real `Skill(wk-arch-review)` invocation. A general-purpose subagent running an
arch-review-shaped prompt does NOT satisfy it. Subagent delegation of spec-claim
verification is a valid ADDITION on top of the skill, never a REPLACEMENT.

**Why** — Substituting a subagent prompt for the skill skips the skill's Eight
Lenses, its empirical-pass HARD RULE, and its findings-report contract — the
coverage the gate exists to guarantee.

**Where** — Phase 1, "Detect architecture-level changes" HARD RULE. Applies
whenever the diff touches spec/adr/design/rfc/plan markdown, prose, or doc comments.
