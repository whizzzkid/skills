---
class: principle
---

# Automated drains must not enqueue their own completion records

**Rule** — A loop worker returns its terminal summary to the dispatcher; it does not invoke `wk-learn` or
`wk-retro`.

**Why** — Batch mode consumes learnings and retrospects. A worker-generated completion record becomes the next
cycle's input, so an otherwise idle queue never converges.

**Where** — [`wk-sharpen`](../README.md), *Loop Mode* and *Post-Completion*.
