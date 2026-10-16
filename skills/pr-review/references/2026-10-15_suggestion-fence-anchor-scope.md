---
class: principle
---

# A suggestion fence is an exact replacement for its anchored range

**Rule** — before posting, check that the fence's lines replace exactly `start_line..line`. A context line either
joins the anchored range or stays out of the fence.

**Why** — GitHub swaps the anchored range for the fence body. A single-line fence that also repeated the line above
the anchor would have duplicated that line when applied. The existing contiguous-range rule covers multi-site fixes,
not context lines inside a one-range fence.

**Where** — `SKILL.md` → Phase 4, suggestion-fence bullet.
