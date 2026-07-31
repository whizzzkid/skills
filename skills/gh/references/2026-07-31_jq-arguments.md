---
class: principle
---

# Bind projection variables with standalone jq

**Rule:** Use `gh --jq` only for self-contained expressions. When a projection needs shell values, pipe raw
`gh --json` output to standalone `jq --arg` or `jq --argjson`.

**Why:** The GitHub CLI accepts one expression for `--jq`; standalone jq argument-binding flags passed afterward are
rejected before evaluation.

**Where:** `wk-gh` read projections for pull requests, runs, issues, and API responses.
