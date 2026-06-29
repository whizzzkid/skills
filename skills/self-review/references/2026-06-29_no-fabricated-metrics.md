---
class: principle
skill: wk-self-review
date: 2026-06-29
severity: high
---

# No fabricated quantitative claims in self-review comments

**Rule:** A self-review comment justifying a threshold (timeout, buffer size,
retry count, dimension) with a specific size, latency, or performance figure
must cite a verifiable source or qualify the value as conservative without
inventing a number.

**Why:** The agent inferred a plausible-sounding figure (claiming downloaded
binaries are "typically 15–30 MB") to ground a `--max-time` rationale. No
benchmark, release artifact, or measurement supported it — fabricated. A
self-review documents context for human reviewers; an invented number poisons
that record.

**Where:** Step 2, after the signal-not-noise rule — content-integrity HARD RULE
applied when authoring any comment body.
