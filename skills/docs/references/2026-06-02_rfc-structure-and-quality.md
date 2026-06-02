---
class: principle
date: 2026-06-02
severity: high
---

- **Rule:** Before authoring or finalizing a spec, RFC, design doc, ADR, or plan
  (not routine README/code-doc updates), enforce five gates: (1) machine-readable
  YAML frontmatter (title, type, status, author, created, last_updated, epic,
  reviewers, labels, related); (2) Diátaxis separation of explanation/reference/
  guide plus a "How to read this doc" note; (3) diagram discipline — one
  top-level block diagram of all components and their contracts, then one focused
  detail diagram per component, never a single monolithic diagram; (4) link
  hygiene — resolve every doc path on disk and verify every ticket/URL, marking
  not-yet-created artifacts as TBD; (5) no fabricated sizing — omit or mark TBD
  any effort estimate the user did not supply.
- **Why:** A spec shipped without frontmatter, with a monolithic diagram,
  unmarked dead links to not-yet-created artifacts, and invented effort estimates
  forced multiple revision rounds. Unmarked speculative links and fabricated
  sizing mislead reviewers who treat the doc as authoritative. Sibling skill
  wk-arch-review enforces the same checklist on its review output; wk-docs
  carries it as the authoring-side pre-delivery gate.
- **Where:** Step 4 "Spec / RFC Quality Gate" (scoped to specs/RFCs/design
  docs/ADRs/plans only).
