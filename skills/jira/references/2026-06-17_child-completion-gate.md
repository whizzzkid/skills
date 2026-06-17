---
class: principle
severity: high
---

# Never close a parent with open children

**Rule:** Before any terminal transition (`Done`/`Closed`/`Resolved`) on a
parent item, query its children via JQL and block the transition if any
child is not in the `Done` status category. Surface the open list and let
the user decide; default to hold.

**Why:** A parent transitioned ahead of its children buries unfinished
work — invisible on the board, falsely counted complete. The state was
moved without human judgment on the pending items.

**Where:** Stage 5 (auto Done on PR merge) and the terminal-state row of
Manual ticket operations both invoke the Child-completion gate subroutine.
Use `statusCategory != Done` (category, not named status) so every
non-terminal state on any board counts as pending. Unverifiable child
state → treat as unverified, do not auto-transition.
