---
class: principle
---

# Keep jq argument binding outside gh

**Rule:** Keep self-contained projections in `gh --jq`; send raw `--json` output to standalone `jq` when shell
variables must be bound.

**Why:** `gh --jq` accepts only an expression, so standalone argument flags are rejected before jq evaluates it.

**Where:** Any `wk-gh` query whose projection compares GitHub data with a shell value.
