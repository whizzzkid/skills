---
class: principle
---

# Confirm scope before changing environments

**Rule:** Confirm optional sibling-repository work before entering it. Within an approved repository, probe a
runnable container toolchain before proposing task-specific host installs.

**Why:** Adjacent work silently expands the deliverable, while host mutation creates persistent machine state when
the repository may already carry an isolated runtime.

**Where:** `wk-workflow` planning scope and environment guardrails.
