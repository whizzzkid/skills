---
class: principle
---

# PR resolution completes against remote state

**Rule** — Before completion, refetch the PR and verify remote HEAD, recorded reply/resolution decisions, and required
CI state; a mismatch resumes its owning step.

**Why** — Local changes and recoverable environment errors do not establish that the PR received the commits, replies,
thread resolutions, or CI outcome required for completion.

**Where** — Step 9.5 terminal condition.
