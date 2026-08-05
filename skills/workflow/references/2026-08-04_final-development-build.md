---
class: principle
---

# Build the user-loadable artifact after mutating gates

**Rule** — Identify every required gate that writes the handoff directory. Run those gates first, then build and
validate the development deliverable as the final artifact-producing command.

**Why** — A later build test can replace a valid handoff directory with a different artifact shape.

**Where** — Phase 3 verification and artifact handoff.
