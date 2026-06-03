---
class: principle
---

- **Rule:** Run the merge-base distance base-detection unconditionally before any scope measurement or `gh pr create` — never assume the default branch.
- **Why:** Creating against the wrong base pulls a parent in-flight branch's commits into the diff and runs CI against the wrong target; mis-basing is hard to recover once reviewers start reading.
- **Where:** Hard Rule 3 (elevates the existing Step 1 "Detect the true base branch (run unconditionally)" sub-step to a gate, since the incident was skipping an already-present sub-step).
