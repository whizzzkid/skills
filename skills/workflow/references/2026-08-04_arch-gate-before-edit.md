---
class: principle
---

# Architecture paths are classified before editing

**Rule** — Classify every planned path before the first patch. When a spec,
architecture decision, design, RFC, implementation plan, or equivalent
arch-bearing path is present, run `wk-arch-review`'s mechanical detector then;
route the completed draft to the authoring owner's single review gate.

**Why** — Detecting architecture scope only after commit or push bypasses the
owner gate until the design is already published. Running the detector early
does not mean dispatching twice: classification precedes editing; review remains
at draft-complete.

**Where** — `SKILL.md` → Phase 2 pre-patch path/content classification.
