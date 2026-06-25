---
class: principle
---

**Rule:** Review-comment resolution is per-push, not one-time. Re-poll and run
`wk-pr-resolve` after every later push (bots re-review on each push), and never
run the Phase 8 retro while a push since the last `wk-pr-resolve` pass has
unaddressed threads.

**Why:** After a second round of commits, the session jumped to the retro without
re-running pr-resolve, leaving new bot findings from the latest push unaddressed.
The resolution loop was treated as a one-time step rather than firing on each
push.

**Where:** Phase 6.5 (Review-Comment Resolution Loop) — escalated "re-poll after
every pass" to "and after every later push," plus a retro precondition. (Learning
filed under wk-pr-resolve; orchestration home is wk-workflow.)
