---
class: principle
---

# Whole-file structure read after a batch of edits

- **Rule:** After any batch of edits that adds or moves content, read the whole file top to bottom: each item fits its
  heading, heading style is consistent, no point is duplicated, voice and pronouns match. "Formatted correctly?" means
  structure + syntax.
- **Why:** Reviewer proposals applied as quote-for-quote replacements moved content into sections where it no longer
  fit and mixed heading styles. Asked whether the markdown was formatted correctly, the agent ran only lint and width
  checks and reported clean; the user had to point out the misplacements.
- **Where:** [`wk-markdown`](../README.md) → Structure Read-Through. Filed against `wk-sitrep`; rerouted to the owner
  of every `.md` edit.
