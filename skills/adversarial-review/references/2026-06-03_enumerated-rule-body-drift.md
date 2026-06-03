---
class: principle
---

- **Rule:** When a commit narrows/expands an enumerated set (banned items, allowed items, supported flags), extract the removed tokens and grep the PR body for each; confirm the body's prose enumeration matches HEAD.
- **Why:** Body edits are not in the file diff the other sweeps scan, so a "narrow X to only Y" commit leaves the body describing the old, broader set. The rename audit misses it because the token is removed from a list inside a surviving file, not via `--diff-filter=D`.
- **Where:** New bullet in sweep 2.10 (PR metadata sync), beside the rename audit.
