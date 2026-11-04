---
class: principle
---

# Diff production files before committing while agents may be mutating

- **Rule:** With dispatched agents possibly still running, confirm every agent finished and `git diff` each
  production file against the intended change before committing; an unexplained hunk blocks the commit. Have
  mutation-testing agents mutate copies, or only files no other agent loads.
- **Why:** A commit request arrived while spec agents were mutation-testing. A production file on disk still held a
  deliberately broken line; only a pre-commit diff caught it. Parallel agents share the working tree, so a temporary
  mutant looks exactly like a real edit to `git add` and to the commit.
- **Where:** [`wk-workflow`](../README.md) → Phase 2: Implement, after the step-by-step commit loop.
