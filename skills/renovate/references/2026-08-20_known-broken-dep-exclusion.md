---
class: principle
source: learnings/skills/renovate/2026-08-20_known-broken-dep-exclusion.md
date: 2026-08-20
skill: wk-renovate
---

## Principle

Batch-apply workflows must pause for user confirmation after listing candidates
so known-broken or blocked items can be excluded before any edits begin.

## Evidence

Agent began applying a major-version Redis client bump before the user
interrupted. The manifest had already been edited, requiring a correction.

## Resolution

Added a confirmation checkpoint to Step 1 — display the table, highlight
major-version bumps, and wait for explicit proceed or exclusion list.
