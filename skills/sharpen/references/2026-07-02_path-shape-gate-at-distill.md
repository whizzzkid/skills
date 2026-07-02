---
class: principle
skill: wk-sharpen
date: 2026-07-02
severity: medium
---

- **Rule:** The distill-time prohibited-subject gate covers not just
  `.skillprohibit` term collisions but shape-matching hooks too. When a lesson's
  core subject IS a path shape that `check-relative-paths` blocks
  (machine-absolute user directories, bare-tilde-rooted literals), the edit text,
  reference, and staged archive can only carry that shape — break the adjacency
  up front, never place-then-reclaim at commit.
- **Why:** `check-relative-paths` matches shape, not intent, on every added line.
  A lesson about a tilde-expansion gotcha necessarily writes the tilde-prefixed
  literal in its examples, so the SKILL edit, its reference, and the staged
  `.learned.md`/retro archive all trip the hook — a collision surfaced only at
  the Step 8 commit, forcing a rework-and-re-stage cycle. Same class as the
  `.skillprohibit` gate, but path shape rather than term list. It is knowable at
  distill time because a lesson about the token can only emit text containing it.
- **Where:** Step 3 prohibited-subject gate — extended the distill-time scan to
  name shape-matching hooks and to note the subject-carries-shape collision.
  Remedy for the path-shape case (unlike a prohibited term, the fold still
  lands): rewrite examples with `$HOME`/`${HOME}` roots or describe the shape in
  prose instead of emitting the raw literal, and scrub the same shape in every
  staged archive before committing.
