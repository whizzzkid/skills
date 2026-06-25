---
class: principle
---

**Rule:** Resolve a review thread as soon as the pushed commit addresses its
finding (Step 8) — never wait for CI.

**Why:** Grouping push → reply → resolve with the Step 9.5 CI wait lets an
unrelated CI flake leave addressed threads open until manually prompted.
Post-push CI failures belong to a later commit context and do not reopen an
already-addressed thread. Resolution gates on "did the commit address this
finding?", not "did CI pass?".

**Where:** Hard Rule 3 and Step 8 (`Post replies, reactions, resolve threads`),
ahead of the Step 9.5 CI wait.
