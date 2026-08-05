---
class: principle
---

# Optional end with next-start rollover

- **Rule:** Treat `end` as optional. Before today's `start` overwrites an
  unfinished prior live page, run that day's complete `end` flow; stop on any
  close failure. Record completion only when the final marker and every close
  artifact are committed and pushed.
- **Why:** Requiring a separate evening invocation loses snapshots, scrubbed
  carry-over, brag entries, and learning capture whenever the invocation is
  missed.
- **Where:** `SKILL.md` start Stage 0.5 + end Stage 8;
  `references/missed-end-rollover.md`; sibling `README.md`.
