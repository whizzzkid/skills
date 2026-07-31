---
class: principle
---

# Confirm optional cross-repository work

**Rule:** Separate required work from optional sibling-repository hardening.
Confirm that added repository scope before inspecting or implementing it, and
prefer a runnable repository devcontainer before task-specific host installs.

**Why:** Related ownership does not expand the approved deliverable, and host
mutation creates persistent machine state when an isolated runtime may exist.

**Where:** `wk-workflow` Phase 1 and environment guardrails.
