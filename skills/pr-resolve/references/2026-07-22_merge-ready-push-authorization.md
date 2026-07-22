---
class: principle
---

- **Rule**: A merge-ready / "make it mergeable" / "land this" directive in the
  original invocation IS blanket push authorization for the whole resolution
  lifecycle (including CI-loop re-pushes) — confirm once at that reading, then
  push each round without re-asking. A bare "resolve comments" is NOT push
  authorization; each push still needs a fresh yes.
- **Why**: Hard Rule 1 demands explicit push confirmation and holds under Auto
  Mode, but did not say whether a merge-ready directive counts as that
  confirmation. The two readings conflict and the skill picked one silently —
  pushing multiple commits autonomously without re-asking.
- **Where**: wk-pr-resolve Hard Rule 1 (push confirmation).
