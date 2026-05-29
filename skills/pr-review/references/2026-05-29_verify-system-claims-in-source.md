---
class: principle
date: 2026-05-29
skill: wk-pr-review
---

# Verify the author's system-behavior claims against source, not prose

- **Rule:** When an author's re-review reply or fix asserts how the
  surrounding system behaves, verify the claim against the relevant source
  file — grep for the behavior it denies — before acknowledging the thread.
- **Why:** Spec/design PRs assert facts about the codebase. A re-review that
  only checks the spec's prose against itself never confirms the factual
  claims are true; a wrong claim ships as documented truth.
- **Where:** Phase 2 "Re-review follow-up" → "Validate a claimed fix" — new
  bullet on verifying system-behavior claims against source.
