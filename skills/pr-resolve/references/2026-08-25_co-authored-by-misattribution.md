---
class: principle
source: learnings/skills/pr-resolve/2026-08-25_co-authored-by-misattribution.md
---

# Co-authored-by claims content contribution, not branch ownership

`Co-authored-by` is a claim about who contributed to a specific commit's
content. It fires only when the commit incorporates the PR author's work
(applying their suggested change, pairing, using their patch).

Purely agent-authored fixes on someone else's branch (lint, merge conflict
resolution, CI fixes) get only `Assisted-by: Claude` — crediting the PR
author as co-author for work they did not write misattributes the change.
