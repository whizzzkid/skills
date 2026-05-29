---
class: principle
skill: wk-pr-review
date: 2026-05-29
---

# Spec/design docs trigger arch-review unconditionally

- **Rule:** Any changed file under `docs/(specs|adr|arch|design|rfc)/` invokes
  `wk-arch-review` before Phase 3, even when the diff has no code. "Doc-only" is
  never a skip reason.
- **Why:** The trigger checklist keyed on code signals (IaC, new service, trust
  boundary), so a doc-only spec passed through. The arch pass then found a
  high-severity design-model error the spec stated and code would have chased.
- **Where:** Phase 1 — HARD RULE above the architecture-trigger list.
- **Sources:** distilled from two learnings (`docs-specs-path-triggers-arch-review`,
  `spec-doc-triggers-arch-review-unconditionally`).
