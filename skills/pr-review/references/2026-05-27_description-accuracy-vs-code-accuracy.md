---
class: principle
---

- **Rule**: Verify specific claims in the PR description / commit message (line ranges, attribute lists, "each/all" framing) against the actual diff; flag mismatches as suggestion-severity body notes even when the code is correct.
- **Why**: A clean diff with a misleading description ships misinformation; future readers act on it. Description accuracy is a separate review surface from code accuracy.
- **Where**: wk-pr-review Phase 3, "Verify PR description and commit-message claims".
