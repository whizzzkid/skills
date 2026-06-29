---
skill: wk-self-review
date: 2026-06-29
type: correction
severity: high
---

Never state a specific size, latency, or performance figure in a self-review comment without a verifiable source.

**What happened:** A self-review comment justified a `--max-time` value by claiming the downloaded binaries are "typically 15–30 MB." No benchmark, release artifact, or measurement in the codebase supported this figure — it was fabricated.

**Root cause:** The agent inferred a plausible-sounding number to make a rationale feel grounded, rather than acknowledging the measurement was unknown.

**Suggested fix:** When writing justification for a timeout, buffer size, or similar threshold, either cite a concrete source (e.g., "the largest release artifact in the repo is X MB per the CI upload log") or state the value is conservative without quantifying. "Unknown binary size — 30 s is conservative for any reasonable CDN response" is honest; an invented range is not.
