---
class: principle
date: 2026-05-29
skill: wk-workflow
---

# Check open PRs for an in-flight spec before creating a new one

- **Rule:** Before producing a new spec/design doc, grep open PRs for a
  related spec in the same feature area; if one exists, stack on it and
  extend that doc rather than landing a parallel file.
- **Why:** Parallel specs force a later hand-merge (doc merge plus rebase)
  when the user notices the overlap mid-stream.
- **Where:** Phase 1 "Spec pre-flight — extend an in-flight spec before
  creating a new one".
