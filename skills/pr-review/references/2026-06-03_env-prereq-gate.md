---
class: principle
---

- **Rule:** When a local environment prerequisite fails (daemon down, deps missing, DB unreachable, runtime absent), stop the review and ask the user to fix it; never disclose local env state in any GitHub-posted surface.
- **Why:** Proceeding leaks a reviewer-machine problem into a published comment ("CI is the arbiter") and ships a review with degraded coverage as if it were complete.
- **Where:** Phase 4, "Environment prerequisite gate" HARD RULE (severity:high).
