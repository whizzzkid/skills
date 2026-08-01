---
class: principle
---

# Generated-artifact acceptance for default-branch-only producers

**Rule** — Reproduce a pinned default-branch-only producer in an isolated repository or controlled live canary before
merge. Feed its exact generated files and mutable metadata through every downstream required check, then keep the
deliverable incomplete until the first live artifact passes its own required CI.

**Why** — Configuration-string assertions and bootstrap metadata do not exercise generated content. Treating a
post-merge execution limitation as a waiver defers the first representative input until after the feature is accepted.

**Where** — `SKILL.md` → Phase 3 → Verification.
