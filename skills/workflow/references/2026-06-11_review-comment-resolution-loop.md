---
class: principle
---

- **Rule** — After CI exits green, loop `wk-pr-resolve` until zero unresolved
  PR review threads remain; re-poll after each pass and resume the loop on
  later runs, since reviewers comment asynchronously across sessions.
- **Why** — A one-shot resolve pass strands every comment added afterward and
  stalls the merge; treating the PR as done after one pass leaves later threads
  open indefinitely.
- **Where** — New Phase 6.5 (Review-Comment Resolution Loop), between Phase 6
  and Phase 7; also wired into the ASCII flow, both plan lists, and the final
  checklist.
