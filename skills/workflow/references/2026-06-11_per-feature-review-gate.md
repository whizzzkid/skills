---
class: principle
---

- **Rule** — Adversarial review is a per-feature gate: run once on the complete
  logical change before the publishing push, not after each incremental commit.
- **Why** — Reviewing partial commits of a multi-site change ran the gate 3×
  across 5 commits, each round rediscovering the next unimplemented site — a
  slow commit→review→fix loop.
- **Where** — Phase 4 HARD RULE "per-feature gate, not per-commit"; Phase 2
  "Cross-cutting change: enumerate sites, then implement all before review".
- **Source** — two high-severity last-session learnings (adversarial-review-once,
  enumerate-sites-before-implementing).
