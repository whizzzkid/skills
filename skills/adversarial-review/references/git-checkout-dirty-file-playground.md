---
class: principle
---

**Rule:** A finding that a "safe no-op" or a missing error-path write is a defect must cite a concrete failure scenario where the absence causes incorrect behavior. Cap at `question` without a repro.

**Why:** Absence of defensive code is not itself a correctness defect. Writing a default (e.g. `{}`) on a read failure can clobber legitimate local-only state when the no-op is the correct bootstrap behavior. Playground validation correctly separated a real git-checkout abort (dirty tracked file) from a fabricated "should write empty state on git show failure" blocker.

**Where:** Step 3 trait "absence-claim-cautious"; Contract item 8.
